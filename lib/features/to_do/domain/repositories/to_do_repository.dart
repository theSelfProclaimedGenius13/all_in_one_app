import '../todo.dart';

abstract class TodoRepository {
  // This is the contract: any "TodoRepository" MUST have this function
  Future<List<Todo>> getTodos();

  // It takes the task string and returns the complete Todo object
  Future<Todo> addTodo({required String task, String? title});

  Future<void> toggleTodo(int id, bool isComplete);

  Future<void> deleteTodo(int id);

  Future<Todo> updateTodo({
    required int id,
    required String task,
    String? title,
  });
  // We'll add more here later, like:
  // Future<void> addTodo(String task);
  // Future<void> toggleTodo(int id, bool isComplete);
}
