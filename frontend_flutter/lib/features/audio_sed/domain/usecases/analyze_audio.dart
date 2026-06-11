import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/analysis_result.dart';
import '../repositories/audio_repository.dart';

class AnalyzeAudioParams {
  final String filePath;
  final String mode;

  const AnalyzeAudioParams({
    required this.filePath,
    required this.mode,
  });
}

class AnalyzeAudio {
  final AudioRepository repository;

  AnalyzeAudio({required this.repository});

  Future<Either<Failure, AnalysisResult>> call(AnalyzeAudioParams params) {
    return repository.analyzeAudio(
      filePath: params.filePath,
      mode: params.mode,
    );
  }
}
