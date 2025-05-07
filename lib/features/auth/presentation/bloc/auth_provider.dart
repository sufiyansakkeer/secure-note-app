import 'package:flutter/material.dart';
import '../../domain/usecases/is_first_launch.dart';
import '../../domain/usecases/is_pin_set.dart';
import '../../domain/usecases/reset_app.dart';
import '../../domain/usecases/set_first_launch_complete.dart';
import '../../domain/usecases/setup_pin.dart';
import '../../domain/usecases/verify_pin.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  firstLaunch,
  loading,
  error,
}

class AuthProvider with ChangeNotifier {
  final IsPinSet isPinSet;
  final SetupPin setupPin;
  final VerifyPin verifyPin;
  final ResetApp resetApp;
  final IsFirstLaunch isFirstLaunch;
  final SetFirstLaunchComplete setFirstLaunchComplete;

  AuthStatus _status = AuthStatus.initial;
  String _errorMessage = '';
  bool _isDarkMode = false;

  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isDarkMode => _isDarkMode;

  AuthProvider({
    required this.isPinSet,
    required this.setupPin,
    required this.verifyPin,
    required this.resetApp,
    required this.isFirstLaunch,
    required this.setFirstLaunchComplete,
  });

  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final firstLaunchResult = await isFirstLaunch();
    
    firstLaunchResult.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (isFirst) async {
        if (isFirst) {
          _status = AuthStatus.firstLaunch;
          notifyListeners();
          return;
        }

        final pinSetResult = await isPinSet();
        
        pinSetResult.fold(
          (failure) {
            _status = AuthStatus.error;
            _errorMessage = failure.message;
            notifyListeners();
          },
          (isPinSet) {
            _status = isPinSet ? AuthStatus.unauthenticated : AuthStatus.firstLaunch;
            notifyListeners();
          },
        );
      },
    );
  }

  Future<bool> setupPinAndCompleteFirstLaunch(String pin) async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await setupPin(pin);
    
    return result.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (success) async {
        if (success) {
          final firstLaunchResult = await setFirstLaunchComplete();
          
          return firstLaunchResult.fold(
            (failure) {
              _status = AuthStatus.error;
              _errorMessage = failure.message;
              notifyListeners();
              return false;
            },
            (success) {
              _status = AuthStatus.authenticated;
              notifyListeners();
              return true;
            },
          );
        } else {
          _status = AuthStatus.error;
          _errorMessage = 'Failed to set up PIN';
          notifyListeners();
          return false;
        }
      },
    );
  }

  Future<bool> login(String pin) async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await verifyPin(pin);
    
    return result.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (isCorrect) {
        if (isCorrect) {
          _status = AuthStatus.authenticated;
          notifyListeners();
          return true;
        } else {
          _status = AuthStatus.unauthenticated;
          _errorMessage = 'Incorrect PIN';
          notifyListeners();
          return false;
        }
      },
    );
  }

  Future<bool> resetApplication() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await resetApp();
    
    return result.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (success) {
        if (success) {
          _status = AuthStatus.firstLaunch;
          notifyListeners();
          return true;
        } else {
          _status = AuthStatus.error;
          _errorMessage = 'Failed to reset app';
          notifyListeners();
          return false;
        }
      },
    );
  }

  void logout() {
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
