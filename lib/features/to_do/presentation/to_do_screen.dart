import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:all_in_one_app/app/widgets/empty_state_widget.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../domain/todo.dart';

class ToDoScreen extends StatelessWidget {
  const ToDoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do List'),
        // We'll add the filter buttons at the bottom of the AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            // --- 1. THIS IS THE NEW FILTER WIDGET ---
            child: _BuildFilterButtons(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // --- 2. UPDATED a new dialog function ---
          _showAddEditTodoDialog(context);
        },
        child: const Icon(Icons.add),
      ),

      // --- 3. UPDATED BlocConsumer ---
      body: BlocConsumer<TodoBloc, TodoState>(
        // --- 4. UPDATED LISTENER ---
        listener: (context, state) {
          // Listen for the 'failure' status
          if (state.status == TodoStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        // --- 5. UPDATED BUILDER ---
        builder: (context, state) {
          // --- Loading State ---
          if (state.status == TodoStatus.loading && state.allTodos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Empty State ---
          // Use the FILTERED list to check for empty
          if (state.filteredTodos.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.check_circle_outline,
              message: 'No to-dos in this filter.',
            );
          }

          // --- Success State (Show the list) ---
          // Use the FILTERED list to build the ListView
          final todos = state.filteredTodos;
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return Dismissible(
                key: Key(todo.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(color: Colors.transparent),
                secondaryBackground: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  context.read<TodoBloc>().add(DeleteTodo(todo.id));
                },
                child: ListTile(
                  title: Text(
                    todo.title ?? todo.task,
                  ), // Show title if it exists
                  subtitle: todo.title != null ? Text(todo.task) : null,
                  leading: Checkbox(
                    value: todo.isComplete,
                    onChanged: (bool? newValue) {
                      if (newValue != null) {
                        context.read<TodoBloc>().add(
                          ToggleTodo(id: todo.id, isComplete: newValue),
                        );
                      }
                    },
                  ),
                  onTap: () {
                    // --- 6. UPDATED the dialog call ---
                    _showAddEditTodoDialog(context, todoToEdit: todo);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- 7. A NEW, COMBINED DIALOG FUNCTION ---
  // This handles BOTH adding and editing
  void _showAddEditTodoDialog(BuildContext context, {Todo? todoToEdit}) {
    final bool isEditing = todoToEdit != null;
    final titleController = TextEditingController(text: todoToEdit?.title);
    final taskController = TextEditingController(text: todoToEdit?.task);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit To-Do' : 'Add To-Do'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Title (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: taskController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Task description',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final String task = taskController.text;
                final String? title = titleController.text.isEmpty
                    ? null
                    : titleController.text;

                if (task.isEmpty && !isEditing) {
                  // Don't add an empty task
                  Navigator.pop(dialogContext);
                  return;
                }

                if (isEditing) {
                  // --- 8. UPDATED 'UpdateTodo' event ---
                  context.read<TodoBloc>().add(
                    UpdateTodo(
                      id: todoToEdit.id,
                      task: task, // Use 'task'
                      title: title,
                    ),
                  );
                } else {
                  // --- 9. UPDATED 'AddTodo' event ---
                  context.read<TodoBloc>().add(
                    AddTodo(
                      task: task, // Use 'task'
                      title: title,
                    ),
                  );
                }
                Navigator.pop(dialogContext);
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }
}

// --- 10. THE NEW FILTER WIDGET ---
class _BuildFilterButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use a BlocSelector to only rebuild when the *filter* changes
    final currentFilter = context.select((TodoBloc bloc) => bloc.state.filter);

    return SegmentedButton<TodoFilter>(
      // The currently selected filter
      selected: {currentFilter},
      // This is called when a new segment is tapped
      onSelectionChanged: (Set<TodoFilter> newFilter) {
        // Send the event to the BLoC
        context.read<TodoBloc>().add(ChangeFilter(newFilter.first));
      },
      segments: const [
        // The three filter options
        ButtonSegment(
          value: TodoFilter.all,
          label: Text('All'),
          icon: Icon(Icons.list),
        ),
        ButtonSegment(
          value: TodoFilter.active,
          label: Text('Active'),
          icon: Icon(Icons.check_box_outline_blank),
        ),
        ButtonSegment(
          value: TodoFilter.completed,
          label: Text('Done'),
          icon: Icon(Icons.check_box),
        ),
      ],
    );
  }
}
