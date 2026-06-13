import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/injection_container.dart';
import '../../features/audio_sed/domain/entities/analysis_result.dart';
import '../../features/recommendation/domain/entities/recommendation_result.dart';
import '../../features/recommendation/presentation/cubit/recommendation_cubit.dart';
import '../../features/audio_sed/presentation/pages/audio_sed_page.dart';
import '../../features/audio_sed/presentation/pages/food_checker_detail_page.dart';
import '../../features/audio_sed/presentation/pages/audio_analysis_detail_page.dart';
import '../../features/audio_sed/presentation/pages/weekly_summary_page.dart';
import '../../features/recommendation/presentation/pages/assessment_page.dart';
import '../../features/recommendation/presentation/pages/recommendation_page.dart';
import '../../features/recommendation/presentation/pages/sleep_assessment_page.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text('Đường dẫn không tồn tại!'),
      ),
    ),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AudioSedPage(),
      ),
      GoRoute(
        path: '/food-checker',
        builder: (context, state) => const FoodCheckerDetailPage(),
      ),
      GoRoute(
        path: '/audio-analysis',
        builder: (context, state) => const AudioAnalysisDetailPage(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const WeeklySummaryPage(),
      ),
      GoRoute(
        path: '/assessment',
        builder: (context, state) {
          final analysisResult = state.extra as AnalysisResult;
          return BlocProvider(
            create: (_) => sl<RecommendationCubit>(),
            child: AssessmentPage(analysisResult: analysisResult),
          );
        },
      ),
      GoRoute(
        path: '/recommendation',
        builder: (context, state) {
          final recommendationResult = state.extra as RecommendationResult;
          return RecommendationPage(result: recommendationResult);
        },
      ),
      GoRoute(
        path: '/sleep-assessment',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => sl<RecommendationCubit>(),
            child: const SleepAssessmentPage(),
          );
        },
      ),
    ],
  );
}
