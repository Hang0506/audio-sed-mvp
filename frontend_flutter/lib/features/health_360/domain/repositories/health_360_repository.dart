import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class Health360Repository {
  Future<Either<Failure, String>> submitUserIntake({
    required String name,
    required List<String> symptoms,
    required List<String> diseaseTags,
    required double lat,
    required double long,
    required String deviceToken,
  });

  Future<Either<Failure, Map<String, dynamic>>> getContextWeather(String userId);

  Future<Either<Failure, Map<String, dynamic>>> scanFood({
    required String userId,
    required String foodKey,
    required Uint8List imageBytes,
  });

  Future<Either<Failure, Map<String, dynamic>>> redeemVoucher({
    required String userId,
    required String productId,
    required String productName,
    required int cost,
    required double lat,
    required double long,
  });

  Future<Either<Failure, void>> trackEvent({
    required String userId,
    required String eventType,
    required Map<String, dynamic> metadata,
  });

  Future<Either<Failure, Map<String, dynamic>>> getWeeklySummary(String userId);
}
