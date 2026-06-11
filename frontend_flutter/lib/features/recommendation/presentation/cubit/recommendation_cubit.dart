import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cough_assessment.dart';
import '../../domain/usecases/get_recommendation.dart';
import '../../domain/usecases/get_sleep_recommendation.dart';
import 'recommendation_state.dart';

class RecommendationCubit extends Cubit<RecommendationState> {
  final GetRecommendation _getRecommendation;
  final GetSleepRecommendation _getSleepRecommendation;

  RecommendationCubit({
    required GetRecommendation getRecommendation,
    required GetSleepRecommendation getSleepRecommendation,
  })  : _getRecommendation = getRecommendation,
        _getSleepRecommendation = getSleepRecommendation,
        super(const RecommendationInitial());

  Future<void> submitCoughAssessment(CoughAssessment assessment) async {
    emit(const RecommendationLoading());
    final result = await _getRecommendation(assessment);
    result.fold(
      (failure) => emit(RecommendationError(failure.message)),
      (recommendationResult) => emit(RecommendationSuccess(recommendationResult)),
    );
  }

  Future<void> submitSleepAssessment({
    required String snoringFreq,
    required String daytimeSleepiness,
    required String apneaObserved,
    required String bodyType,
    required List<String> sleepSymptoms,
  }) async {
    emit(const RecommendationLoading());
    final result = await _getSleepRecommendation(
      SleepAssessmentParams(
        snoringFreq: snoringFreq,
        daytimeSleepiness: daytimeSleepiness,
        apneaObserved: apneaObserved,
        bodyType: bodyType,
        sleepSymptoms: sleepSymptoms,
      ),
    );
    result.fold(
      (failure) => emit(RecommendationError(failure.message)),
      (sleepData) => emit(RecommendationSleepSuccess(sleepData)),
    );
  }

  void resetSurvey() {
    emit(const RecommendationInitial());
  }
}
