import 'package:flutter/material.dart';
import '../../features/audio_sed/domain/entities/sound_event.dart';

class TimelineChart extends StatelessWidget {
  final List<SoundEvent> events;
  final double durationSec;

  static const Map<String, Color> classColors = {
    'Cough': Color(0xFFF37022), // FPT Orange
    'Breathing': Color(0xFF00A651), // Long Chau Green
    'Snoring': Color(0xFF9333EA), // Purple
    'Wheeze': Color(0xFFEAB308), // Yellow
  };

  const TimelineChart({
    super.key,
    required this.events,
    required this.durationSec,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty || durationSec <= 0) {
      return const SizedBox.shrink();
    }

    final double validDuration = durationSec > 0 ? durationSec : 5.0;

    // Filter categories seen
    final seenClasses = events.map((e) => e.className).toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🕐 DÒNG THỜI GIAN SỰ KIỆN',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final widthTotal = constraints.maxWidth;
              return Stack(
                children: events.map((event) {
                  final double leftRatio = event.start / validDuration;
                  final double widthRatio = (event.end - event.start) / validDuration;

                  final double left = leftRatio * widthTotal;
                  final double width = widthRatio * widthTotal;

                  final color = classColors[event.className] ?? Colors.blueGrey;

                  return Positioned(
                    left: left,
                    top: 4,
                    bottom: 4,
                    width: width.clamp(5.0, widthTotal),
                    child: Tooltip(
                      message: '${event.classNameVi} (${event.start.toStringAsFixed(1)}s - ${event.end.toStringAsFixed(1)}s)',
                      child: Container(
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: seenClasses.map((className) {
            final color = classColors[className] ?? Colors.blueGrey;
            String nameVi = className;
            if (className == 'Cough') nameVi = 'Ho';
            if (className == 'Breathing') nameVi = 'Thở';
            if (className == 'Snoring') nameVi = 'Ngáy';
            if (className == 'Wheeze') nameVi = 'Thở khò khè';

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  nameVi,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
