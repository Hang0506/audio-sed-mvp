import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/recommendation_repository.dart';

class SleepAssessmentParams {
  final String snoringFreq;
  final String daytimeSleepiness;
  final String apneaObserved;
  final String bodyType;
  final List<String> sleepSymptoms;

  const SleepAssessmentParams({
    required this.snoringFreq,
    required this.daytimeSleepiness,
    required this.apneaObserved,
    required this.bodyType,
    required this.sleepSymptoms,
  });
}

class GetSleepRecommendation {
  final RecommendationRepository repository;

  GetSleepRecommendation({required this.repository});

  Future<Either<Failure, Map<String, dynamic>>> call(SleepAssessmentParams params) {
    return repository.getSleepRecommendation(
      snoringFreq: params.snoringFreq,
      daytimeSleepiness: params.daytimeSleepiness,
      apneaObserved: params.apneaObserved,
      bodyType: params.bodyType,
      sleepSymptoms: params.sleepSymptoms,
    );
  }
}

