import 'package:get_it/get_it.dart';
import 'data/datasources/supabase/supabase_video_call_datasource.dart';
import 'data/providers/firebase_auth_provider.dart';
import 'data/providers/firebase_firestore_provider.dart';
import 'data/providers/firebase_storage_provider.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/storage_repository.dart';
import 'data/repositories/video_call_repository_impl.dart';
import 'domain/repositories/video_call_repository.dart';
import 'domain/usecases/answer_call_usecase.dart';
import 'domain/usecases/end_call_usecase.dart';
import 'domain/usecases/initiate_call_usecase.dart';
import 'domain/usecases/reject_call_usecase.dart';
import 'domain/usecases/send_ice_candidate_usecase.dart';
import 'domain/usecases/watch_call_usecase.dart';
import 'domain/usecases/watch_user_calls_usecase.dart';
import 'features/authentication/bloc/auth_bloc.dart';
import 'features/chat/bloc/chat_bloc.dart';
import 'features/video_call/bloc/video_call_bloc.dart';

final sl = GetIt.instance;

/// Initialize dependency injection
Future<void> initializeDependencies() async {
  // ==================== Firebase Providers ====================
  sl.registerLazySingleton(() => FirebaseAuthProvider());
  sl.registerLazySingleton(() => FirebaseFirestoreProvider());
  sl.registerLazySingleton(() => FirebaseStorageProvider());

  // ==================== Supabase Datasources ====================
  sl.registerLazySingleton(() => SupabaseVideoCallDatasource());

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

  sl.registerLazySingleton<VideoCallRepository>(
    () => VideoCallRepositoryImpl(sl()),
  );

  // ==================== Use Cases ====================
  // Video Call Use Cases
  sl.registerLazySingleton(() => InitiateCallUseCase(sl()));
  sl.registerLazySingleton(() => AnswerCallUseCase(sl()));
  sl.registerLazySingleton(() => EndCallUseCase(sl()));
  sl.registerLazySingleton(() => RejectCallUseCase(sl()));
  sl.registerLazySingleton(() => SendIceCandidateUseCase(sl()));
  sl.registerLazySingleton(() => WatchCallUseCase(sl()));
  sl.registerLazySingleton(() => WatchUserCallsUseCase(sl()));

  // ==================== BLoCs ====================
  // AuthBloc is singleton since it manages global auth state
  sl.registerLazySingleton(() => AuthBloc(sl()));

  // ChatBloc
  sl.registerFactory(() => ChatBloc(sl()));

  // VideoCallBloc - Factory since each call is independent
  sl.registerFactory(
    () => VideoCallBloc(
      initiateCallUseCase: sl(),
      answerCallUseCase: sl(),
      endCallUseCase: sl(),
      rejectCallUseCase: sl(),
      sendIceCandidateUseCase: sl(),
      watchCallUseCase: sl(),
      watchUserCallsUseCase: sl(),
    ),
  );
}
