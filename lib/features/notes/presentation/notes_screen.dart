import 'package:all_in_one_app/features/notes/bloc/notes_bloc.dart';
import 'package:all_in_one_app/features/notes/bloc/notes_event.dart';
import 'package:all_in_one_app/features/notes/bloc/notes_state.dart';
import 'package:all_in_one_app/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:all_in_one_app/features/notes/domain/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotesBloc(
        // We provide the repository implementation here
        notesRepository: NotesRepositoryImpl(),
      )..add(LoadNotes()), // <-- Immediately tell the BLoC to load the notes
      child: const _NotesView(),
    );
  }
}

/// --- 2. The View Widget (Builds the UI) ---
class _NotesView extends StatelessWidget {
  const _NotesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- 3. Floating Action Button to Add Notes ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the 'add' screen
          // We'll create this route in the next step
          context.goNamed('add_note');
        },
        child: const Icon(Icons.add),
      ),

      // --- 4. BlocConsumer to handle states ---
      // It's a BlocBuilder + BlocListener
      body: BlocConsumer<NotesBloc, NotesState>(
        // --- 5. The LISTENER (for SnackBars) ---
        listener: (context, state) {
          if (state.status == NotesStatus.failure) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },

        // --- 6. The BUILDER (for the UI) ---
        builder: (context, state) {
          // --- Loading State ---
          if (state.status == NotesStatus.loading && state.notes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Empty State ---
          if (state.notes.isEmpty) {
            return const Center(
              child: Text(
                'No notes yet. Tap + to add one!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // --- Success State (Show the list) ---
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: state.notes.length,
            itemBuilder: (context, index) {
              final note = state.notes[index];
              return _NoteCard(note: note); // We'll make this helper
            },
          );
        },
      ),
    );
  }
}

/// --- 7. A Helper Widget for the Note Card ---
class _NoteCard extends StatelessWidget {
  final Note note;
  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        title: Text(
          note.title ?? 'Untitled Note',
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          note.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          // Navigate to the 'edit' screen, passing the note's ID
          // We'll create this route in the next step
          context.goNamed(
            'edit_note',
            pathParameters: {'id': note.id.toString()},
          );
        },
      ),
    );
  }
}
