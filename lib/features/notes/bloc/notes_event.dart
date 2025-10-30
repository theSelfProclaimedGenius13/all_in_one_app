import 'package:equatable/equatable.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();
  @override
  List<Object?> get props => [];
}

// Load all notes
class LoadNotes extends NotesEvent {}

// Create a new note
class AddNote extends NotesEvent {
  final String content;
  final String? title;
  const AddNote({required this.content, this.title});
  @override
  List<Object?> get props => [content, title];
}

// Update an existing note
class UpdateNote extends NotesEvent {
  final int id;
  final String content;
  final String? title;
  const UpdateNote({required this.id, required this.content, this.title});
  @override
  List<Object?> get props => [id, content, title];
}

// Delete a note
class DeleteNote extends NotesEvent {
  final int id;
  const DeleteNote(this.id);
  @override
  List<Object> get props => [id];
}
