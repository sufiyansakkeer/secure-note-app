import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_data_source.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;

  NotesRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Note>>> getNotes() async {
    try {
      final models = await localDataSource.getNotes();
      final notes = models.map((model) => model.toEntity()).toList();
      return Right(notes);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Note>> getNoteById(int id) async {
    try {
      final model = await localDataSource.getNoteById(id);
      return Right(model.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Note>> createNote(Note note) async {
    try {
      final noteModel = NoteModel.fromEntity(note);
      final resultModel = await localDataSource.createNote(noteModel);
      return Right(resultModel.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Note>> updateNote(Note note) async {
    try {
      final noteModel = NoteModel.fromEntity(note);
      final resultModel = await localDataSource.updateNote(noteModel);
      return Right(resultModel.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteNote(int id) async {
    try {
      final result = await localDataSource.deleteNote(id);
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAllNotes() async {
    try {
      final result = await localDataSource.deleteAllNotes();
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }
}
