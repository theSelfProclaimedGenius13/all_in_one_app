import 'package:all_in_one_app/features/notes/domain/note.dart';

abstract class NotesRepository {
  Future<List<Note>> getAllNotes();
  Future<Note> createNote({required String content, String? title});
  Future<Note> updateNote({
    required int id,
    required String content,
    String? title,
  });
  Future<void> deleteNote(int id);
}
