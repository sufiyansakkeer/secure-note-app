import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class IsFirstLaunch {
  final AuthRepository repository;

  IsFirstLaunch(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.isFirstLaunch();
  }
}
