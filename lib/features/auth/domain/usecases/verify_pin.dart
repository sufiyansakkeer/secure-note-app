import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyPin {
  final AuthRepository repository;

  VerifyPin(this.repository);

  Future<Either<Failure, bool>> call(String pin) async {
    return await repository.verifyPin(pin);
  }
}
