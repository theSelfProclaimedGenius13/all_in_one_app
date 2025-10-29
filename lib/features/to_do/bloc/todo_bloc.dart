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
        print('Failed to toggle todo, rolling back: $e');
        // Re-emit the *original* state to undo the change in the UI
        emit(currentState);
      }
    }
  }
}
