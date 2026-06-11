import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/repositories/audio_repository.dart';
import '../datasources/audio_remote_data_source.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioRemoteDataSource remoteDataSource;

  AudioRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<String>>> getSamples() async {
    try {
      final samples = await remoteDataSource.getSamples();
      return Right(samples);
    } catch (e) {
      return Left(ServerFailure('Không thể kết nối với máy chủ: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> downloadSample(String filename) async {
    try {
      final path = await remoteDataSource.downloadSample(filename);
      return Right(path);
    } catch (e) {
      return Left(ServerFailure('Không thể tải tệp mẫu: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AnalysisResult>> analyzeAudio({
    required String filePath,
    required String mode,
  }) async {
    try {
      final result = await remoteDataSource.analyzeAudio(
        filePath: filePath,
        mode: mode,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Lỗi phân tích âm thanh: ${e.toString()}'));
    }
  }
}

