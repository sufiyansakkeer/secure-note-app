import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ResetApp {
  final AuthRepository repository;

  ResetApp(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.resetApp();
  }
}
