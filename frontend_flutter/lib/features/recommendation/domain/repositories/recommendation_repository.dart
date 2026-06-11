import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cough_assessment.dart';
import '../entities/recommendation_result.dart';

abstract class RecommendationRepository {
  Future<Either<Failure, RecommendationResult>> getRecommendation(
    CoughAssessment assessment,
  );

  Future<Either<Failure, Map<String, dynamic>>> getSleepRecommendation({
    required String snoringFreq,
    required String daytimeSleepiness,
    required String apneaObserved,
    required String bodyType,
    required List<String> sleepSymptoms,
  });
}
