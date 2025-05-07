import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/util/constants.dart';

abstract class AuthLocalDataSource {
  Future<bool> isPinSet();
  Future<bool> setupPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<bool> resetApp();
  Future<bool> isFirstLaunch();
  Future<bool> setFirstLaunchComplete();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<bool> isPinSet() async {
    try {
      final pin = await secureStorage.read(key: StorageKeys.pinKey);
      return pin != null;
    } catch (e) {
      throw CacheException(message: 'Failed to check if PIN is set: ${e.toString()}');
    }
  }

  @override
  Future<bool> setupPin(String pin) async {
    try {
      await secureStorage.write(key: StorageKeys.pinKey, value: pin);
      return true;
    } catch (e) {
      throw CacheException(message: 'Failed to set up PIN: ${e.toString()}');
    }
  }

  @override
  Future<bool> verifyPin(String pin) async {
    try {
      final storedPin = await secureStorage.read(key: StorageKeys.pinKey);
      return storedPin == pin;
    } catch (e) {
      throw CacheException(message: 'Failed to verify PIN: ${e.toString()}');
    }
  }

  @override
  Future<bool> resetApp() async {
    try {
      await secureStorage.delete(key: StorageKeys.pinKey);
      await secureStorage.write(key: StorageKeys.isFirstLaunch, value: 'true');
      return true;
    } catch (e) {
      throw CacheException(message: 'Failed to reset app: ${e.toString()}');
    }
  }

  @override
  Future<bool> isFirstLaunch() async {
    try {
      final isFirstLaunch = await secureStorage.read(key: StorageKeys.isFirstLaunch);
      return isFirstLaunch == null || isFirstLaunch == 'true';
    } catch (e) {
      throw CacheException(message: 'Failed to check if first launch: ${e.toString()}');
    }
  }

  @override
  Future<bool> setFirstLaunchComplete() async {
    try {
      await secureStorage.write(key: StorageKeys.isFirstLaunch, value: 'false');
      return true;
    } catch (e) {
      throw CacheException(message: 'Failed to set first launch complete: ${e.toString()}');
    }
  }
}
