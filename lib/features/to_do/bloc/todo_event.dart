import 'package:equatable/equatable.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class ChangeFilter extends TodoEvent {
  final TodoFilter filter;

  const ChangeFilter(this.filter);

  @override
  List<Object> get props => [filter];
}

// 1. LoadTodos: Triggered when we need to load the to-do list
class LoadTodos extends TodoEvent {}

// --- ADD THIS CLASS ---
class AddTodo extends TodoEvent {
  final String task;
  final String? title;

  const AddTodo({required this.task, this.title});

  @override
  List<Object?> get props => [task, title];
}

class ToggleTodo extends TodoEvent {
  final int id;
  final bool isComplete; // The new value

  const ToggleTodo({required this.id, required this.isComplete});

  @override
  List<Object> get props => [id, isComplete];
}

class DeleteTodo extends TodoEvent {
  final int id;

  const DeleteTodo(this.id);

  @override
  List<Object> get props => [id];
}

class UpdateTodo extends TodoEvent {
  final int id;
  final String task;
  final String? title;

  const UpdateTodo({required this.id, required this.task, this.title});

  @override
  List<Object?> get props => [id, task, title];
}

enum TodoFilter { all, active, completed }
