import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class AuthRepository {
  /// Checks if the PIN is already set
  Future<Either<Failure, bool>> isPinSet();
  
  /// Sets up a new PIN
  Future<Either<Failure, bool>> setupPin(String pin);
  
  /// Verifies the entered PIN
  Future<Either<Failure, bool>> verifyPin(String pin);
  
  /// Resets the PIN and clears all data
  Future<Either<Failure, bool>> resetApp();
  
  /// Checks if it's the first launch of the app
  Future<Either<Failure, bool>> isFirstLaunch();
  
  /// Sets the first launch flag to false
  Future<Either<Failure, bool>> setFirstLaunchComplete();
}
