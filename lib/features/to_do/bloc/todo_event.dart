import 'package:equatable/equatable.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object> get props => [];
}

// 1. LoadTodos: Triggered when we need to load the to-do list
class LoadTodos extends TodoEvent {}

// --- ADD THIS CLASS ---
class AddTodo extends TodoEvent {
  final String task;

  const AddTodo(this.task);

  @override
  List<Object> get props => [task];
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
  final String newTask;

  const UpdateTodo({required this.id, required this.newTask});

  @override
  List<Object> get props => [id, newTask];
}
