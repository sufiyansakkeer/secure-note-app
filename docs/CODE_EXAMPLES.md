# Secure Notes App - Code Examples

This document provides code examples to help developers understand how to use and extend the Secure Notes app.

## Table of Contents

1. [Adding a New Feature](#adding-a-new-feature)
2. [Adding a New Use Case](#adding-a-new-use-case)
3. [Adding a New Repository Method](#adding-a-new-repository-method)
4. [Adding a New UI Component](#adding-a-new-ui-component)
5. [Error Handling Examples](#error-handling-examples)
6. [Testing Examples](#testing-examples)

## Adding a New Feature

To add a new feature to the app, follow these steps:

1. Create the feature folder structure
2. Define entities in the domain layer
3. Define repository interfaces in the domain layer
4. Create use cases in the domain layer
5. Implement models in the data layer
6. Implement repositories in the data layer
7. Create UI components in the presentation layer
8. Register dependencies in the dependency injection container

### Example: Adding a Categories Feature

#### 1. Create Folder Structure

```
lib/features/categories/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

#### 2. Define Entity

```dart
// lib/features/categories/domain/entities/category.dart
class Category {
  final int? id;
  final String name;
  final String color;
  final DateTime createdAt;

  const Category({
    this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });
}
```

#### 3. Define Repository Interface

```dart
// lib/features/categories/domain/repositories/categories_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category.dart';

abstract class CategoriesRepository {
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, Category>> getCategoryById(int id);
  Future<Either<Failure, Category>> createCategory(Category category);
  Future<Either<Failure, Category>> updateCategory(Category category);
  Future<Either<Failure, bool>> deleteCategory(int id);
}
```

#### 4. Create Use Cases

```dart
// lib/features/categories/domain/usecases/get_categories.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category.dart';
import '../repositories/categories_repository.dart';

class GetCategories {
  final CategoriesRepository repository;

  GetCategories(this.repository);

  Future<Either<Failure, List<Category>>> call() async {
    return await repository.getCategories();
  }
}
```

#### 5. Implement Model

```dart
// lib/features/categories/data/models/category_model.dart
import '../../domain/entities/category.dart';

class CategoryModel {
  final int? id;
  final String name;
  final String color;
  final DateTime createdAt;

  const CategoryModel({
    this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  // Convert to Category entity
  Category toEntity() {
    return Category(
      id: id,
      name: name,
      color: color,
      createdAt: createdAt,
    );
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      color: category.color,
      createdAt: category.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
```

#### 6. Implement Repository

```dart
// lib/features/categories/data/repositories/categories_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/categories_repository.dart';
import '../datasources/categories_local_data_source.dart';
import '../models/category_model.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesLocalDataSource localDataSource;

  CategoriesRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final models = await localDataSource.getCategories();
      final categories = models.map((model) => model.toEntity()).toList();
      return Right(categories);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    }
  }

  // Implement other methods...
}
```

#### 7. Create Provider

```dart
// lib/features/categories/presentation/bloc/categories_provider.dart
import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_category_by_id.dart';
import '../../domain/usecases/update_category.dart';

enum CategoriesStatus {
  initial,
  loading,
  loaded,
  error,
}

class CategoriesProvider with ChangeNotifier {
  final GetCategories getCategories;
  final GetCategoryById getCategoryById;
  final CreateCategory createCategory;
  final UpdateCategory updateCategory;
  final DeleteCategory deleteCategory;

  CategoriesStatus _status = CategoriesStatus.initial;
  List<Category> _categories = [];
  String _errorMessage = '';

  CategoriesStatus get status => _status;
  List<Category> get categories => _categories;
  String get errorMessage => _errorMessage;

  CategoriesProvider({
    required this.getCategories,
    required this.getCategoryById,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
  });

  Future<void> loadCategories() async {
    _status = CategoriesStatus.loading;
    notifyListeners();

    final result = await getCategories();
    
    result.fold(
      (failure) {
        _status = CategoriesStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (categories) {
        _categories = categories;
        _status = CategoriesStatus.loaded;
        notifyListeners();
      },
    );
  }

  // Implement other methods...
}
```

#### 8. Register Dependencies

```dart
// lib/app/di/injection_container.dart
// Add to existing file

// Categories
// Provider
sl.registerFactory(
  () => CategoriesProvider(
    getCategories: sl(),
    getCategoryById: sl(),
    createCategory: sl(),
    updateCategory: sl(),
    deleteCategory: sl(),
  ),
);

// Use cases
sl.registerLazySingleton(() => GetCategories(sl()));
sl.registerLazySingleton(() => GetCategoryById(sl()));
sl.registerLazySingleton(() => CreateCategory(sl()));
sl.registerLazySingleton(() => UpdateCategory(sl()));
sl.registerLazySingleton(() => DeleteCategory(sl()));

// Repository
sl.registerLazySingleton<CategoriesRepository>(
  () => CategoriesRepositoryImpl(localDataSource: sl()),
);

// Data sources
sl.registerLazySingleton<CategoriesLocalDataSource>(
  () => CategoriesLocalDataSourceImpl(),
);
```

## Adding a New Use Case

To add a new use case to an existing feature:

1. Create the use case class in the domain layer
2. Add the method to the repository interface if needed
3. Implement the method in the repository implementation
4. Add the method to the data source if needed
5. Register the use case in the dependency injection container
6. Use the use case in the provider/bloc

### Example: Adding a Search Notes Use Case

```dart
// lib/features/notes/domain/usecases/search_notes.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class SearchNotes {
  final NotesRepository repository;

  SearchNotes(this.repository);

  Future<Either<Failure, List<Note>>> call(String query) async {
    return await repository.searchNotes(query);
  }
}
```

Add the method to the repository interface:

```dart
// lib/features/notes/domain/repositories/notes_repository.dart
// Add to existing interface
Future<Either<Failure, List<Note>>> searchNotes(String query);
```

Implement the method in the repository:

```dart
// lib/features/notes/data/repositories/notes_repository_impl.dart
// Add to existing implementation
@override
Future<Either<Failure, List<Note>>> searchNotes(String query) async {
  try {
    final models = await localDataSource.searchNotes(query);
    final notes = models.map((model) => model.toEntity()).toList();
    return Right(notes);
  } on DatabaseException catch (e) {
    return Left(DatabaseFailure(message: e.message));
  }
}
```

## Error Handling Examples

### Repository Layer Error Handling

```dart
@override
Future<Either<Failure, Note>> getNoteById(int id) async {
  try {
    final model = await localDataSource.getNoteById(id);
    return Right(model.toEntity());
  } on DatabaseException catch (e) {
    return Left(DatabaseFailure(message: e.message));
  }
}
```

### Presentation Layer Error Handling

```dart
Future<void> loadNote(int id) async {
  _status = NotesStatus.loading;
  notifyListeners();

  final result = await getNoteById(id);
  
  result.fold(
    (failure) {
      _status = NotesStatus.error;
      _errorMessage = failure.message;
      notifyListeners();
    },
    (note) {
      _selectedNote = note;
      _status = NotesStatus.loaded;
      notifyListeners();
    },
  );
}
```

## Testing Examples

### Repository Test

```dart
void main() {
  late NotesRepositoryImpl repository;
  late MockNotesLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockNotesLocalDataSource();
    repository = NotesRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  group('getNotes', () {
    final tNoteModels = [
      NoteModel(
        id: 1,
        title: 'Test Note',
        content: 'Test Content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    final tNotes = tNoteModels.map((model) => model.toEntity()).toList();

    test('should return notes when call to local data source is successful',
        () async {
      // arrange
      when(mockLocalDataSource.getNotes())
          .thenAnswer((_) async => tNoteModels);
      // act
      final result = await repository.getNotes();
      // assert
      verify(mockLocalDataSource.getNotes());
      expect(result, equals(Right(tNotes)));
    });

    test('should return database failure when call to data source is unsuccessful',
        () async {
      // arrange
      when(mockLocalDataSource.getNotes())
          .thenThrow(DatabaseException(message: 'Database error'));
      // act
      final result = await repository.getNotes();
      // assert
      verify(mockLocalDataSource.getNotes());
      expect(
          result, equals(Left(DatabaseFailure(message: 'Database error'))));
    });
  });
}
```
