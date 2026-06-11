import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/health_360_repository.dart';

class GetContextWeather {
  final Health360Repository repository;

  GetContextWeather({required this.repository});

  Future<Either<Failure, Map<String, dynamic>>> call(String userId) {
    return repository.getContextWeather(userId);
  }
}
