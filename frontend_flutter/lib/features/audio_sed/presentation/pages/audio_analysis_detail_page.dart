import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/audio_sed_cubit.dart';
import '../cubit/audio_sed_state.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/wave_visualizer.dart';
import '../../../health_360/presentation/cubit/health_360_cubit.dart';

class AudioAnalysisDetailPage extends StatefulWidget {
  const AudioAnalysisDetailPage({super.key});

  @override
  State<AudioAnalysisDetailPage> createState() => _AudioAnalysisDetailPageState();
}

class _AudioAnalysisDetailPageState extends State<AudioAnalysisDetailPage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AudioSedCubit, AudioSedState>(
      builder: (context, state) {
        final isRecording = state is AudioSedRecording;
        final isAnalyzing = state is AudioSedAnalyzing;
        final hasResults = state is AudioSedAnalysisSuccess;

        String statusText = 'Sẵn sàng';
        int seconds = 0;
        if (isRecording) {
          seconds = state.elapsedSeconds;
          statusText = '00:0$seconds / Đang thu âm...';
        } else if (isAnalyzing) {
          statusText = '00:05 / Đang phân tích...';
        } else if (hasResults) {
          statusText = '00:05 / Hoàn tất';
        }

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF4F7F6),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF0C1220) : AppColors.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text(
              'PHÂN TÍCH ÂM THANH GIỌNG HO',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Audio Waveform Card
                Card(
                  elevation: 0,
                  color: isDark ? const Color(0xFF131C2E) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ghi âm giọng nói và tiếng ho',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.primaryBlueDark,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Waveform Visualizer Area
                        Container(
                          height: 80,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F7F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: WaveformVisualizer(
                            isRecording: isRecording || isAnalyzing,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (!isRecording && !isAnalyzing && !hasResults) ...[
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Ấn nút Microphone bên dưới để bắt đầu ghi âm',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                        ] else if (isRecording || isAnalyzing) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isRecording) ...[
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _pulseController.value,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE74C3C),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                statusText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ] else if (hasResults) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đang phát lại bản thu âm... 🎧'),
                                      backgroundColor: AppColors.primaryBlue,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.play_arrow, size: 16),
                                label: const Text(
                                  'Nghe lại',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEBF2FF),
                                  foregroundColor: AppColors.primaryBlue,
                                  side: const BorderSide(color: AppColors.primaryBlue),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  elevation: 0,
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  context.read<AudioSedCubit>().reset();
                                },
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text(
                                  'Thu lại',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF7F8C8D),
                                  side: const BorderSide(color: Color(0xFF7F8C8D)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // AI Analysis Report Card
                if (hasResults) ...[
                  const SizedBox(height: 12),
                  _buildReportCard(context, state, isDark),
                ],
              ],
            ),
          ),
          floatingActionButton: SizedBox(
            width: 72,
            height: 72,
            child: FloatingActionButton(
              onPressed: isAnalyzing
                  ? null
                  : () {
                      if (isRecording) {
                        context.read<AudioSedCubit>().stopRecordingAndAnalyze('v1');
                      } else {
                        context.read<AudioSedCubit>().startRecording('v1');
                      }
                    },
              backgroundColor: isRecording ? Colors.red : AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: const CircleBorder(),
              child: isAnalyzing
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      isRecording ? Icons.stop : Icons.mic,
                      size: 32,
                    ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildReportCard(BuildContext context, AudioSedAnalysisSuccess state, bool isDark) {
    // Dynamically complete task if applicable
    context.read<Health360Cubit>().completeTask('night_task_1', 15);

    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF131C2E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phát hiện giọng nói nghẹt & ho khan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.primaryBlueDark,
              ),
            ),
            const SizedBox(height: 12),

            // Mucus Risk Alert Box (Red border and red background)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDEDEC),
                border: Border.all(color: const Color(0xFFE74C3C), width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text(
                        '⚠️',
                        style: TextStyle(fontSize: 14, color: Color(0xFFE74C3C)),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Dịch nhầy xoang sau: CAO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE74C3C),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Cảnh báo',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Obstruction Row (Yellow warning)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tắc nghẽn hô hấp',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primaryBlueDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF5E7),
                      border: Border.all(color: const Color(0xFFFDEBD0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Trung bình',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF39C12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Recommendation
            const Text(
              'Tần số âm thanh biểu hiện tắc nghẽn khoang xoang sàng sau rõ rệt. Khuyên dùng: Súc họng nước muối ấm, xịt mũi nước biển sâu trước khi ngủ.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
