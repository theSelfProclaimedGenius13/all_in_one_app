import 'package:all_in_one_app/features/notes/bloc/notes_bloc.dart';
import 'package:all_in_one_app/features/notes/bloc/notes_event.dart';
import 'package:all_in_one_app/features/notes/domain/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddEditNoteScreen extends StatefulWidget {
  // This screen can be used for 'add' (id is null) or 'edit' (id is provided)
  final String? noteId;

  const AddEditNoteScreen({super.key, this.noteId});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  // Controllers to manage the text fields
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // A variable to hold the note we are editing, if any
  Note? _editingNote;

  // A check to see if we are in "edit mode"
  bool get _isEditing => widget.noteId != null;

  @override
  void initState() {
    super.initState();

    // If we are in "edit mode" (noteId was passed)
    if (_isEditing) {
      // Find the note from the BLoC's current state
      final noteId = int.parse(widget.noteId!);
      final currentState = context.read<NotesBloc>().state;

      // This is a safe way to find the note.
      try {
        _editingNote = currentState.notes.firstWhere(
          (note) => note.id == noteId,
        );
      } catch (e) {
        _editingNote = null; // This should never happen, but it's safe
      }

      // If we found the note, fill the text fields
      if (_editingNote != null) {
        _titleController.text = _editingNote!.title ?? '';
        _contentController.text = _editingNote!.content;
      }
    }
  }

  @override
  void dispose() {
    // Clean up the controllers
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// --- Helper function for the "Save" button ---
  void _onSave() {
    // Basic validation
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note content cannot be empty.')),
      );
      return;
    }

    if (_isEditing) {
      // --- Update Existing Note ---
      context.read<NotesBloc>().add(
        UpdateNote(
          id: _editingNote!.id,
          content: _contentController.text,
          title: _titleController.text,
        ),
      );
    } else {
      // --- Add New Note ---
      context.read<NotesBloc>().add(
        AddNote(content: _contentController.text, title: _titleController.text),
      );
    }

    // Go back to the previous screen
    context.pop();
  }

  /// --- Helper function for the "Delete" button ---
  void _onDelete() {
    if (_isEditing) {
      context.read<NotesBloc>().add(DeleteNote(_editingNote!.id));
      // Pop twice to go all the way back to the list
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'Add Note'),
        actions: [
          // --- Show Delete Button only in Edit Mode ---
          if (_isEditing)
            IconButton(icon: const Icon(Icons.delete), onPressed: _onDelete),

          // --- The Save Button ---
          IconButton(icon: const Icon(Icons.save), onPressed: _onSave),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Title Field ---
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            // --- Content Field ---
            Expanded(
              child: TextField(
                controller: _contentController,
                autofocus: true,
                // Automatically open the keyboard
                maxLines: null,
                // Allows unlimited lines
                expands: true,
                // Fills the available space
                decoration: const InputDecoration(
                  hintText: 'Start writing...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
