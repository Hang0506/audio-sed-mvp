import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/health_360_repository.dart';
import '../datasources/health_360_remote_data_source.dart';

class Health360RepositoryImpl implements Health360Repository {
  final Health360RemoteDataSource remoteDataSource;

  Health360RepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> submitUserIntake({
    required String name,
    required List<String> symptoms,
    required List<String> diseaseTags,
    required double lat,
    required double long,
    required String deviceToken,
  }) async {
    try {
      final userId = await remoteDataSource.submitUserIntake(
        name: name,
        symptoms: symptoms,
        diseaseTags: diseaseTags,
        lat: lat,
        long: long,
        deviceToken: deviceToken,
      );
      return Right(userId);
    } catch (e) {
      return Left(ServerFailure('Lỗi tạo hồ sơ lâm sàng: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getContextWeather(String userId) async {
    try {
      final data = await remoteDataSource.getContextWeather(userId);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure('Lỗi lấy dữ liệu thời tiết: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> scanFood({
    required String userId,
    required String foodKey,
    required Uint8List imageBytes,
  }) async {
    try {
      final data = await remoteDataSource.scanFood(
        userId: userId,
        foodKey: foodKey,
        imageBytes: imageBytes,
      );
      return Right(data);
    } catch (e) {
      return Left(ServerFailure('Lỗi phân tích thực phẩm: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> redeemVoucher({
    required String userId,
    required String productId,
    required String productName,
    required int cost,
    required double lat,
    required double long,
  }) async {
    try {
      final data = await remoteDataSource.createOrder(
        userId: userId,
        productId: productId,
        productName: productName,
        lat: lat,
        long: long,
      );
      return Right(data);
    } catch (e) {
      return Left(ServerFailure('Lỗi tạo đơn hàng đổi thưởng: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> trackEvent({
    required String userId,
    required String eventType,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      await remoteDataSource.trackEvent(
        userId: userId,
        eventType: eventType,
        metadata: metadata,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Lỗi ghi nhận sự kiện: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getWeeklySummary(String userId) async {
    try {
      final data = await remoteDataSource.getWeeklySummary(userId);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure('Lỗi lấy tổng kết tuần: ${e.toString()}'));
    }
  }
}
