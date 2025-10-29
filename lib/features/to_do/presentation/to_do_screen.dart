import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../domain/todo.dart';

class ToDoScreen extends StatelessWidget {
  const ToDoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My To-Do List')),
      // 1. Wrap your main UI in a BlocBuilder
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          // 2. Handle the LOADING state
          if (state is TodosLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 3. Handle the LOADED state
          if (state is TodosLoaded) {
            final List<Todo> todos = state.todos; // Get the list from the state

            if (todos.isEmpty) {
              return const Center(child: Text('No to-dos yet. Add one!'));
            }

            // Display the list
            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  title: Text(todo.task),
                  leading: Checkbox(
                    value: todo.isComplete,
                    onChanged: (bool? newValue) {
                      // Ensure the new value isn't null
                      if (newValue != null) {
                        // Find the BLoC and add the ToggleTodo event
                        context.read<TodoBloc>().add(
                          ToggleTodo(id: todo.id, isComplete: newValue),
                        );
                      }
                    },
                  ),
                );
              },
            );
          }

          // 4. Handle the ERROR state
          if (state is TodosError) {
            return Center(
              child: Text(
                'Failed to load todos: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // 5. Fallback for any other state
          return const Center(child: Text('Something went wrong!'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add AddTodo event
          _showAddTodoDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    // We create a controller here, specific to this dialog
    final TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add New To-Do'),
          content: TextField(
            controller: taskController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'What needs to be done?',
            ),
          ),
          actions: [
            // "Cancel" button
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close the dialog
              },
              child: const Text('Cancel'),
            ),

            // "Add" button
            TextButton(
              onPressed: () {
                final task = taskController.text;
                if (task.isNotEmpty) {
                  // This is the key line:
                  // 1. Find the TodoBloc
                  // 2. Add the AddTodo event with the task text
                  context.read<TodoBloc>().add(AddTodo(task));

                  Navigator.pop(dialogContext); // Close the dialog
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
