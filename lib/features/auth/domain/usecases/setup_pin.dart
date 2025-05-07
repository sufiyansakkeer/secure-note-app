import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SetupPin {
  final AuthRepository repository;

  SetupPin(this.repository);

  Future<Either<Failure, bool>> call(String pin) async {
    return await repository.setupPin(pin);
  }
}
