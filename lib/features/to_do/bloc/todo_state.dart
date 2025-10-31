import 'package:all_in_one_app/features/to_do/bloc/todo_event.dart';
import 'package:equatable/equatable.dart';

import '../domain/todo.dart';

enum TodoStatus { initial, loading, success, failure }

class TodoState extends Equatable {
  // 1. The master list of all to-dos
  final List<Todo> allTodos;

  // 2. The current active filter
  final TodoFilter filter;

  // 3. The current status of the BLoC
  final TodoStatus status;

  // 4. Any error message
  final String? errorMessage;

  const TodoState({
    this.allTodos = const <Todo>[],
    this.filter = TodoFilter.all,
    this.status = TodoStatus.initial,
    this.errorMessage,
  });

  // 5. THE GETTER: This is the magic!
  // The UI will call this to get the list it should display.
  List<Todo> get filteredTodos {
    switch (filter) {
      case TodoFilter.active:
        return allTodos.where((todo) => !todo.isComplete).toList();
      case TodoFilter.completed:
        return allTodos.where((todo) => todo.isComplete).toList();
      case TodoFilter.all:
      default:
        return allTodos;
    }
  }

  // 6. The copyWith method
  TodoState copyWith({
    List<Todo>? allTodos,
    TodoFilter? filter,
    TodoStatus? status,
    String? errorMessage,
  }) {
    return TodoState(
      allTodos: allTodos ?? this.allTodos,
      filter: filter ?? this.filter,
      status: status ?? this.status,
      errorMessage: errorMessage, // Don't carry over old errors
    );
  }

  @override
  List<Object?> get props => [allTodos, filter, status, errorMessage];
}
