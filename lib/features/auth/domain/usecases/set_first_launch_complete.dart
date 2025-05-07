import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SetFirstLaunchComplete {
  final AuthRepository repository;

  SetFirstLaunchComplete(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.setFirstLaunchComplete();
  }
}
