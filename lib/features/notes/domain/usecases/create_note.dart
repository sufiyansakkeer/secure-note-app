import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class CreateNote {
  final NotesRepository repository;

  CreateNote(this.repository);

  Future<Either<Failure, Note>> call(Note note) async {
    return await repository.createNote(note);
  }
}
