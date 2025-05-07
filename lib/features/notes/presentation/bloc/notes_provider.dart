import 'package:flutter/material.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/create_note.dart';
import '../../domain/usecases/delete_all_notes.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_note_by_id.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/update_note.dart';

enum NotesStatus {
  initial,
  loading,
  loaded,
  error,
}

class NotesProvider with ChangeNotifier {
  final GetNotes getNotes;
  final GetNoteById getNoteById;
  final CreateNote createNote;
  final UpdateNote updateNote;
  final DeleteNote deleteNote;
  final DeleteAllNotes deleteAllNotes;

  NotesStatus _status = NotesStatus.initial;
  List<Note> _notes = [];
  Note? _selectedNote;
  String _errorMessage = '';

  NotesStatus get status => _status;
  List<Note> get notes => _notes;
  Note? get selectedNote => _selectedNote;
  String get errorMessage => _errorMessage;

  NotesProvider({
    required this.getNotes,
    required this.getNoteById,
    required this.createNote,
    required this.updateNote,
    required this.deleteNote,
    required this.deleteAllNotes,
  });

  Future<void> loadNotes() async {
    _status = NotesStatus.loading;
    notifyListeners();

    final result = await getNotes();
    
    result.fold(
      (failure) {
        _status = NotesStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (notes) {
        _notes = notes;
        _status = NotesStatus.loaded;
        notifyListeners();
      },
    );
  }

  Future<void> loadNoteById(int id) async {
    _status = NotesStatus.loading;
    notifyListeners();

    final result = await getNoteById(id);
    
    result.fold(
      (failure) {
        _status = NotesStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (note) {
        _selectedNote = note;
        _status = NotesStatus.loaded;
        notifyListeners();
      },
    );
  }

  Future<bool> addNote(String title, String content) async {
    _status = NotesStatus.loading;
    notifyListeners();

    final now = DateTime.now();
    final note = Note(
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );

    final result = await createNote(note);
    
    return result.fold(
      (failure) {
        _status = NotesStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (createdNote) {
        _notes.insert(0, createdNote);
        _status = NotesStatus.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> editNote(int id, String title, String content) async {
    _status = NotesStatus.loading;
    notifyListeners();

    final noteToUpdate = _notes.firstWhere((note) => note.id == id);
    final updatedNote = Note(
      id: id,
      title: title,
      content: content,
      createdAt: noteToUpdate.createdAt,
      updatedAt: DateTime.now(),
    );

    final result = await updateNote(updatedNote);
    
    return result.fold(
      (failure) {
        _status = NotesStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (updatedNote) {
        final index = _notes.indexWhere((note) => note.id == id);
        if (index != -1) {
          _notes[index] = updatedNote;
        }
        _selectedNote = updatedNote;
        _status = NotesStatus.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> removeNote(int id) async {
    _status = NotesStatus.loading;
    notifyListeners();

    final result = await deleteNote(id);
    
    return result.fold(
      (failure) {
        _status = NotesStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (success) {
        if (success) {
          _notes.removeWhere((note) => note.id == id);
          if (_selectedNote?.id == id) {
            _selectedNote = null;
          }
          _status = NotesStatus.loaded;
          notifyListeners();
          return true;
        } else {
          _status = NotesStatus.error;
          _errorMessage = 'Failed to delete note';
          notifyListeners();
          return false;
        }
      },
    );
  }

  Future<bool> clearAllNotes() async {
    _status = NotesStatus.loading;
    notifyListeners();

    final result = await deleteAllNotes();
    
    return result.fold(
      (failure) {
        _status = NotesStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (success) {
        if (success) {
          _notes = [];
          _selectedNote = null;
          _status = NotesStatus.loaded;
          notifyListeners();
          return true;
        } else {
          _status = NotesStatus.error;
          _errorMessage = 'Failed to clear all notes';
          notifyListeners();
          return false;
        }
      },
    );
  }

  void clearSelectedNote() {
    _selectedNote = null;
    notifyListeners();
  }
}
