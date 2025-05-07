import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class GetNotes {
  final NotesRepository repository;

  GetNotes(this.repository);

  Future<Either<Failure, List<Note>>> call() async {
    return await repository.getNotes();
  }
}
