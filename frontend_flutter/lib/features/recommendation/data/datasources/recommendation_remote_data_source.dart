import '../../../../core/network/api_client.dart';
import '../../domain/entities/cough_assessment.dart';
import '../models/recommendation_result_model.dart';

abstract class RecommendationRemoteDataSource {
  Future<RecommendationResultModel> getRecommendation(CoughAssessment assessment);

  Future<Map<String, dynamic>> getSleepRecommendation({
    required String snoringFreq,
    required String daytimeSleepiness,
    required String apneaObserved,
    required String bodyType,
    required List<String> sleepSymptoms,
  });
}

class RecommendationRemoteDataSourceImpl implements RecommendationRemoteDataSource {
  final ApiClient client;

  RecommendationRemoteDataSourceImpl({required this.client});

  @override
  Future<RecommendationResultModel> getRecommendation(CoughAssessment assessment) async {
    final response = await client.post(
      '/api/recommendation',
      data: assessment.toJson(),
    );

    if (response.statusCode == 200) {
      return RecommendationResultModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to get recommendations');
    }
  }

  @override
  Future<Map<String, dynamic>> getSleepRecommendation({
    required String snoringFreq,
    required String daytimeSleepiness,
    required String apneaObserved,
    required String bodyType,
    required List<String> sleepSymptoms,
  }) async {
    final response = await client.post(
      '/api/sleep-assessment',
      data: {
        'snoring_freq': snoringFreq,
        'daytime_sleepiness': daytimeSleepiness,
        'apnea_observed': apneaObserved,
        'body_type': bodyType,
        'sleep_symptoms': sleepSymptoms,
      },
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Failed to get sleep recommendations');
    }
  }
}
