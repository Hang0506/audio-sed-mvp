import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cough_assessment.dart';
import '../../domain/entities/recommendation_result.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../datasources/recommendation_remote_data_source.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  final RecommendationRemoteDataSource remoteDataSource;

  RecommendationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, RecommendationResult>> getRecommendation(
    CoughAssessment assessment,
  ) async {
    try {
      final result = await remoteDataSource.getRecommendation(assessment);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Lỗi tải khuyến nghị: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSleepRecommendation({
    required String snoringFreq,
    required String daytimeSleepiness,
    required String apneaObserved,
    required String bodyType,
    required List<String> sleepSymptoms,
  }) async {
    try {
      final result = await remoteDataSource.getSleepRecommendation(
        snoringFreq: snoringFreq,
        daytimeSleepiness: daytimeSleepiness,
        apneaObserved: apneaObserved,
        bodyType: bodyType,
        sleepSymptoms: sleepSymptoms,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Lỗi tải khuyến nghị giấc ngủ: ${e.toString()}'));
    }
  }
}
