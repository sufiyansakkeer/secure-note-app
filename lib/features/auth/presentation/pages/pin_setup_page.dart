import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../presentation/bloc/auth_provider.dart';
import '../../../notes/presentation/pages/notes_list_page.dart';

class PinSetupPage extends StatefulWidget {
  const PinSetupPage({super.key});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _setupPin() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.setupPinAndCompleteFirstLaunch(
        _pinController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NotesListPage()),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                      Icons.security,
                      size: 40,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Welcome text
                Text(
                  'Welcome to Secure Notes!',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Please set up a 4-digit PIN to secure your notes.',
                  style: textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // PIN input with custom styling
                _buildPinInput(context),
                const SizedBox(height: 16),
                // Confirm PIN input
                _buildConfirmPinInput(context),
                const SizedBox(height: 32),
                // Security tips
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Security Tips',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Avoid using sequential numbers (1234)',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Avoid using repeated digits (1111)',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Choose a PIN you can remember',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Setup button
                ElevatedButton(
                  onPressed: _isLoading ? null : _setupPin,
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
                            'Set PIN',
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onPrimary,
                            ),
                          ),
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
          labelText: 'Enter 4-digit PIN',
          hintText: 'Create your secure PIN',
          prefixIcon: const Icon(Icons.pin),
          suffixIcon:
              _pinController.text.isNotEmpty
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
        ),
        keyboardType: TextInputType.number,
        obscureText: true,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge?.copyWith(letterSpacing: 8),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a PIN';
          }
          if (value.length != 4) {
            return 'PIN must be 4 digits';
          }

          // Check for sequential digits (e.g., 1234, 4321)
          if (_isSequentialPin(value)) {
            return 'Avoid sequential digits for security';
          }

          // Check for repeated digits (e.g., 1111, 2222)
          if (_isRepeatedPin(value)) {
            return 'Avoid repeated digits for security';
          }

          return null;
        },
        onChanged: (value) {
          // Force a rebuild to update the suffix icon
          setState(() {});
        },
      ),
    );
  }

  Widget _buildConfirmPinInput(BuildContext context) {
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
        controller: _confirmPinController,
        decoration: InputDecoration(
          labelText: 'Confirm PIN',
          hintText: 'Re-enter your PIN',
          prefixIcon: const Icon(Icons.check_circle_outline),
          suffixIcon:
              _confirmPinController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.backspace_outlined),
                    onPressed: () {
                      setState(() {
                        _confirmPinController.text = _confirmPinController.text
                            .substring(
                              0,
                              _confirmPinController.text.length - 1,
                            );
                      });
                    },
                    color: colorScheme.primary,
                    splashRadius: 24,
                  )
                  : const SizedBox(width: 48),
        ),
        keyboardType: TextInputType.number,
        obscureText: true,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge?.copyWith(letterSpacing: 8),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please confirm your PIN';
          }
          if (value != _pinController.text) {
            return 'PINs do not match';
          }
          return null;
        },
        onChanged: (value) {
          // Force a rebuild to update the suffix icon
          setState(() {});
        },
        onFieldSubmitted: (_) {
          if (!_isLoading && _formKey.currentState!.validate()) {
            _setupPin();
          }
        },
      ),
    );
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
}
