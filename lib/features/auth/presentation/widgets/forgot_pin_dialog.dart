import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/bloc/auth_provider.dart';
import '../pages/pin_setup_page.dart';

class ForgotPinDialog extends StatefulWidget {
  const ForgotPinDialog({super.key});

  @override
  State<ForgotPinDialog> createState() => _ForgotPinDialogState();
}

class _ForgotPinDialogState extends State<ForgotPinDialog> {
  bool _isLoading = false;

  void _resetApp() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resetApplication();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PinSetupPage()),
        (route) => false,
      );
    } else {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reset app. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset App?'),
      content: const Text(
        'This will delete all your notes and reset your PIN. This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _resetApp,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Reset', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
