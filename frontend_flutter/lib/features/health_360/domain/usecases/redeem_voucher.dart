import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/health_360_repository.dart';

class RedeemVoucherParams {
  final String userId;
  final String productId;
  final String productName;
  final int cost;
  final double lat;
  final double long;

  const RedeemVoucherParams({
    required this.userId,
    required this.productId,
    required this.productName,
    required this.cost,
    required this.lat,
    required this.long,
  });
}

class RedeemVoucher {
  final Health360Repository repository;

  RedeemVoucher({required this.repository});

  Future<Either<Failure, Map<String, dynamic>>> call(RedeemVoucherParams params) {
    return repository.redeemVoucher(
      userId: params.userId,
      productId: params.productId,
      productName: params.productName,
      cost: params.cost,
      lat: params.lat,
      long: params.long,
    );
  }
}
