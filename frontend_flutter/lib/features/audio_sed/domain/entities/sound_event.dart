import 'package:equatable/equatable.dart';

class SoundEvent extends Equatable {
  final int classId;
  final String className;
  final String classNameVi;
  final double start;
  final double end;
  final double confidence;

  const SoundEvent({
    required this.classId,
    required this.className,
    required this.classNameVi,
    required this.start,
    required this.end,
    required this.confidence,
  });

  @override
  List<Object?> get props => [
        classId,
        className,
        classNameVi,
        start,
        end,
        confidence,
      ];
}
