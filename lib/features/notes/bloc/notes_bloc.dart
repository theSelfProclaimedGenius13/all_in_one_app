import 'package:all_in_one_app/features/notes/bloc/notes_event.dart';
import 'package:all_in_one_app/features/notes/bloc/notes_state.dart';
import 'package:all_in_one_app/features/notes/domain/repositories/notes_repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesRepository _notesRepository;

  NotesBloc({required NotesRepository notesRepository})
    : _notesRepository = notesRepository,
      super(const NotesState()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    emit(state.copyWith(status: NotesStatus.loading));
    try {
      final notes = await _notesRepository.getAllNotes();
      emit(state.copyWith(status: NotesStatus.success, notes: notes));
    } catch (e) {
      emit(
        state.copyWith(status: NotesStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAddNote(AddNote event, Emitter<NotesState> emit) async {
    try {
      // We don't do an optimistic update for 'add'
      // We wait for the DB to give us the new Note with its ID
      emit(state.copyWith(status: NotesStatus.loading));
      final newNote = await _notesRepository.createNote(
        content: event.content,
        title: event.title,
      );
      // Add the new note to the top of the list
      emit(
        state.copyWith(
          status: NotesStatus.success,
          notes: [newNote, ...state.notes],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: NotesStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<NotesState> emit) async {
    // Optimistic update for "edit"
    final previousState = state;
    final updatedList = state.notes.map((note) {
      if (note.id == event.id) {
        return note.copyWith(content: event.content, title: event.title);
      }
      return note;
    }).toList();

    emit(state.copyWith(notes: updatedList)); // Show change instantly

    try {
      // Then, try to sync with the DB
      await _notesRepository.updateNote(
        id: event.id,
        content: event.content,
        title: event.title,
      );
    } catch (e) {
      // If it fails, roll back
      emit(previousState.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    // Optimistic update for "delete"
    final previousState = state;
    final updatedList = state.notes
        .where((note) => note.id != event.id)
        .toList();

    emit(state.copyWith(notes: updatedList)); // Show change instantly

    try {
      // Then, try to sync with the DB
      await _notesRepository.deleteNote(event.id);
    } catch (e) {
      // If it fails, roll back
      emit(previousState.copyWith(errorMessage: e.toString()));
    }
  }
}
