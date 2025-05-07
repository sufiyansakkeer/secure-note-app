# Secure Notes App - Architecture Documentation

## Clean Architecture Overview

The Secure Notes app follows Clean Architecture principles as proposed by Robert C. Martin. This architecture divides the application into concentric layers, each with its own responsibilities and dependencies.

![Clean Architecture Diagram](https://blog.cleancoder.com/uncle-bob/images/2012-08-13-the-clean-architecture/CleanArchitecture.jpg)

### Key Principles

1. **Independence of Frameworks**: The business logic is independent of UI, database, or external frameworks.
2. **Testability**: Business rules can be tested without UI, database, web server, or any external element.
3. **Independence of UI**: The UI can change without changing the rest of the system.
4. **Independence of Database**: The business rules are not bound to the database.
5. **Independence of External Agency**: Business rules don't know anything about the outside world.

## Project Structure

The project is organized into the following structure:

```
lib/
├── app/
│   └── di/                  # Dependency injection
├── core/
│   ├── error/               # Error handling
│   └── util/                # Utilities and constants
├── features/
│   ├── auth/                # Authentication feature
│   │   ├── data/            # Data layer
│   │   │   ├── datasources/ # Data sources
│   │   │   ├── models/      # Data models
│   │   │   └── repositories/ # Repository implementations
│   │   ├── domain/          # Domain layer
│   │   │   ├── entities/    # Business entities
│   │   │   ├── repositories/ # Repository interfaces
│   │   │   └── usecases/    # Use cases
│   │   └── presentation/    # Presentation layer
│   │       ├── bloc/        # State management
│   │       ├── pages/       # UI pages
│   │       └── widgets/     # UI components
│   └── notes/               # Notes feature (same structure as auth)
└── main.dart                # Entry point
```

## Layers in Detail

### 1. Domain Layer

The innermost layer containing business logic and rules. It's independent of other layers.

#### Components

- **Entities**: Core business objects (e.g., `Note`)
- **Repository Interfaces**: Define methods for data operations
- **Use Cases**: Implement specific business rules

#### Example: Note Entity

```dart
class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });
}
```

#### Example: Repository Interface

```dart
abstract class NotesRepository {
  Future<Either<Failure, List<Note>>> getNotes();
  Future<Either<Failure, Note>> getNoteById(int id);
  Future<Either<Failure, Note>> createNote(Note note);
  Future<Either<Failure, Note>> updateNote(Note note);
  Future<Either<Failure, bool>> deleteNote(int id);
  Future<Either<Failure, bool>> deleteAllNotes();
}
```

#### Example: Use Case

```dart
class GetNotes {
  final NotesRepository repository;

  GetNotes(this.repository);

  Future<Either<Failure, List<Note>>> call() async {
    return await repository.getNotes();
  }
}
```

### 2. Data Layer

Implements the repository interfaces defined in the domain layer.

#### Components

- **Models**: Data representations of entities
- **Data Sources**: Interfaces and implementations for data retrieval
- **Repositories**: Implementations of domain repository interfaces

#### Example: Note Model

```dart
class NoteModel {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteModel({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Note entity
  Note toEntity() {
    return Note(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }
}
```

#### Example: Data Source

```dart
abstract class NotesLocalDataSource {
  Future<List<NoteModel>> getNotes();
  Future<NoteModel> getNoteById(int id);
  Future<NoteModel> createNote(NoteModel note);
  Future<NoteModel> updateNote(NoteModel note);
  Future<bool> deleteNote(int id);
  Future<bool> deleteAllNotes();
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  // Implementation using Hive
}
```

#### Example: Repository Implementation

```dart
class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;

  NotesRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Note>>> getNotes() async {
    try {
      final models = await localDataSource.getNotes();
      final notes = models.map((model) => model.toEntity()).toList();
      return Right(notes);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }
  
  // Other methods...
}
```

### 3. Presentation Layer

Handles UI and user interactions.

#### Components

- **Providers/BLoCs**: Manage state and business logic for UI
- **Pages**: Full screens in the application
- **Widgets**: Reusable UI components

#### Example: Notes Provider

```dart
class NotesProvider with ChangeNotifier {
  final GetNotes getNotes;
  final GetNoteById getNoteById;
  final CreateNote createNote;
  final UpdateNote updateNote;
  final DeleteNote deleteNote;
  final DeleteAllNotes deleteAllNotes;

  NotesStatus _status = NotesStatus.initial;
  List<Note> _notes = [];
  Note? _selectedNote;
  String _errorMessage = '';

  // Getters, methods, etc.
}
```

## Dependency Injection

The app uses GetIt for dependency injection, configured in `app/di/injection_container.dart`.

```dart
final sl = GetIt.instance;

Future<void> init() async {
  // Register providers
  sl.registerFactory(() => AuthProvider(
        isPinSet: sl(),
        setupPin: sl(),
        // Other dependencies...
      ));
  
  // Register use cases
  sl.registerLazySingleton(() => IsPinSet(sl()));
  sl.registerLazySingleton(() => SetupPin(sl()));
  
  // Register repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );
  
  // Register data sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );
  
  // Register external dependencies
  sl.registerLazySingleton(() => const FlutterSecureStorage());
}
```

## Error Handling

The application uses a functional approach to error handling with the Either type from Dartz.

```dart
// Repository method
Future<Either<Failure, List<Note>>> getNotes() async {
  try {
    final models = await localDataSource.getNotes();
    final notes = models.map((model) => model.toEntity()).toList();
    return Right(notes);
  } on DatabaseException catch (e) {
    return Left(DatabaseFailure(message: e.message));
  }
}

// Use in presentation layer
final result = await getNotes();
result.fold(
  (failure) => _handleError(failure),
  (notes) => _displayNotes(notes),
);
```

## Data Flow

1. **User Interaction**: User interacts with UI
2. **Provider/BLoC**: Handles the interaction and calls appropriate use case
3. **Use Case**: Executes business logic and calls repository
4. **Repository**: Coordinates data operations and calls data source
5. **Data Source**: Interacts with external systems (Hive, Secure Storage)
6. **Response**: Data flows back up through the layers

## Security Architecture

1. **PIN Authentication**:
   - PIN stored in Flutter Secure Storage
   - PIN verification required to access notes
   - Multiple failed attempts trigger temporary lockout

2. **Data Security**:
   - Notes stored locally using Hive
   - No cloud synchronization
   - Option to reset app (delete all data) if PIN is forgotten

## Conclusion

The Clean Architecture approach used in the Secure Notes app provides:

- **Separation of Concerns**: Each layer has a specific responsibility
- **Testability**: Business logic can be tested independently
- **Maintainability**: Changes in one layer don't affect others
- **Scalability**: New features can be added without modifying existing code

This architecture ensures that the application remains robust, maintainable, and adaptable to future requirements.
