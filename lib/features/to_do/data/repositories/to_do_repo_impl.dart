import '../../domain/repositories/to_do_repository.dart';
import '../../domain/todo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TodoRepositoryImpl implements TodoRepository {
  // Get the Supabase client
  final SupabaseClient supabaseClient = Supabase.instance.client;

  @override
  Future<List<Todo>> getTodos() async {
    try {
      // 1. Call your Supabase table (I'm assuming it's named 'todos')
      //    This returns a List<Map<String, dynamic>>
      final data = await supabaseClient
          .from(
            'todos',
          ) // ⚠️ IMPORTANT: Change 'todos' if your table name is different
          .select()
          .order('id', ascending: true);

      // 2. Convert that list of maps into a list of Todo objects
      final todos = data.map((item) => Todo.fromMap(item)).toList();

      return todos;
    } catch (e) {
      // 3. If anything goes wrong, throw an exception
      throw Exception('Error fetching todos: $e');
    }
  }

  @override
  Future<Todo> addTodo(String task) async {
    try {
      // 1. Get the current user's ID (crucial for row-level security)
      final userId = supabaseClient.auth.currentUser!.id;

      // 2. Insert the new row and tell Supabase to return it
      final data = await supabaseClient
          .from('todos') // Your table name
          .insert({
            'task': task,
            'user_id': userId,
            'is_complete': false, // You can set defaults here or in Supabase
          })
          .select() // <-- Asks Supabase to return the row it just created
          .single(); // <-- Specifies we only expect ONE row back

      // 3. Convert the returned Map into a Todo object
      return Todo.fromMap(data);
    } catch (e) {
      throw Exception('Error adding todo: $e');
    }
  }

  @override
  Future<void> toggleTodo(int id, bool isComplete) async {
    try {
      // Get the user ID for security
      final userId = supabaseClient.auth.currentUser!.id;

      await supabaseClient
          .from('todos') // Your table name
          .update({'is_complete': isComplete}) // Set the new value
          .eq('id', id) // Where the ID matches
          .eq('user_id', userId); // AND it belongs to the current user
    } catch (e) {
      throw Exception('Error toggling todo: $e');
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    try {
      // Get the user ID for security
      final userId = supabaseClient.auth.currentUser!.id;

      await supabaseClient
          .from('todos') // Your table name
          .delete()
          .eq('id', id) // Where the ID matches
          .eq('user_id', userId); // AND it belongs to the current user
    } catch (e) {
      throw Exception('Error deleting todo: $e');
    }
  }

  @override
  Future<Todo> updateTodo(int id, String task) async {
    try {
      // Get the user ID for security
      final userId = supabaseClient.auth.currentUser!.id;

      final data = await supabaseClient
          .from('todos') // Your table name
          .update({'task': task}) // Set the new task text
          .eq('id', id) // Where the ID matches
          .eq('user_id', userId) // AND it belongs to the current user
          .select() // <-- Ask Supabase to return the row
          .single(); // <-- Specifies we only expect ONE row back

      // Convert the returned Map into a Todo object
      return Todo.fromMap(data);
    } catch (e) {
      throw Exception('Error updating todo: $e');
    }
  }
}
