import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notes_repository.dart';

class DeleteAllNotes {
  final NotesRepository repository;

  DeleteAllNotes(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.deleteAllNotes();
  }
}
