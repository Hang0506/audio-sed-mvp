import 'package:get_it/get_it.dart';
import '../../core/network/api_client.dart';
import '../cubit/theme_cubit.dart';
import '../../features/audio_sed/data/datasources/audio_remote_data_source.dart';
import '../../features/audio_sed/data/repositories/audio_repository_impl.dart';
import '../../features/audio_sed/domain/repositories/audio_repository.dart';
import '../../features/audio_sed/domain/usecases/get_samples.dart';
import '../../features/audio_sed/domain/usecases/download_sample.dart';
import '../../features/audio_sed/domain/usecases/analyze_audio.dart';
import '../../features/audio_sed/domain/usecases/get_recommendation.dart';
import '../../features/audio_sed/domain/usecases/get_sleep_recommendation.dart';
import '../../features/audio_sed/presentation/cubit/audio_sed_cubit.dart';
import '../../features/audio_sed/presentation/cubit/recommendation_cubit.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // --- Core ---
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // --- Global Cubits ---
  sl.registerFactory(() => ThemeCubit());

  // --- Features: Audio SED ---
  // Data sources
  sl.registerLazySingleton<AudioRemoteDataSource>(
    () => AudioRemoteDataSourceImpl(client: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AudioRepository>(
    () => AudioRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSamples(repository: sl()));
  sl.registerLazySingleton(() => DownloadSample(repository: sl()));
  sl.registerLazySingleton(() => AnalyzeAudio(repository: sl()));
  sl.registerLazySingleton(() => GetRecommendation(repository: sl()));
  sl.registerLazySingleton(() => GetSleepRecommendation(repository: sl()));

  // Cubits
  sl.registerFactory(
    () => AudioSedCubit(
      getSamples: sl(),
      downloadSample: sl(),
      analyzeAudio: sl(),
    ),
  );
  sl.registerFactory(
    () => RecommendationCubit(
      getRecommendation: sl(),
      getSleepRecommendation: sl(),
    ),
  );
}
