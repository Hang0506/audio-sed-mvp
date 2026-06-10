import '../../domain/entities/sound_event.dart';

class SoundEventModel extends SoundEvent {
  const SoundEventModel({
    required super.classId,
    required super.className,
    required super.classNameVi,
    required super.start,
    required super.end,
    required super.confidence,
  });

  factory SoundEventModel.fromJson(Map<String, dynamic> json) {
    return SoundEventModel(
      // The API doesn't always return class_id, let's map it based on class name if missing
      classId: json['class_id'] as int? ?? _getClassId(json['class'] as String? ?? ''),
      className: json['class'] as String? ?? '',
      classNameVi: json['class_vi'] as String? ?? '',
      start: (json['start'] as num? ?? 0.0).toDouble(),
      end: (json['end'] as num? ?? 0.0).toDouble(),
      confidence: (json['confidence'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'class': className,
      'class_vi': classNameVi,
      'start': start,
      'end': end,
      'confidence': confidence,
    };
  }

  static int _getClassId(String className) {
    switch (className) {
      case 'Breathing':
        return 36;
      case 'Wheeze':
        return 37;
      case 'Snoring':
        return 38;
      case 'Cough':
        return 42;
      default:
        return 0;
    }
  }
}
