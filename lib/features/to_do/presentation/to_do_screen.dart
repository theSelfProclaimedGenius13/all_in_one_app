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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            // The filter buttons
            child: _BuildFilterButtons(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // The combined add/edit dialog
          _showAddEditTodoDialog(context);
        },
        child: const Icon(Icons.add),
      ),

      // We use BlocConsumer to build the UI and listen for errors
      body: BlocConsumer<TodoBloc, TodoState>(
        listener: (context, state) {
          // Listen for the 'failure' status to show SnackBars
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
        builder: (context, state) {
          // --- Loading State ---
          if (state.status == TodoStatus.loading && state.allTodos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Empty State (All Todos) ---
          if (state.allTodos.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.check_circle_outline,
              message: 'No to-dos yet. Tap + to add one!',
            );
          }

          // --- Empty State (Filtered) ---
          if (state.filteredTodos.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.filter_list_off,
              message: 'No to-dos in this filter.',
            );
          }

          // --- Success State (Show the list) ---
          // We get the list *from the state* every time. No local list.
          final todos = state.filteredTodos;

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];

              // We can use the simple, reliable Dismissible widget
              return Dismissible(
                key: Key(todo.id.toString()), // Unique key
                direction: DismissDirection.endToStart,
                background: Container(color: Colors.transparent),
                secondaryBackground: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  // Fire the event, the BLoC handles the logic
                  context.read<TodoBloc>().add(DeleteTodo(todo.id));
                },
                child: ListTile(
                  title: Text(todo.title ?? todo.task),
                  subtitle: todo.title != null ? Text(todo.task) : null,
                  leading: Checkbox(
                    value: todo.isComplete,
                    onChanged: (bool? newValue) {
                      // Fire the event, the BLoC handles the logic
                      if (newValue != null) {
                        context.read<TodoBloc>().add(
                          ToggleTodo(id: todo.id, isComplete: newValue),
                        );
                      }
                    },
                  ),
                  onTap: () {
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

  // --- This is the combined Add/Edit dialog function ---
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
                  Navigator.pop(dialogContext);
                  return;
                }

                if (isEditing) {
                  context.read<TodoBloc>().add(
                    UpdateTodo(id: todoToEdit.id, task: task, title: title),
                  );
                } else {
                  context.read<TodoBloc>().add(
                    AddTodo(task: task, title: title),
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

// --- This is the filter button widget (unchanged) ---
class _BuildFilterButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use a BlocSelector to only rebuild when the *filter* changes
    final currentFilter = context.select((TodoBloc bloc) => bloc.state.filter);

    return SegmentedButton<TodoFilter>(
      selected: {currentFilter},
      onSelectionChanged: (Set<TodoFilter> newFilter) {
        context.read<TodoBloc>().add(ChangeFilter(newFilter.first));
      },
      segments: const [
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
