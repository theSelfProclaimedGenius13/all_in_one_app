import 'package:all_in_one_app/features/notes/domain/note.dart';
import 'package:equatable/equatable.dart';

enum NotesStatus { initial, loading, success, failure }

class NotesState extends Equatable {
  final List<Note> notes;
  final NotesStatus status;
  final String? errorMessage; // To show in SnackBars

  const NotesState({
    this.notes = const <Note>[],
    this.status = NotesStatus.initial,
    this.errorMessage,
  });

  NotesState copyWith({
    List<Note>? notes,
    NotesStatus? status,
    String? errorMessage,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      status: status ?? this.status,
      errorMessage: errorMessage, // Don't carry over old errors
    );
  }

  @override
  List<Object?> get props => [notes, status, errorMessage];
}
