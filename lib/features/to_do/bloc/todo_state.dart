import 'package:equatable/equatable.dart';

import '../domain/todo.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object> get props => [];
}

// 1. TodosLoading: The initial state, tells the UI to show a spinner
class TodosLoading extends TodoState {}

// 2. TodosLoaded: The success state, gives the UI the list of to-dos
class TodosLoaded extends TodoState {
  final List<Todo> todos; // We assume you have a 'Todo' model

  const TodosLoaded({this.todos = const <Todo>[]});

  @override
  List<Object> get props => [todos];
}

// 3. TodosError: The failure state, gives the UI an error message
class TodosError extends TodoState {
  final String message;

  const TodosError(this.message);

  @override
  List<Object> get props => [message];
}
