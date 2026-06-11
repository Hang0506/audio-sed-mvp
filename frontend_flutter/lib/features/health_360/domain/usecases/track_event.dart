import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/health_360_repository.dart';

class TrackEventParams {
  final String userId;
  final String eventType;
  final Map<String, dynamic> metadata;

  const TrackEventParams({
    required this.userId,
    required this.eventType,
    required this.metadata,
  });
}

class TrackEvent {
  final Health360Repository repository;

  TrackEvent({required this.repository});

  Future<Either<Failure, void>> call(TrackEventParams params) {
    return repository.trackEvent(
      userId: params.userId,
      eventType: params.eventType,
      metadata: params.metadata,
    );
  }
}
