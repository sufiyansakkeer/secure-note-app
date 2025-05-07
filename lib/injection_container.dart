import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/is_first_launch.dart';
import 'features/auth/domain/usecases/is_pin_set.dart';
import 'features/auth/domain/usecases/reset_app.dart';
import 'features/auth/domain/usecases/set_first_launch_complete.dart';
import 'features/auth/domain/usecases/setup_pin.dart';
import 'features/auth/domain/usecases/verify_pin.dart';
import 'features/auth/presentation/bloc/auth_provider.dart';
// import 'features/notes/data/datasources/notes_local_data_source.dart';

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

  // Data sources
  // sl.registerLazySingleton<NotesLocalDataSource>(
  //   () => NotesLocalDataSourceImpl(),
  // );

  // External
  sl.registerLazySingleton(() => const FlutterSecureStorage());
}
