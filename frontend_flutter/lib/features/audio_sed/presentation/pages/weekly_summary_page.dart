import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../health_360/presentation/cubit/health_360_cubit.dart';
import '../../../health_360/presentation/cubit/health_360_state.dart';
import '../../../../app/theme/app_theme.dart';

class WeeklySummaryPage extends StatelessWidget {
  const WeeklySummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<Health360Cubit, Health360State>(
      builder: (context, state) {
        final String coughBefore = state.weeklySummary?['cough_before'] as String? ?? '6 lần/đêm';
        final String coughAfter = state.weeklySummary?['cough_after'] as String? ?? '1 lần/đêm';
        final String snoreBefore = state.weeklySummary?['snore_before'] as String? ?? '42 phút';
        final String snoreAfter = state.weeklySummary?['snore_after'] as String? ?? '12 phút';

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
              'TỔNG KẾT TUẦN',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📅 Báo cáo chu kỳ tuần',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.navyText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'TRIỆU CHỨNG ĐANG GIẢM DẦN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Đối chiếu lâm sàng dựa trên khảo sát Tai-Mũi-Họng ban đầu.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),

                // Comparison Stats Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131C2E) : Colors.white,
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('🎙️', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 6),
                          Text(
                            'Kết quả Audio AI ghi âm ban đêm',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Comparison 1: Cough Count
                      _buildComparisonGrid(
                        context: context,
                        title: 'CƠN HO KHAN',
                        before: coughBefore,
                        beforeColor: const Color(0xFFEF4444),
                        after: coughAfter,
                        afterColor: const Color(0xFF10B981),
                      ),
                      const SizedBox(height: 12),

                      // Comparison 2: Snoring duration
                      _buildComparisonGrid(
                        context: context,
                        title: 'TIẾNG THỞ NGÁY',
                        before: snoreBefore,
                        beforeColor: const Color(0xFFFB923C),
                        after: snoreAfter,
                        afterColor: const Color(0xFF10B981),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Weekly reward claim
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF241610), const Color(0xFF131C2E)]
                          : [const Color(0xFFFFF5F0), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: const Color(0xFFFB923C).withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Thành quả bảo vệ hệ hô hấp',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentOrange,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '🌟 +450 L-POINT',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.accentOrange,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: state.isWeeklyBonusClaimed
                              ? null
                              : () {
                                  context.read<Health360Cubit>().claimWeeklyBonus();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã nhận +450 L-Point thưởng tuần! 🌟'),
                                      backgroundColor: Color(0xFF10B981),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentOrange,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                            disabledForegroundColor: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: Text(
                            state.isWeeklyBonusClaimed
                                ? '✓ ĐÃ NHẬN L-POINT THƯỞNG TUẦN'
                                : 'NHẬN THƯỞNG L-POINT TUẦN CỦA LONG CHÂU',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComparisonGrid({
    required BuildContext context,
    required String title,
    required String before,
    required Color beforeColor,
    required String after,
    required Color afterColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  before,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: beforeColor,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'HIỆN TẠI',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  after,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: afterColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
