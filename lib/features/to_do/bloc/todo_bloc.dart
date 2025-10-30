// lib/to_do/bloc/todo_bloc.dart

import 'package:all_in_one_app/features/to_do/bloc/todo_event.dart';
import 'package:all_in_one_app/features/to_do/bloc/todo_state.dart';

import 'package:all_in_one_app/features/to_do/domain/todo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/repositories/to_do_repository.dart';

// These 'part' files are linked to this 'main' bloc file

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  // Constructor: Sets the initial state
  final TodoRepository _todoRepository;

  // 4. Update the constructor to REQUIRE the repository
  TodoBloc({required TodoRepository todoRepository})
    : _todoRepository = todoRepository,
      // 5. Assign it
      super(TodosLoading()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<ToggleTodo>(_onToggleTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<UpdateTodo>(_onUpdateTodo);
  }

  // The event handler function for 'LoadTodos'
  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    // 1. Emit the loading state to show a spinner in the UI
    emit(TodosLoading());

    try {
      // 7. This is the new part!
      //    We call the REPOSITORY, not Supabase directly
      final List<Todo> todos = await _todoRepository.getTodos();

      // 8. Emit the success state with the real data
      emit(TodosLoaded(todos: todos));
    } catch (e) {
      // 4. If anything goes wrong, emit the error state
      emit(TodosError(e.toString()));
    }
  }

  // --- 2. ADD THE NEW HANDLER FUNCTION ---
  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    // Get the current state
    final currentState = state;

    // We can only add a todo if we are already in the 'Loaded' state
    if (currentState is TodosLoaded) {
      try {
        // Call the repository to add the item to Supabase
        // This will return the new Todo object
        final newTodo = await _todoRepository.addTodo(event.task);

        // Create a new list based on the old list, plus the new todo
        final updatedList = List<Todo>.from(currentState.todos)..add(newTodo);

        // Emit the new 'Loaded' state with the updated list
        emit(TodosLoaded(todos: updatedList));
      } catch (e) {
        // If it fails, you could emit a temporary error state

        emit(TodosError('Failed to add todo: $e'));
      }
    }
  }

  Future<void> _onToggleTodo(ToggleTodo event, Emitter<TodoState> emit) async {
    // Get the current state
    final currentState = state;

    if (currentState is TodosLoaded) {
      // 1. Create an updated list
      final List<Todo> updatedTodos = currentState.todos.map((todo) {
        // Find the todo that was toggled
        if (todo.id == event.id) {
          // Use our new copyWith method!
          return todo.copyWith(isComplete: event.isComplete);
        }
        // Return all other todos unchanged
        return todo;
      }).toList();

      // 2. EMIT THE NEW STATE IMMEDIATELY (Optimistic Update)
      // The UI will rebuild right away, feeling very fast.
      emit(TodosLoaded(todos: updatedTodos));

      // 3. Now, try to sync this change with Supabase
      try {
        await _todoRepository.toggleTodo(event.id, event.isComplete);
        // If it succeeds, great! Our state is already correct.
      } catch (e) {
        // 4. If it fails, roll back the state
        emit(TodosError('Failed to toggle todo, rolling back: $e'));
        // Re-emit the *original* state to undo the change in the UI
        emit(currentState);
      }
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    // Get the current state
    final currentState = state;

    if (currentState is TodosLoaded) {
      // 1. EMIT THE NEW STATE IMMEDIATELY (Optimistic Update)
      // Create a new list *without* the deleted item.
      final updatedList = currentState.todos
          .where((todo) => todo.id != event.id)
          .toList();

      emit(TodosLoaded(todos: updatedList));

      // 2. Now, try to sync this change with Supabase
      try {
        await _todoRepository.deleteTodo(event.id);
        // If it succeeds, great! Our state is already correct.
      } catch (e) {
        // 3. If it fails, roll back the state
        emit(TodosError('Failed to delete todo, rolling back: $e'));
        // Re-emit the *original* state to undo the change in the UI
        emit(currentState);
      }
    }
  }

  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    final currentState = state;
    if (currentState is! TodosLoaded) return; // Guard clause

    // --- THIS IS YOUR SPECIAL LOGIC ---
    // .trim() removes whitespace from the start and end
    final bool isEmpty = event.newTask.trim().isEmpty;

    if (isEmpty) {
      // --- PATH A: THE TASK IS EMPTY, SO WE DELETE ---

      // 1. Optimistic update (remove from list)
      final updatedList = currentState.todos
          .where((todo) => todo.id != event.id)
          .toList();

      emit(TodosLoaded(todos: updatedList));

      // 2. Call repository
      try {
        await _todoRepository.deleteTodo(event.id);
      } catch (e) {
        emit(
          TodosError(
            'Failed to delete todo (on empty update), rolling back: $e',
          ),
        );
        // 3. Rollback
        emit(currentState);
      }
    } else {
      // --- PATH B: THE TASK IS NOT EMPTY, SO WE UPDATE ---

      // 1. Optimistic update (update item in list)
      final updatedList = currentState.todos.map((todo) {
        if (todo.id == event.id) {
          // Use our copyWith method to return an updated todo
          return todo.copyWith(task: event.newTask);
        }
        return todo;
      }).toList();

      emit(TodosLoaded(todos: updatedList));

      // 2. Call repository
      try {
        // We call updateTodo, which returns the full object
        // We don't need the returned object here, but it's good practice
        await _todoRepository.updateTodo(event.id, event.newTask);
      } catch (e) {
        emit(TodosError('Failed to update todo, rolling back: $e'));
        // 3. Rollback
        emit(currentState);
      }
    }
  }
}
