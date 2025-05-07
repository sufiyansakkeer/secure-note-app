# Getting Started with Secure Notes App

This guide will help you set up the Secure Notes App development environment and understand the basic workflow.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable version)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter extensions
- [Git](https://git-scm.com/downloads)

## Setting Up the Development Environment

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/secure_note_app.git
cd secure_note_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

```bash
flutter run
```

This will launch the app on your connected device or emulator.

## Project Structure

The project follows a clean architecture approach with the following structure:

```
lib/
├── app/
│   └── di/                  # Dependency injection
├── core/
│   ├── error/               # Error handling
│   └── util/                # Utilities and constants
├── features/
│   ├── auth/                # Authentication feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── notes/               # Notes feature
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart                # Entry point
```

### Key Components

- **main.dart**: Entry point of the application
- **app/di/injection_container.dart**: Dependency injection setup
- **features/auth**: Authentication feature (PIN setup and verification)
- **features/notes**: Notes management feature

## Understanding the App Flow

1. **App Initialization**:
   - The app starts in `main.dart`
   - Hive database is initialized
   - Dependencies are registered via GetIt

2. **Authentication Flow**:
   - `AuthWrapper` checks the authentication status
   - First launch: Shows PIN setup screen
   - Subsequent launches: Shows PIN login screen if authenticated, or notes list if already logged in

3. **Notes Management**:
   - After authentication, users can view, create, edit, and delete notes
   - Notes are stored locally using Hive

## Key Files to Understand

### Authentication

- **auth_provider.dart**: Manages authentication state
- **pin_setup_page.dart**: UI for setting up a PIN
- **pin_login_page.dart**: UI for logging in with a PIN
- **auth_repository.dart**: Interface for authentication operations
- **auth_local_data_source.dart**: Handles local storage of authentication data

### Notes Management

- **notes_provider.dart**: Manages notes state
- **notes_list_page.dart**: UI for displaying all notes
- **note_edit_page.dart**: UI for creating/editing a note
- **notes_repository.dart**: Interface for notes operations
- **notes_local_data_source.dart**: Handles local storage of notes data

## Common Development Tasks

### Adding a New Feature

1. Create the necessary files in the appropriate directories
2. Implement the feature following clean architecture principles
3. Register any new dependencies in `injection_container.dart`
4. Update the UI to include the new feature

### Modifying Existing Features

1. Identify the files that need to be changed
2. Make the necessary changes
3. Test the changes to ensure they work as expected
4. Update any affected documentation

### Running Tests

```bash
flutter test
```

## Debugging Tips

- Use `print` statements or the Flutter DevTools for debugging
- Check the console for error messages
- Use the Flutter Inspector to debug UI issues
- Set breakpoints in your IDE to step through code

## Common Issues and Solutions

### Hive Database Issues

If you encounter issues with the Hive database:

1. Delete the app from your device/emulator
2. Run `flutter clean`
3. Run `flutter pub get`
4. Run the app again

### Dependency Issues

If you encounter dependency issues:

1. Run `flutter pub get`
2. Check `pubspec.yaml` for any conflicts
3. Run `flutter clean` and then `flutter pub get` again

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Hive Documentation](https://docs.hivedb.dev/)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Clean Architecture Resources](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## Next Steps

Now that you have the app running, here are some suggestions for what to explore next:

1. **Understand the Authentication Flow**: Look at how PIN setup and verification work
2. **Explore the Notes Feature**: See how notes are created, stored, and displayed
3. **Review the Clean Architecture**: Understand how the layers interact
4. **Try Adding a Simple Feature**: Practice by adding a small enhancement

Happy coding!
