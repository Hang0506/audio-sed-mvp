import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/health_360_repository.dart';

class GetWeeklySummary {
  final Health360Repository repository;

  GetWeeklySummary({required this.repository});

  Future<Either<Failure, Map<String, dynamic>>> call(String userId) {
    return repository.getWeeklySummary(userId);
  }
}
