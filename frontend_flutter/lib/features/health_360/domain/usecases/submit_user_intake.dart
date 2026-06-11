import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/health_360_repository.dart';

class SubmitUserIntakeParams {
  final String name;
  final List<String> symptoms;
  final List<String> diseaseTags;
  final double lat;
  final double long;
  final String deviceToken;

  const SubmitUserIntakeParams({
    required this.name,
    required this.symptoms,
    required this.diseaseTags,
    required this.lat,
    required this.long,
    required this.deviceToken,
  });
}

class SubmitUserIntake {
  final Health360Repository repository;

  SubmitUserIntake({required this.repository});

  Future<Either<Failure, String>> call(SubmitUserIntakeParams params) {
    return repository.submitUserIntake(
      name: params.name,
      symptoms: params.symptoms,
      diseaseTags: params.diseaseTags,
      lat: params.lat,
      long: params.long,
      deviceToken: params.deviceToken,
    );
  }
}
