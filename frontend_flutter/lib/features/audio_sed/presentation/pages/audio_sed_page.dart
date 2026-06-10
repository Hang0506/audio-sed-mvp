import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/cubit/theme_cubit.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/timeline_chart.dart';
import '../../../../shared/widgets/wave_visualizer.dart';
import '../../domain/entities/analysis_result.dart';
import '../cubit/audio_sed_cubit.dart';
import '../cubit/audio_sed_state.dart';

class AudioSedPage extends StatefulWidget {
  const AudioSedPage({super.key});

  @override
  State<AudioSedPage> createState() => _AudioSedPageState();
}

class _AudioSedPageState extends State<AudioSedPage> {
  String _selectedMode = 'v1'; // 'v1' or 'v2'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('HỆ THỐNG AI'),
            Text(
              'PHÂN TÍCH TIẾNG HO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          ),
        ],
      ),
      body: BlocConsumer<AudioSedCubit, AudioSedState>(
        listener: (context, state) {
          if (state is AudioSedError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final samples = _getSamplesFromState(state);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mode Selector Header
                  _buildModeSelector(context),

                  // Health Consult Banner
                  _buildBannerCard(context, state),

                  // Left/Right split represented vertically on mobile
                  _buildAudioSedCard(context, state),

                  // Sound samples selection
                  _buildSamplesCard(context, samples),

                  // AI Analysis results
                  _buildAnalysisCard(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> _getSamplesFromState(AudioSedState state) {
    if (state is AudioSedSamplesLoaded) {
      return state.samples;
    } else if (state is AudioSedAnalysisSuccess) {
      return state.samples;
    } else if (state is AudioSedError) {
      return state.samples;
    }
    return [];
  }

  Widget _buildModeSelector(BuildContext context) {
    final theme = Theme.of(context);
    final isV1 = _selectedMode == 'v1';

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() => _selectedMode = 'v1');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isV1 ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Phát hiện ho (V1)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isV1 ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() => _selectedMode = 'v2');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isV1 ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Phân tích khan/đờm (V2)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: !isV1 ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context, AudioSedState state) {
    if (state is! AudioSedAnalysisSuccess) return const SizedBox.shrink();

    final result = state.result;
    final hasCough = result.hasCough;
    final hasSnore = result.events.any((e) => e.className == 'Snoring');

    if (hasCough) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.accentGreenLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.accentGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phát Hiện Triệu Chứng Ho',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'Nhận tư vấn đề xuất sản phẩm thuốc phù hợp.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.push('/assessment', extra: result);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
              ),
              child: const Text('Khảo sát', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      );
    } else if (hasSnore) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF5FF), // Light purple
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9D5FF)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.nightlight_round, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phát Hiện Tiếng Ngáy/Thở',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'Đoạn ghi âm có tiếng ngáy. Sàng lọc ngưng thở lúc ngủ.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.push('/sleep-assessment');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9333EA),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
              ),
              child: const Text('Khảo sát', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildAudioSedCard(BuildContext context, AudioSedState state) {
    final theme = Theme.of(context);
    final isRecording = state is AudioSedRecording;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 16,
          children: [
            Row(
              children: [
                const Text('🎙️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Kiểm tra tiếng ho',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            
            // Recorder Card UI
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.light
                    ? const Color(0xFFF8FAFC)
                    : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Column(
                spacing: 12,
                children: [
                  const Text(
                    'THU ÂM TRỰC TIẾP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  // Microphone Button
                  InkWell(
                    onTap: () {
                      if (isRecording) {
                        context.read<AudioSedCubit>().stopRecordingAndAnalyze(_selectedMode);
                      } else {
                        context.read<AudioSedCubit>().startRecording(_selectedMode);
                      }
                    },
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: isRecording ? Colors.red : AppColors.accentOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isRecording ? Colors.red : AppColors.accentOrange)
                                .withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Icon(
                        isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  
                  Text(
                    isRecording
                        ? 'Đang thu âm... ${state.elapsedSeconds}s'
                        : 'Nhấn để thu âm 5 giây',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isRecording ? Colors.red : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            
            // Waveform visualizer
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                const Text(
                  'TRỰC QUAN SÓNG ÂM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                WaveformVisualizer(isRecording: isRecording),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSamplesCard(BuildContext context, List<String> samples) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Row(
              children: [
                const Text('📁', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Mẫu âm thanh kiểm thử',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            
            if (samples.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Không có mẫu âm thanh nào.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: samples.map((filename) {
                  String icon = '🎵';
                  if (filename.contains('cough')) icon = '😷';
                  if (filename.contains('breathing')) icon = '🫁';
                  if (filename.contains('snoring')) icon = '💤';

                  return OutlinedButton.icon(
                    onPressed: () {
                      context
                          .read<AudioSedCubit>()
                          .analyzeSampleFile(filename, _selectedMode);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Text(icon, style: const TextStyle(fontSize: 13)),
                    label: Text(
                      filename,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context, AudioSedState state) {
    final theme = Theme.of(context);

    if (state is AudioSedSamplesLoading || state is AudioSedInitial) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const CircularProgressIndicator(strokeWidth: 2.5),
              const SizedBox(width: 16),
              Text(
                'Đang tải danh sách mẫu...',
                style: theme.textTheme.bodyMedium,
              )
            ],
          ),
        ),
      );
    }

    if (state is AudioSedAnalyzing) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            spacing: 12,
            children: [
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryBlue,
                  strokeWidth: 3,
                ),
              ),
              Text(
                'Đang chẩn đoán giọng ho bằng mô hình AI...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is AudioSedAnalysisSuccess) {
      final result = state.result;
      final timeMs = result.inferenceTimeMs;
      final duration = result.durationSec;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('📊', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        'Phân tích từ AI',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '⏱️ ${timeMs.toStringAsFixed(0)}ms | ${duration.toStringAsFixed(1)}s audio',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              
              // Events list
              if (result.events.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '💨 Không phát hiện âm thanh hô hấp bất thường (ho, rít, thở dốc).',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                )
              else
                Column(
                  children: result.events.map((event) {
                    final color = TimelineChart.classColors[event.className] ?? Colors.blueGrey;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  event.classNameVi,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${event.start.toStringAsFixed(1)}s – ${event.end.toStringAsFixed(1)}s',
                                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${(event.confidence * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              // V2 dry/wet breakdown
              if (state.mode == 'v2' && result.coughTypeAnalysis != null)
                _buildV2CoughBreakdown(context, result.coughTypeAnalysis!),

              // Timeline graph
              if (result.events.isNotEmpty)
                TimelineChart(events: result.events, durationSec: duration),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          spacing: 8,
          children: [
            const Center(
              child: Text(
                'Chưa có dữ liệu âm thanh.',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
              ),
            ),
            Text(
              'Vui lòng bấm nút mic hoặc chọn mẫu kiểm thử để bắt đầu phân tích.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildV2CoughBreakdown(BuildContext context, CoughTypeAnalysis ct) {
    final dryPct = ct.probabilities['dry'] ?? 0.0;
    final wetPct = ct.probabilities['wet'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            children: [
              Text(
                ct.coughType == 'dry' ? '🌵' : '💧',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87, fontSize: 13),
                        children: [
                          const TextSpan(text: 'Chẩn đoán ho: ', style: TextStyle(fontWeight: FontWeight.w500)),
                          TextSpan(
                            text: ct.coughTypeVi,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Độ chính xác AI: ${(ct.confidence * 100).toStringAsFixed(0)}%',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Dry progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ho khan', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                  Text('${(dryPct * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: dryPct,
                  backgroundColor: Colors.white,
                  color: AppColors.accentOrange,
                  minHeight: 6,
                ),
              ),
            ],
          ),

          // Wet progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ho có đờm', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                  Text('${(wetPct * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: wetPct,
                  backgroundColor: Colors.white,
                  color: AppColors.primaryBlue,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
