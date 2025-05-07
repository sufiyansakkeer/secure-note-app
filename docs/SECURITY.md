# Secure Notes App - Security Documentation

## Overview

The Secure Notes app is designed with security as a primary concern. This document outlines the security features and implementation details to help developers understand how user data is protected.

## Security Features

### 1. PIN Authentication

- **PIN Storage**: PINs are stored using Flutter Secure Storage, which uses platform-specific secure storage mechanisms:
  - Android: Android Keystore System
  - iOS: Keychain

- **PIN Verification**: PIN is verified locally without network transmission
  
- **Brute Force Protection**: Multiple failed PIN attempts trigger a temporary lockout

- **PIN Reset**: If a user forgets their PIN, they can reset the app, which deletes all notes for security

### 2. Data Storage

- **Local Storage Only**: All data is stored locally on the device, with no cloud synchronization
  
- **Hive Database**: Notes are stored in Hive, a lightweight and fast NoSQL database

- **Secure Access**: Database access requires successful PIN authentication

### 3. Data Deletion

- **Forgot PIN**: When a user chooses to reset their PIN, all notes are deleted to prevent unauthorized access
  
- **Secure Deletion**: The app ensures complete removal of data when notes are deleted

## Implementation Details

### PIN Authentication Implementation

The PIN authentication system is implemented using Flutter Secure Storage, which provides a secure way to store sensitive information.

```dart
// lib/features/auth/data/datasources/auth_local_data_source.dart
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

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
}
```

### Brute Force Protection Implementation

The app implements a simple brute force protection mechanism by tracking failed login attempts and temporarily locking the app after a certain number of failures.

```dart
// lib/features/auth/presentation/pages/pin_login_page.dart
class _PinLoginPageState extends State<PinLoginPage> {
  int _failedAttempts = 0;
  bool _isLocked = false;
  DateTime? _lockUntil;

  void _incrementFailedAttempts() {
    setState(() {
      _failedAttempts++;
      if (_failedAttempts >= 3) {
        _isLocked = true;
        _lockUntil = DateTime.now().add(const Duration(minutes: 1));
        _startLockTimer();
      }
    });
  }

  void _startLockTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      if (_lockUntil != null && now.isAfter(_lockUntil!)) {
        setState(() {
          _isLocked = false;
          _failedAttempts = 0;
          _lockUntil = null;
        });
        timer.cancel();
      } else {
        setState(() {});
      }
    });
  }
}
```

### Secure Data Storage Implementation

Notes are stored using Hive, with proper error handling and data validation.

```dart
// lib/features/notes/data/datasources/notes_local_data_source.dart
class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  Box<NoteModel>? _notesBox;

  Future<Box<NoteModel>> get notesBox async {
    if (_notesBox != null && _notesBox!.isOpen) return _notesBox!;
    await initDatabase();
    return _notesBox!;
  }

  @override
  Future<void> initDatabase() async {
    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Register the adapter if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(NoteModelAdapter());
      }

      // Open the box
      _notesBox = await Hive.openBox<NoteModel>('notes_box');
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to initialize Hive database: ${e.toString()}',
      );
    }
  }
}
```

### Secure Data Deletion Implementation

When a user resets the app, all notes are securely deleted.

```dart
// lib/features/auth/presentation/widgets/forgot_pin_dialog.dart
void _resetApp() async {
  if (!mounted) return;

  setState(() {
    _isLoading = true;
  });

  // First, clear all notes data
  final notesProvider = Provider.of<NotesProvider>(context, listen: false);
  final notesCleared = await notesProvider.clearAllNotes();

  if (!mounted) return;

  if (!notesCleared) {
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to clear notes data. Please try again.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // Then reset the app (clear PIN and first launch flag)
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final success = await authProvider.resetApplication();

  // ...
}
```

## Security Best Practices

### 1. Avoid Storing Sensitive Data in Code

Never hardcode sensitive information like API keys, passwords, or PINs in the source code. Use secure storage mechanisms like Flutter Secure Storage.

### 2. Validate User Input

Always validate user input to prevent injection attacks or unexpected behavior.

```dart
// Example of input validation
String? _validatePin(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a PIN';
  }
  if (value.length < 4) {
    return 'PIN must be at least 4 digits';
  }
  if (!RegExp(r'^\d+$').hasMatch(value)) {
    return 'PIN must contain only digits';
  }
  return null;
}
```

### 3. Handle Errors Securely

Ensure that error messages don't reveal sensitive information.

```dart
// Example of secure error handling
try {
  // Operation that might fail
} catch (e) {
  // Log the detailed error internally
  _logger.error('Detailed error: $e');
  
  // Show a generic error message to the user
  showErrorMessage('An error occurred. Please try again.');
}
```

### 4. Implement Proper Authentication Flows

Ensure that authentication is required before accessing sensitive data.

```dart
// Example of checking authentication before accessing data
Future<void> loadNotes() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  if (authProvider.status != AuthStatus.authenticated) {
    // Redirect to login
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PinLoginPage()),
    );
    return;
  }
  
  // Proceed with loading notes
  final notesProvider = Provider.of<NotesProvider>(context, listen: false);
  await notesProvider.loadNotes();
}
```

## Security Considerations for Future Development

### 1. Biometric Authentication

Consider adding support for fingerprint or face recognition for enhanced security.

### 2. End-to-End Encryption

If cloud synchronization is added in the future, implement end-to-end encryption to protect data in transit and at rest.

### 3. Secure Backup and Restore

Implement secure mechanisms for backing up and restoring notes, ensuring that backups are encrypted.

### 4. Security Audits

Regularly audit the codebase for security vulnerabilities and keep dependencies updated.

## Conclusion

The Secure Notes app implements several security features to protect user data. By following the principles outlined in this document, developers can maintain and enhance the security of the application as it evolves.
