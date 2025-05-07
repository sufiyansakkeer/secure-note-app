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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App logo/icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: 40,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Welcome text
                Text(
                  'Welcome Back!',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Please enter your PIN to access your secure notes.',
                  style: textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // PIN input with custom styling
                _buildPinInput(context),
                // Error message
                if (_errorMessage.isNotEmpty && !_isLocked) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Lock status
                if (_isLocked) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock, color: colorScheme.error),
                            const SizedBox(width: 8),
                            Text(
                              'Account Locked',
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Too many failed attempts. Try again in $_remainingLockTime seconds.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                // Login button
                ElevatedButton(
                  onPressed: (_isLoading || _isLocked) ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: colorScheme.primary.withAlpha(100),
                  ),
                  child:
                      _isLoading
                          ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                          : Text(
                            _isLocked ? 'Locked' : 'Login',
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onPrimary,
                            ),
                          ),
                ),
                const SizedBox(height: 16),
                // Forgot PIN button
                TextButton.icon(
                  onPressed: _showForgotPinDialog,
                  icon: const Icon(Icons.help_outline, size: 18),
                  label: const Text('Forgot PIN?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinInput(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _pinController,
        decoration: InputDecoration(
          labelText: 'Enter PIN',
          hintText: 'Enter your 4-digit PIN',
          prefixIcon: const Icon(Icons.pin),
          suffixIcon:
              _pinController.text.isNotEmpty && !_isLocked
                  ? IconButton(
                    icon: const Icon(Icons.backspace_outlined),
                    onPressed: () {
                      setState(() {
                        _pinController.text = _pinController.text.substring(
                          0,
                          _pinController.text.length - 1,
                        );
                      });
                    },
                    color: colorScheme.primary,
                    splashRadius: 24,
                  )
                  : const SizedBox(width: 48),
          enabled: !_isLocked,
          errorStyle: TextStyle(fontSize: 12),
        ),
        keyboardType: TextInputType.number,
        obscureText: true,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge?.copyWith(letterSpacing: 8),
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

          // We'll skip the sequential and repeated checks during login
          // as the user already set their PIN
          return null;
        },
        onChanged: (value) {
          // Force a rebuild to update the suffix icon
          setState(() {});
        },
        onFieldSubmitted: (_) {
          if (!_isLoading && !_isLocked) {
            _login();
          }
        },
      ),
    );
  }
}
