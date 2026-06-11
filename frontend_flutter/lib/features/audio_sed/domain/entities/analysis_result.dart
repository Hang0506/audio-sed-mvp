import 'package:equatable/equatable.dart';
import 'sound_event.dart';

class CoughTypeAnalysis extends Equatable {
  final String coughType;
  final String coughTypeVi;
  final double confidence;
  final Map<String, double> probabilities;

  const CoughTypeAnalysis({
    required this.coughType,
    required this.coughTypeVi,
    required this.confidence,
    required this.probabilities,
  });

  @override
  List<Object?> get props => [coughType, coughTypeVi, confidence, probabilities];
}

class AnalysisResult extends Equatable {
  final List<SoundEvent> events;
  final bool hasCough;
  final double inferenceTimeMs;
  final double durationSec;
  final CoughTypeAnalysis? coughTypeAnalysis;

  const AnalysisResult({
    required this.events,
    required this.hasCough,
    required this.inferenceTimeMs,
    required this.durationSec,
    this.coughTypeAnalysis,
  });

  @override
  List<Object?> get props => [
        events,
        hasCough,
        inferenceTimeMs,
        durationSec,
        coughTypeAnalysis,
      ];
}
