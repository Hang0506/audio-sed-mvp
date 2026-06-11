import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/audio_repository.dart';

class GetSamples {
  final AudioRepository repository;

  GetSamples({required this.repository});

  Future<Either<Failure, List<String>>> call() {
    return repository.getSamples();
  }
}
