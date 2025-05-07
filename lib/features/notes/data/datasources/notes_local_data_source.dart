import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/note_model_adapter.dart';
import '../models/note_model.dart';

abstract class NotesLocalDataSource {
  Future<List<NoteModel>> getNotes();
  Future<NoteModel> getNoteById(int id);
  Future<NoteModel> createNote(NoteModel note);
  Future<NoteModel> updateNote(NoteModel note);
  Future<bool> deleteNote(int id);
  Future<bool> deleteAllNotes();
  Future<void> initDatabase();
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  Box<NoteModel>? _notesBox;

  Future<Box<NoteModel>> get notesBox async {
    if (_notesBox != null && _notesBox!.isOpen) return _notesBox!;
    await initDatabase();
    return _notesBox!;
  }

  @override
  Future<void> initDatabase() async {
    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Register the adapter if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        // Using 0 as the typeId for NoteModel
        Hive.registerAdapter(NoteModelAdapter());
      }

      // Open the box
      _notesBox = await Hive.openBox<NoteModel>('notes_box');
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to initialize Hive database: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<NoteModel>> getNotes() async {
    try {
      final box = await notesBox;
      final notes = box.values.toList();

      // Sort by updatedAt in descending order
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return notes;
    } catch (e) {
      throw DatabaseException(message: 'Failed to get notes: ${e.toString()}');
    }
  }

  @override
  Future<NoteModel> getNoteById(int id) async {
    try {
      final box = await notesBox;
      final note = box.get(id);

      if (note == null) {
        throw DatabaseException(message: 'Note not found');
      }

      return note;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get note by ID: ${e.toString()}',
      );
    }
  }

  @override
  Future<NoteModel> createNote(NoteModel note) async {
    try {
      final box = await notesBox;

      // Generate a new ID that stays within the 32-bit integer range (0 - 0xFFFFFFFF)
      // Use a combination of current seconds since epoch (smaller than milliseconds)
      // and a random component to ensure uniqueness
      final timestamp = DateTime.now().second;
      final random =
          DateTime.now().millisecond * 1000 + DateTime.now().microsecond % 1000;

      // Combine them to create a unique ID within the valid range
      // This will create an ID like: SSRRRRR (S=seconds, R=random component)
      // which will be well within the 32-bit limit
      final id = (timestamp * 100000 + random) % 0xFFFFFFFF;

      final newNote = NoteModel(
        id: id,
        title: note.title,
        content: note.content,
        createdAt: note.createdAt,
        updatedAt: note.updatedAt,
      );

      // Save the note with the ID as the key
      await box.put(id, newNote);

      return newNote;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to create note: ${e.toString()}',
      );
    }
  }

  @override
  Future<NoteModel> updateNote(NoteModel note) async {
    try {
      final box = await notesBox;

      if (note.id == null) {
        throw DatabaseException(message: 'Cannot update note without ID');
      }

      // Check if the note exists
      if (!box.containsKey(note.id)) {
        throw DatabaseException(message: 'Note not found');
      }

      // Save the updated note
      await box.put(note.id, note);

      return note;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to update note: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> deleteNote(int id) async {
    try {
      final box = await notesBox;

      // Check if the note exists
      if (!box.containsKey(id)) {
        return false;
      }

      // Delete the note
      await box.delete(id);

      return true;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to delete note: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> deleteAllNotes() async {
    try {
      final box = await notesBox;

      // Clear all notes
      await box.clear();

      return true;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to delete all notes: ${e.toString()}',
      );
    }
  }
}
