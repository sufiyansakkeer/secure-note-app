import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/note.dart';

abstract class NotesRepository {
  /// Get all notes
  Future<Either<Failure, List<Note>>> getNotes();
  
  /// Get a specific note by ID
  Future<Either<Failure, Note>> getNoteById(int id);
  
  /// Create a new note
  Future<Either<Failure, Note>> createNote(Note note);
  
  /// Update an existing note
  Future<Either<Failure, Note>> updateNote(Note note);
  
  /// Delete a note by ID
  Future<Either<Failure, bool>> deleteNote(int id);
  
  /// Delete all notes (used when resetting the app)
  Future<Either<Failure, bool>> deleteAllNotes();
}
