import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/is_first_launch.dart';
import '../../features/auth/domain/usecases/is_pin_set.dart';
import '../../features/auth/domain/usecases/reset_app.dart';
import '../../features/auth/domain/usecases/set_first_launch_complete.dart';
import '../../features/auth/domain/usecases/setup_pin.dart';
import '../../features/auth/domain/usecases/verify_pin.dart';
import '../../features/auth/presentation/bloc/auth_provider.dart';
import '../../features/notes/data/repositories/notes_repository_impl.dart';
import '../../features/notes/domain/repositories/notes_repository.dart';
import '../../features/notes/domain/usecases/create_note.dart';
import '../../features/notes/domain/usecases/delete_all_notes.dart';
import '../../features/notes/domain/usecases/delete_note.dart';
import '../../features/notes/domain/usecases/get_note_by_id.dart';
import '../../features/notes/domain/usecases/get_notes.dart';
import '../../features/notes/domain/usecases/update_note.dart';
import '../../features/notes/presentation/bloc/notes_provider.dart';
import '../../features/notes/data/datasources/notes_local_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  // Bloc/Provider
  sl.registerFactory(
    () => AuthProvider(
      isPinSet: sl(),
      setupPin: sl(),
      verifyPin: sl(),
      resetApp: sl(),
      isFirstLaunch: sl(),
      setFirstLaunchComplete: sl(),
    ),
  );
  // Features - Notes
  // Bloc/Provider
  sl.registerFactory(
    () => NotesProvider(
      getNotes: sl(),
      getNoteById: sl(),
      createNote: sl(),
      updateNote: sl(),
      deleteNote: sl(),
      deleteAllNotes: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetNotes(sl()));
  sl.registerLazySingleton(() => GetNoteById(sl()));
  sl.registerLazySingleton(() => CreateNote(sl()));
  sl.registerLazySingleton(() => UpdateNote(sl()));
  sl.registerLazySingleton(() => DeleteNote(sl()));
  sl.registerLazySingleton(() => DeleteAllNotes(sl()));

  // Repository
  sl.registerLazySingleton<NotesRepository>(
    () => NotesRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => IsPinSet(sl()));
  sl.registerLazySingleton(() => SetupPin(sl()));
  sl.registerLazySingleton(() => VerifyPin(sl()));
  sl.registerLazySingleton(() => ResetApp(sl()));
  sl.registerLazySingleton(() => IsFirstLaunch(sl()));
  sl.registerLazySingleton(() => SetFirstLaunchComplete(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );

  // Datasources
  sl.registerLazySingleton<NotesLocalDataSource>(
    () => NotesLocalDataSourceImpl(),
  );

  // External
  sl.registerLazySingleton(() => const FlutterSecureStorage());
}
