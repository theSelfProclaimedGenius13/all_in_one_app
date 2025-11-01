// lib/to_do/bloc/todo_bloc.dart

import 'package:all_in_one_app/features/to_do/bloc/todo_event.dart';
import 'package:all_in_one_app/features/to_do/bloc/todo_state.dart';

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
      super(const TodoState()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<ToggleTodo>(_onToggleTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<ChangeFilter>(_onChangeFilter);
  }

  void _onChangeFilter(ChangeFilter event, Emitter<TodoState> emit) {
    // Just emit a new state with the new filter
    emit(state.copyWith(filter: event.filter));
  }

  // The event handler function for 'LoadTodos'
  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    // 1. Emit the loading state to show a spinner in the UI
    emit(state.copyWith(status: TodoStatus.loading));

    try {
      // 7. This is the new part!
      //    We call the REPOSITORY, not Supabase directly
      final todos = await _todoRepository.getTodos();

      // 8. Emit the success state with the real data
      emit(state.copyWith(status: TodoStatus.success, allTodos: todos));
    } catch (e) {
      // 4. If anything goes wrong, emit the error state
      emit(
        state.copyWith(status: TodoStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  // --- REFACTORED ---
  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    // We can add a todo even if the list is loading
    try {
      final newTodo = await _todoRepository.addTodo(
        task: event.task,
        title: event.title,
      );
      // Create a new list with the new todo at the top
      final updatedList = [newTodo, ...state.allTodos];
      // Emit 'success' status with the new list
      emit(state.copyWith(status: TodoStatus.success, allTodos: updatedList));
    } catch (e) {
      // Emit 'failure' and show an error
      emit(
        state.copyWith(status: TodoStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onToggleTodo(ToggleTodo event, Emitter<TodoState> emit) async {
    // Save the previous state for rollback
    final previousState = state;

    // Optimistic update
    final updatedList = state.allTodos.map((todo) {
      if (todo.id == event.id) {
        return todo.copyWith(isComplete: event.isComplete);
      }
      return todo;
    }).toList();

    // Emit the new list immediately
    emit(state.copyWith(allTodos: updatedList));

    try {
      await _todoRepository.toggleTodo(event.id, event.isComplete);
    } catch (e) {
      // If it fails, emit the *previous* state with a new error message
      emit(
        previousState.copyWith(
          status: TodoStatus.failure,
          errorMessage: 'Failed to update. Check connection.',
        ),
      );
    }
  }

  // --- REFACTORED ---
  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    // Save the previous state for rollback
    final previousState = state;

    // Optimistic update
    final updatedList = state.allTodos
        .where((todo) => todo.id != event.id)
        .toList();

    // Emit the new list immediately
    emit(state.copyWith(allTodos: updatedList));

    try {
      await _todoRepository.deleteTodo(event.id);
    } catch (e) {
      // If it fails, roll back
      emit(
        previousState.copyWith(
          status: TodoStatus.failure,
          errorMessage: 'Failed to delete. Check connection.',
        ),
      );
    }
  }

  // --- REFACTORED ---
  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    // Save the previous state for rollback
    final previousState = state;

    final bool isEmpty = event.task.trim().isEmpty;

    if (isEmpty) {
      // --- DELETE PATH ---
      final updatedList = state.allTodos
          .where((todo) => todo.id != event.id)
          .toList();
      emit(state.copyWith(allTodos: updatedList)); // Optimistic update
      try {
        await _todoRepository.deleteTodo(event.id);
      } catch (e) {
        // Rollback
        emit(
          previousState.copyWith(
            status: TodoStatus.failure,
            errorMessage: 'Failed to delete. Check connection.',
          ),
        );
      }
    } else {
      // --- UPDATE PATH ---
      final updatedList = state.allTodos.map((todo) {
        if (todo.id == event.id) {
          return todo.copyWith(task: event.task, title: event.title);
        }
        return todo;
      }).toList();
      emit(state.copyWith(allTodos: updatedList)); // Optimistic update
      try {
        await _todoRepository.updateTodo(
          id: event.id,
          task: event.task,
          title: event.title,
        );
      } catch (e) {
        // Rollback
        emit(
          previousState.copyWith(
            status: TodoStatus.failure,
            errorMessage: 'Failed to update. Check connection.',
          ),
        );
      }
    }
  }
}
