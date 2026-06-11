import 'package:equatable/equatable.dart';

class CoughAssessment extends Equatable {
  final String coughType;
  final String duration;
  final String subject;
  final String coughFrequency;
  final List<String> redFlags;
  final bool nightCough;
  final bool postFlu;
  final bool audioHasCough;
  final int audioCoughCount;
  final double audioConfidence;

  const CoughAssessment({
    required this.coughType,
    required this.duration,
    required this.subject,
    required this.coughFrequency,
    required this.redFlags,
    required this.nightCough,
    required this.postFlu,
    required this.audioHasCough,
    required this.audioCoughCount,
    required this.audioConfidence,
  });

  Map<String, dynamic> toJson() {
    return {
      'cough_type': coughType,
      'duration': duration,
      'subject': subject,
      'cough_frequency': coughFrequency,
      'red_flags': redFlags,
      'night_cough': nightCough,
      'post_flu': postFlu,
      'audio_has_cough': audioHasCough,
      'audio_cough_count': audioCoughCount,
      'audio_confidence': audioConfidence,
    };
  }

  @override
  List<Object?> get props => [
        coughType,
        duration,
        subject,
        coughFrequency,
        redFlags,
        nightCough,
        postFlu,
        audioHasCough,
        audioCoughCount,
        audioConfidence,
      ];
}
