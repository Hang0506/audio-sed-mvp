import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/analysis_result.dart';

abstract class AudioRepository {
  Future<Either<Failure, List<String>>> getSamples();
  
  Future<Either<Failure, String>> downloadSample(String filename);
  
  Future<Either<Failure, AnalysisResult>> analyzeAudio({
    required String filePath,
    required String mode,
  });
}

