import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import 'dashboard_shared_widgets.dart';

class AIAssistantTab extends StatelessWidget {
  final int coins;
  final String symptomProfile;

  const AIAssistantTab({
    super.key,
    required this.coins,
    required this.symptomProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardProfileRow(coins: coins, symptomProfile: symptomProfile),
          const SizedBox(height: 12),
          const CriticalAlertBanner(),
          const SizedBox(height: 12),

          // AI Food Checker Gateway Card
          GestureDetector(
            onTap: () => context.push('/food-checker'),
            child: Card(
              elevation: 0,
              color: isDark ? const Color(0xFF131C2E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF4F7F6),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Center(
                        child: Text(
                          '📸',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kiểm Tra Đồ Ăn Chống Viêm',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.primaryBlueDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Quét ảnh hoặc tra cứu nhanh món ăn có nguy cơ gây tích tụ dịch nhầy xoang.',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Audio AI Analysis Gateway Card
          GestureDetector(
            onTap: () => context.push('/audio-analysis'),
            child: Card(
              elevation: 0,
              color: isDark ? const Color(0xFF131C2E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF4F7F6),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Center(
                        child: Text(
                          '🎙️',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phân Tích Âm Thanh Giọng Ho',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.primaryBlueDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Thu âm giọng nói và tiếng ho để nhận diện sớm dấu hiệu nghẹt mũi, đờm họng sau.',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
