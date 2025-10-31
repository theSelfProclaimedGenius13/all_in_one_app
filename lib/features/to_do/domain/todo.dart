// lib/models/todo.dart

import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final int id;
  final String task;
  final bool isComplete;
  final String userId; // To know who this todo belongs toD
  final String? title;

  const Todo({
    required this.id,
    required this.task,
    this.isComplete = false,
    required this.userId,
    this.title,
  });

  // A factory constructor to create a Todo from a Map (like from Supabase)
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int,
      task: map['task'] as String,
      isComplete: map['is_complete'] as bool,
      userId: map['user_id'] as String,
      title: map['title'] as String?,
    );
  }

  // A method to convert a Todo object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task': task,
      'is_complete': isComplete,
      'user_id': userId,
      'title': title,
    };
  }

  Todo copyWith({
    int? id,
    String? task,
    bool? isComplete,
    String? userId,
    String? title,
  }) {
    return Todo(
      id: id ?? this.id,
      task: task ?? this.task,
      isComplete: isComplete ?? this.isComplete,
      userId: userId ?? this.userId,
      title: title ?? this.title,
    );
  }

  @override
  List<Object?> get props => [id, task, isComplete, userId, title];
}
