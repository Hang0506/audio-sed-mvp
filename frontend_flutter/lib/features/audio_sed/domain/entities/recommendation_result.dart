import 'package:equatable/equatable.dart';

class RecommendationCategory extends Equatable {
  final String category;
  final String categoryLabel;
  final String categoryIcon;
  final List<String> items;
  final int priority;

  const RecommendationCategory({
    required this.category,
    required this.categoryLabel,
    required this.categoryIcon,
    required this.items,
    required this.priority,
  });

  @override
  List<Object?> get props => [
        category,
        categoryLabel,
        categoryIcon,
        items,
        priority,
      ];
}

class ClassificationInfo extends Equatable {
  final String coughType;
  final String coughTypeVi;
  final String duration;
  final String durationVi;
  final String durationDesc;
  final String subject;
  final String subjectVi;
  final String severity;

  const ClassificationInfo({
    required this.coughType,
    required this.coughTypeVi,
    required this.duration,
    required this.durationVi,
    required this.durationDesc,
    required this.subject,
    required this.subjectVi,
    required this.severity,
  });

  @override
  List<Object?> get props => [
        coughType,
        coughTypeVi,
        duration,
        durationVi,
        durationDesc,
        subject,
        subjectVi,
        severity,
      ];
}

class RecommendationResult extends Equatable {
  final ClassificationInfo classification;
  final List<RecommendationCategory> recommendations;
  final List<String> warnings;
  final bool shouldSeeDoctor;

  const RecommendationResult({
    required this.classification,
    required this.recommendations,
    required this.warnings,
    required this.shouldSeeDoctor,
  });

  @override
  List<Object?> get props => [
        classification,
        recommendations,
        warnings,
        shouldSeeDoctor,
      ];
}
