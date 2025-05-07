import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../presentation/bloc/auth_provider.dart';
import '../../../notes/presentation/pages/notes_list_page.dart';
import '../widgets/forgot_pin_dialog.dart';

class PinLoginPage extends StatefulWidget {
  const PinLoginPage({super.key});

  @override
  State<PinLoginPage> createState() => _PinLoginPageState();
}

class _PinLoginPageState extends State<PinLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  int _failedAttempts = 0;
  bool _isLocked = false;
  final int _lockDuration = 30; // Lock duration in seconds
  int _remainingLockTime = 0;
  Timer? _lockTimer;

  @override
  void initState() {
    super.initState();
    _checkLockStatus();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _lockTimer?.cancel();
    super.dispose();
  }

  void _checkLockStatus() {
    if (_isLocked && _remainingLockTime > 0) {
      _startLockTimer();
    }
  }

  void _startLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingLockTime > 0) {
          _remainingLockTime--;
        } else {
          _isLocked = false;
          _lockTimer?.cancel();
        }
      });
    });
  }

  void _incrementFailedAttempts() {
    setState(() {
      _failedAttempts++;
      if (_failedAttempts >= 3) {
        _isLocked = true;
        _remainingLockTime = _lockDuration;
        _startLockTimer();
        _errorMessage =
            'Too many failed attempts. Try again in $_remainingLockTime seconds.';
      }
    });
  }

  void _resetFailedAttempts() {
    setState(() {
      _failedAttempts = 0;
    });
  }

  void _login() async {
    if (_isLocked) {
      setState(() {
        _errorMessage =
            'Account is locked. Try again in $_remainingLockTime seconds.';
      });
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(_pinController.text);

      if (!mounted) return;

      if (success) {
        _resetFailedAttempts();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NotesListPage()),
        );
      } else {
        _incrementFailedAttempts();
        setState(() {
          _isLoading = false;
          if (!_isLocked) {
            _errorMessage =
                'Incorrect PIN. Please try again. ${3 - _failedAttempts} attempts remaining.';
          }
          _pinController.clear();
        });
      }
    }
  }

  void _showForgotPinDialog() {
    showDialog(context: context, builder: (context) => const ForgotPinDialog());
  }

  // Helper method to check if PIN has sequential digits (e.g., 1234, 4321)
  bool _isSequentialPin(String pin) {
    if (pin.length != 4) return false;

    // Check ascending sequence
    bool isAscending = true;
    for (int i = 0; i < pin.length - 1; i++) {
      if (int.parse(pin[i + 1]) != int.parse(pin[i]) + 1) {
        isAscending = false;
        break;
      }
    }

    // Check descending sequence
    bool isDescending = true;
    for (int i = 0; i < pin.length - 1; i++) {
      if (int.parse(pin[i + 1]) != int.parse(pin[i]) - 1) {
        isDescending = false;
        break;
      }
    }

    return isAscending || isDescending;
  }

  // Helper method to check if PIN has repeated digits (e.g., 1111, 2222)
  bool _isRepeatedPin(String pin) {
    if (pin.length != 4) return false;

    // Check if all digits are the same
    final firstDigit = pin[0];
    for (int i = 1; i < pin.length; i++) {
      if (pin[i] != firstDigit) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome Back!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Please enter your PIN to access your notes.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _pinController,
                decoration: InputDecoration(
                  labelText: 'Enter PIN',
                  border: const OutlineInputBorder(),
                  enabled: !_isLocked,
                  errorStyle: const TextStyle(fontSize: 12),
                  // helperText:
                  //     _isLocked
                  //         ? 'Account is locked'
                  //         : 'Enter your 4-digit PIN',
                  helperStyle: TextStyle(
                    color:
                        _isLocked ? Theme.of(context).colorScheme.error : null,
                  ),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                enabled: !_isLocked,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your PIN';
                  }
                  if (value.length != 4) {
                    return 'PIN must be 4 digits';
                  }

                  // Check for sequential digits (e.g., 1234, 4321)
                  final isSequential = _isSequentialPin(value);
                  if (isSequential) {
                    return 'PIN should not be sequential digits';
                  }

                  // Check for repeated digits (e.g., 1111, 2222)
                  final isRepeated = _isRepeatedPin(value);
                  if (isRepeated) {
                    return 'PIN should not be repeated digits';
                  }

                  return null;
                },
              ),
              if (_errorMessage.isNotEmpty && !_isLocked) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              if (_isLocked) ...[
                Text(
                  'Account is locked due to too many failed attempts.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Try again in $_remainingLockTime seconds',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: (_isLoading || _isLocked) ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                          _isLocked ? 'Locked' : 'Login',
                          style: const TextStyle(fontSize: 16),
                        ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _showForgotPinDialog,
                child: const Text('Forgot PIN?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
