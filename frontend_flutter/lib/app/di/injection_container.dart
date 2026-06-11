import 'package:get_it/get_it.dart';
import '../../core/network/api_client.dart';
import '../cubit/theme_cubit.dart';

// Audio SED Feature
import '../../features/audio_sed/data/datasources/audio_remote_data_source.dart';
import '../../features/audio_sed/data/repositories/audio_repository_impl.dart';
import '../../features/audio_sed/domain/repositories/audio_repository.dart';
import '../../features/audio_sed/domain/usecases/get_samples.dart';
import '../../features/audio_sed/domain/usecases/download_sample.dart';
import '../../features/audio_sed/domain/usecases/analyze_audio.dart';
import '../../features/audio_sed/presentation/cubit/audio_sed_cubit.dart';

// Health 360 Feature
import '../../features/health_360/data/datasources/health_360_remote_data_source.dart';
import '../../features/health_360/data/repositories/health_360_repository_impl.dart';
import '../../features/health_360/domain/repositories/health_360_repository.dart';
import '../../features/health_360/domain/usecases/submit_user_intake.dart';
import '../../features/health_360/domain/usecases/get_context_weather.dart';
import '../../features/health_360/domain/usecases/scan_food.dart';
import '../../features/health_360/domain/usecases/redeem_voucher.dart';
import '../../features/health_360/domain/usecases/track_event.dart';
import '../../features/health_360/domain/usecases/get_weekly_summary.dart';
import '../../features/health_360/presentation/cubit/health_360_cubit.dart';

// Recommendation Feature
import '../../features/recommendation/data/datasources/recommendation_remote_data_source.dart';
import '../../features/recommendation/data/repositories/recommendation_repository_impl.dart';
import '../../features/recommendation/domain/repositories/recommendation_repository.dart';
import '../../features/recommendation/domain/usecases/get_recommendation.dart';
import '../../features/recommendation/domain/usecases/get_sleep_recommendation.dart';
import '../../features/recommendation/presentation/cubit/recommendation_cubit.dart';

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

  // Cubits
  sl.registerFactory(
    () => AudioSedCubit(
      getSamples: sl(),
      downloadSample: sl(),
      analyzeAudio: sl(),
    ),
  );

  // --- Features: Health 360 ---
  // Data sources
  sl.registerLazySingleton<Health360RemoteDataSource>(
    () => Health360RemoteDataSourceImpl(client: sl()),
  );

  // Repositories
  sl.registerLazySingleton<Health360Repository>(
    () => Health360RepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => SubmitUserIntake(repository: sl()));
  sl.registerLazySingleton(() => GetContextWeather(repository: sl()));
  sl.registerLazySingleton(() => ScanFood(repository: sl()));
  sl.registerLazySingleton(() => RedeemVoucher(repository: sl()));
  sl.registerLazySingleton(() => TrackEvent(repository: sl()));
  sl.registerLazySingleton(() => GetWeeklySummary(repository: sl()));

  // Cubits
  sl.registerFactory(
    () => Health360Cubit(
      submitUserIntake: sl(),
      getContextWeather: sl(),
      scanFood: sl(),
      redeemVoucher: sl(),
      trackEvent: sl(),
      getWeeklySummary: sl(),
    ),
  );

  // --- Features: Recommendation ---
  // Data sources
  sl.registerLazySingleton<RecommendationRemoteDataSource>(
    () => RecommendationRemoteDataSourceImpl(client: sl()),
  );

  // Repositories
  sl.registerLazySingleton<RecommendationRepository>(
    () => RecommendationRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetRecommendation(repository: sl()));
  sl.registerLazySingleton(() => GetSleepRecommendation(repository: sl()));

  // Cubits
  sl.registerFactory(
    () => RecommendationCubit(
      getRecommendation: sl(),
      getSleepRecommendation: sl(),
    ),
  );
}
