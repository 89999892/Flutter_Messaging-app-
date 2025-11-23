import 'package:get_it/get_it.dart';
import 'data/providers/firebase_auth_provider.dart';
import 'data/providers/firebase_firestore_provider.dart';
import 'data/providers/firebase_storage_provider.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/storage_repository.dart';
import 'features/authentication/bloc/auth_bloc.dart';
import 'features/chat/bloc/chat_bloc.dart';

final sl = GetIt.instance;

/// Initialize dependency injection
Future<void> initializeDependencies() async {
  // ==================== Providers ====================
  sl.registerLazySingleton(() => FirebaseAuthProvider());
  sl.registerLazySingleton(() => FirebaseFirestoreProvider());
  sl.registerLazySingleton(() => FirebaseStorageProvider());

  // ==================== Repositories ====================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<StorageRepository>(
    () => StorageRepositoryImpl(sl()),
  );

  // ==================== BLoCs ====================
  // AuthBloc is singleton since it manages global auth state
  sl.registerLazySingleton(() => AuthBloc(sl()));

  // ChatBloc
  sl.registerFactory(() => ChatBloc(sl()));
}
