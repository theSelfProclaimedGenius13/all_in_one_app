import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final int id;
  final String userId;
  final String? title; // Title can be null
  final String content;
  final DateTime createdAt;

  const Note({
    required this.id,
    required this.userId,
    this.title,
    required this.content,
    required this.createdAt,
  });

  // A factory constructor to create a Note from a Map (like from Supabase)
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      title: map['title'] as String?,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // A helper method to make copying objects easier
  Note copyWith({
    int? id,
    String? userId,
    String? title,
    String? content,
    DateTime? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, title, content, createdAt];
}
