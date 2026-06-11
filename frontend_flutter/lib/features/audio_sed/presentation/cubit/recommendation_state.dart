import '../../domain/entities/recommendation_result.dart';

sealed class RecommendationState {
  const RecommendationState();
}

final class RecommendationInitial extends RecommendationState {
  const RecommendationInitial();
}

final class RecommendationLoading extends RecommendationState {
  const RecommendationLoading();
}

final class RecommendationSuccess extends RecommendationState {
  final RecommendationResult result;
  const RecommendationSuccess(this.result);
}

final class RecommendationSleepSuccess extends RecommendationState {
  final Map<String, dynamic> sleepData;
  const RecommendationSleepSuccess(this.sleepData);
}

final class RecommendationError extends RecommendationState {
  final String message;
  const RecommendationError(this.message);
}
