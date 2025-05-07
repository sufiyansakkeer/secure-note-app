# Secure Notes App

A secure, PIN-protected note-taking application built with Flutter that follows clean architecture principles.

![Secure Notes App](assets/screenshots/app_banner.png)

## Overview

Secure Notes is a privacy-focused note-taking application that protects your sensitive information with PIN authentication. The app is designed with security in mind, using secure storage for authentication and Hive for efficient local data persistence.

## Features

- **PIN Authentication**: Secure access to your notes with a PIN code
- **Secure Storage**: PIN is stored securely using Flutter Secure Storage
- **Create & Edit Notes**: Easily create, edit, and delete notes
- **Dark Mode Support**: Toggle between light and dark themes
- **Clean Architecture**: Organized codebase following clean architecture principles
- **Offline Support**: All data is stored locally on your device
- **Forgot PIN**: Option to reset PIN (will delete all notes for security)
- **Responsive UI**: Works on various screen sizes and orientations

## Screenshots

_Add your screenshots here_

## Technologies Used

- **Flutter**: UI framework
- **Hive**: NoSQL database for local storage
- **Flutter Secure Storage**: Secure storage for sensitive data (PIN)
- **Provider**: State management
- **Get It**: Dependency injection
- **Dartz**: Functional programming features
- **Equatable**: Simplifies equality comparisons

## Architecture

The project follows Clean Architecture principles with the following layers:

- **Presentation**: UI components and state management
- **Domain**: Business logic and use cases
- **Data**: Data sources, repositories, and models

## Project Structure

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

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:

   ```
   git clone https://github.com/yourusername/secure_note_app.git
   ```

2. Navigate to the project directory:

   ```
   cd secure_note_app
   ```

3. Install dependencies:

   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Usage

1. **First Launch**: Set up a PIN to secure your notes
2. **Login**: Enter your PIN to access your notes
3. **Create Note**: Tap the + button to create a new note
4. **Edit Note**: Tap on a note to view and edit it
5. **Delete Note**: Swipe a note to delete it
6. **Theme Toggle**: Use the theme toggle in the app bar to switch between light and dark modes
7. **Forgot PIN**: If you forget your PIN, you can reset it, but this will delete all notes for security reasons

## Security Features

- PIN authentication using secure storage
- No cloud synchronization, all data stays on your device
- Option to reset PIN and data if PIN is forgotten
- Automatic logout after multiple failed PIN attempts

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
