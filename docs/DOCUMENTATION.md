# Secure Notes App - Technical Documentation

## Table of Contents

1. [Introduction](#introduction)
2. [Architecture Overview](#architecture-overview)
3. [Feature Documentation](#feature-documentation)
   - [Authentication](#authentication)
   - [Notes Management](#notes-management)
4. [Data Flow](#data-flow)
5. [Security Implementation](#security-implementation)
6. [State Management](#state-management)
7. [Error Handling](#error-handling)
8. [Testing](#testing)
9. [Future Improvements](#future-improvements)

## Introduction

Secure Notes is a privacy-focused note-taking application built with Flutter. It follows clean architecture principles to ensure maintainability, testability, and scalability. The app provides a secure environment for users to store sensitive information protected by PIN authentication.

## Architecture Overview

The application follows Clean Architecture principles, separating concerns into distinct layers:

### Layers

1. **Presentation Layer**
   - Contains UI components (widgets, pages)
   - Manages state using Provider
   - Handles user interactions
   - Communicates with Domain layer

2. **Domain Layer**
   - Contains business logic and rules
   - Defines entities and use cases
   - Defines repository interfaces
   - Independent of any framework or implementation details

3. **Data Layer**
   - Implements repository interfaces from Domain layer
   - Manages data sources (local storage)
   - Handles data conversion between entities and models

### Dependency Flow

Dependencies flow from outer layers to inner layers:
- Presentation → Domain ← Data

This ensures that the Domain layer remains independent and can be tested in isolation.

### Dependency Injection

The application uses GetIt for dependency injection, configured in `app/di/injection_container.dart`. This allows for:
- Loose coupling between components
- Easier testing through dependency substitution
- Centralized management of dependencies

## Feature Documentation

### Authentication

The authentication feature handles user PIN setup, verification, and app reset functionality.

#### Components

1. **Entities**
   - No specific entities, uses primitive types

2. **Use Cases**
   - `IsPinSet`: Checks if a PIN has been set
   - `SetupPin`: Sets up a new PIN
   - `VerifyPin`: Verifies an entered PIN
   - `ResetApp`: Resets the app (clears PIN and data)
   - `IsFirstLaunch`: Checks if it's the first launch
   - `SetFirstLaunchComplete`: Marks first launch as complete

3. **Repository**
   - `AuthRepository`: Interface defining authentication operations
   - `AuthRepositoryImpl`: Implementation of the repository

4. **Data Sources**
   - `AuthLocalDataSource`: Interface for local authentication data operations
   - `AuthLocalDataSourceImpl`: Implementation using Flutter Secure Storage

5. **Presentation**
   - `AuthProvider`: Manages authentication state
   - `PinSetupPage`: UI for setting up a PIN
   - `PinLoginPage`: UI for logging in with a PIN
   - `ForgotPinDialog`: UI for resetting the app

#### Authentication Flow

1. **First Launch**:
   - App checks if it's the first launch using `IsFirstLaunch`
   - If true, shows `PinSetupPage`
   - User sets a PIN, which is stored securely
   - First launch flag is set to false

2. **Subsequent Launches**:
   - App checks if PIN is set using `IsPinSet`
   - If true, shows `PinLoginPage`
   - User enters PIN, which is verified using `VerifyPin`
   - If correct, user is authenticated and can access notes

3. **Forgot PIN**:
   - User taps "Forgot PIN" on login page
   - Shows confirmation dialog
   - If confirmed, app is reset using `ResetApp`
   - All notes are deleted for security
   - User is redirected to `PinSetupPage`

### Notes Management

The notes feature handles creating, reading, updating, and deleting notes.

#### Components

1. **Entities**
   - `Note`: Core business entity representing a note

2. **Use Cases**
   - `GetNotes`: Retrieves all notes
   - `GetNoteById`: Retrieves a specific note
   - `CreateNote`: Creates a new note
   - `UpdateNote`: Updates an existing note
   - `DeleteNote`: Deletes a note
   - `DeleteAllNotes`: Deletes all notes (used when resetting app)

3. **Repository**
   - `NotesRepository`: Interface defining note operations
   - `NotesRepositoryImpl`: Implementation of the repository

4. **Data Sources**
   - `NotesLocalDataSource`: Interface for local note data operations
   - `NotesLocalDataSourceImpl`: Implementation using Hive

5. **Models**
   - `NoteModel`: Data model for persistence

6. **Presentation**
   - `NotesProvider`: Manages notes state
   - `NotesListPage`: UI for displaying all notes
   - `NoteEditPage`: UI for creating/editing a note
   - `NoteItem`: UI component for displaying a note in the list

#### Notes Flow

1. **Viewing Notes**:
   - `NotesListPage` loads notes using `GetNotes`
   - Notes are displayed in a list sorted by last updated time

2. **Creating a Note**:
   - User taps "+" button on `NotesListPage`
   - `NoteEditPage` is shown with empty fields
   - User enters title and content
   - Note is created using `CreateNote`
   - User is returned to `NotesListPage` with updated list

3. **Editing a Note**:
   - User taps on a note in `NotesListPage`
   - `NoteEditPage` is shown with note data
   - User edits title and/or content
   - Note is updated using `UpdateNote`
   - User is returned to `NotesListPage` with updated list

4. **Deleting a Note**:
   - User swipes a note in `NotesListPage`
   - Confirmation is requested
   - Note is deleted using `DeleteNote`
   - List is updated

## Data Flow

### Authentication Data Flow

1. User enters PIN in UI
2. `AuthProvider` calls use case (e.g., `VerifyPin`)
3. Use case calls `AuthRepository`
4. Repository calls `AuthLocalDataSource`
5. Data source interacts with Flutter Secure Storage
6. Result flows back up the chain with error handling at each level

### Notes Data Flow

1. User interacts with notes UI
2. `NotesProvider` calls appropriate use case
3. Use case calls `NotesRepository`
4. Repository calls `NotesLocalDataSource`
5. Data source interacts with Hive database
6. Result flows back up the chain with error handling at each level

## Security Implementation

### PIN Storage

- PINs are stored using Flutter Secure Storage
- Flutter Secure Storage uses platform-specific secure storage:
  - Android: Android Keystore System
  - iOS: Keychain

### Data Protection

- Notes are stored locally using Hive
- No cloud synchronization to prevent data leakage
- PIN verification required to access notes
- Option to reset app (delete all data) if PIN is forgotten
- Automatic logout after multiple failed PIN attempts

## State Management

The application uses Provider for state management:

- `AuthProvider`: Manages authentication state
  - Tracks authentication status (authenticated, unauthenticated, first launch)
  - Handles PIN verification and setup
  - Manages theme preferences

- `NotesProvider`: Manages notes state
  - Tracks notes loading status
  - Maintains list of notes
  - Handles CRUD operations for notes

## Error Handling

The application uses a structured approach to error handling:

1. **Exceptions**:
   - Defined in `core/error/exceptions.dart`
   - Specific exceptions for different error types (e.g., `DatabaseException`, `CacheException`)

2. **Failures**:
   - Defined in `core/error/failures.dart`
   - Represent domain-level errors
   - Used with Either type from Dartz for functional error handling

3. **Error Flow**:
   - Data sources throw exceptions
   - Repositories catch exceptions and return failures
   - Use cases pass failures to presentation layer
   - Presentation layer displays appropriate error messages

## Testing

*Note: Add testing documentation as tests are implemented*

## Future Improvements

Potential future enhancements for the application:

1. **Biometric Authentication**: Add support for fingerprint/face recognition
2. **Note Categories**: Allow users to categorize notes
3. **Rich Text Support**: Add formatting options for note content
4. **Search Functionality**: Allow users to search through notes
5. **Export/Import**: Add ability to backup and restore notes
6. **Attachments**: Support for images and files in notes
7. **End-to-End Encryption**: Additional security layer for note content
8. **Customizable Themes**: More theme options beyond light/dark
9. **Localization**: Support for multiple languages
