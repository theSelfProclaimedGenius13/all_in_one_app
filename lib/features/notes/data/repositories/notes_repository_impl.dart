import 'package:all_in_one_app/features/notes/domain/note.dart';
import 'package:all_in_one_app/features/notes/domain/repositories/notes_repositories.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesRepositoryImpl implements NotesRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'notes';

  // Helper to get the current user ID
  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<Note>> getAllNotes() async {
    try {
      final data = await _client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      return data.map((item) => Note.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Error fetching notes: $e');
    }
  }

  @override
  Future<Note> createNote({required String content, String? title}) async {
    try {
      final data = await _client
          .from(_tableName)
          .insert({'user_id': _userId, 'title': title, 'content': content})
          .select()
          .single();

      return Note.fromMap(data);
    } catch (e) {
      throw Exception('Error creating note: $e');
    }
  }

  @override
  Future<Note> updateNote({
    required int id,
    required String content,
    String? title,
  }) async {
    try {
      final data = await _client
          .from(_tableName)
          .update({'title': title, 'content': content})
          .eq('id', id)
          .eq('user_id', _userId) // Ensure they can only update their own
          .select()
          .single();

      return Note.fromMap(data);
    } catch (e) {
      throw Exception('Error updating note: $e');
    }
  }

  @override
  Future<void> deleteNote(int id) async {
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', id)
          .eq('user_id', _userId); // Ensure they can only delete their own
    } catch (e) {
      throw Exception('Error deleting note: $e');
    }
  }
}
