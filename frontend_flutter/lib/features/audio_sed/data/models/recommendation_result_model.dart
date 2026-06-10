import '../../domain/entities/recommendation_result.dart';

class ClassificationInfoModel extends ClassificationInfo {
  const ClassificationInfoModel({
    required super.coughType,
    required super.coughTypeVi,
    required super.duration,
    required super.durationVi,
    required super.durationDesc,
    required super.subject,
    required super.subjectVi,
    required super.severity,
  });

  factory ClassificationInfoModel.fromJson(Map<String, dynamic> json) {
    return ClassificationInfoModel(
      coughType: json['cough_type'] as String? ?? '',
      coughTypeVi: json['cough_type_vi'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      durationVi: json['duration_vi'] as String? ?? '',
      durationDesc: json['duration_desc'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      subjectVi: json['subject_vi'] as String? ?? '',
      severity: json['severity'] as String? ?? '',
    );
  }
}

class RecommendationCategoryModel extends RecommendationCategory {
  const RecommendationCategoryModel({
    required super.category,
    required super.categoryLabel,
    required super.categoryIcon,
    required super.items,
    required super.priority,
  });

  factory RecommendationCategoryModel.fromJson(Map<String, dynamic> json) {
    return RecommendationCategoryModel(
      category: json['category'] as String? ?? '',
      categoryLabel: json['category_label'] as String? ?? '',
      categoryIcon: json['category_icon'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)?.map((i) => i as String).toList() ?? [],
      priority: json['priority'] as int? ?? 1,
    );
  }
}

class RecommendationResultModel extends RecommendationResult {
  const RecommendationResultModel({
    required super.classification,
    required super.recommendations,
    required super.warnings,
    required super.shouldSeeDoctor,
  });

  factory RecommendationResultModel.fromJson(Map<String, dynamic> json) {
    return RecommendationResultModel(
      classification: ClassificationInfoModel.fromJson(
        json['classification'] as Map<String, dynamic>? ?? {},
      ),
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((r) => RecommendationCategoryModel.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      warnings: (json['warnings'] as List<dynamic>?)?.map((w) => w as String).toList() ?? [],
      shouldSeeDoctor: json['should_see_doctor'] as bool? ?? false,
    );
  }
}
