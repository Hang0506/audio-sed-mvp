import '../../domain/entities/analysis_result.dart';
import 'sound_event_model.dart';

class CoughTypeAnalysisModel extends CoughTypeAnalysis {
  const CoughTypeAnalysisModel({
    required super.coughType,
    required super.coughTypeVi,
    required super.confidence,
    required super.probabilities,
  });

  factory CoughTypeAnalysisModel.fromJson(Map<String, dynamic> json) {
    return CoughTypeAnalysisModel(
      coughType: json['cough_type'] as String? ?? 'dry',
      coughTypeVi: json['cough_type_vi'] as String? ?? 'Ho khan',
      confidence: (json['confidence'] as num? ?? 0.0).toDouble(),
      probabilities: (json['probabilities'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cough_type': coughType,
      'cough_type_vi': coughTypeVi,
      'confidence': confidence,
      'probabilities': probabilities,
    };
  }
}

class AnalysisResultModel extends AnalysisResult {
  const AnalysisResultModel({
    required super.events,
    required super.hasCough,
    required super.inferenceTimeMs,
    required super.durationSec,
    super.coughTypeAnalysis,
  });

  factory AnalysisResultModel.fromJson(Map<String, dynamic> json) {
    return AnalysisResultModel(
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => SoundEventModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hasCough: json['has_cough'] as bool? ?? false,
      inferenceTimeMs: (json['inference_time_ms'] as num? ?? 0.0).toDouble(),
      durationSec: (json['duration_sec'] as num? ?? 0.0).toDouble(),
      coughTypeAnalysis: json['cough_type_analysis'] != null
          ? CoughTypeAnalysisModel.fromJson(
              json['cough_type_analysis'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'events': events
          .map((e) => (e as SoundEventModel).toJson())
          .toList(),
      'has_cough': hasCough,
      'inference_time_ms': inferenceTimeMs,
      'duration_sec': durationSec,
      'cough_type_analysis': coughTypeAnalysis != null
          ? (coughTypeAnalysis as CoughTypeAnalysisModel).toJson()
          : null,
    };
  }
}
