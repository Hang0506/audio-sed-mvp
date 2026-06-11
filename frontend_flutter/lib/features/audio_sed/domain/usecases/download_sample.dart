import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/audio_repository.dart';

class DownloadSample {
  final AudioRepository repository;

  DownloadSample({required this.repository});

  Future<Either<Failure, String>> call(String filename) {
    return repository.downloadSample(filename);
  }
}
