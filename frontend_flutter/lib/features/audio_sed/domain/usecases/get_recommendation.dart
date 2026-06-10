import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cough_assessment.dart';
import '../entities/recommendation_result.dart';
import '../repositories/audio_repository.dart';

class GetRecommendation {
  final AudioRepository repository;

  GetRecommendation({required this.repository});

  Future<Either<Failure, RecommendationResult>> call(CoughAssessment assessment) {
    return repository.getRecommendation(assessment);
  }
}
