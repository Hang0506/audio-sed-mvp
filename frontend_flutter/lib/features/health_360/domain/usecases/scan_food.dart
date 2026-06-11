import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/health_360_repository.dart';

class ScanFoodParams {
  final String userId;
  final String foodKey;
  final Uint8List imageBytes;

  const ScanFoodParams({
    required this.userId,
    required this.foodKey,
    required this.imageBytes,
  });
}

class ScanFood {
  final Health360Repository repository;

  ScanFood({required this.repository});

  Future<Either<Failure, Map<String, dynamic>>> call(ScanFoodParams params) {
    return repository.scanFood(
      userId: params.userId,
      foodKey: params.foodKey,
      imageBytes: params.imageBytes,
    );
  }
}
