import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class GetNoteById {
  final NotesRepository repository;

  GetNoteById(this.repository);

  Future<Either<Failure, Note>> call(int id) async {
    return await repository.getNoteById(id);
  }
}
