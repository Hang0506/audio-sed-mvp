import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import 'dashboard_shared_widgets.dart';

class HandbookTab extends StatelessWidget {
  final int coins;
  final String symptomProfile;

  const HandbookTab({
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

          // Personalized Article Feed
          // Article 1
          _buildArticleCard(
            context: context,
            icon: '📖',
            title: '5 Bước Vệ Sinh Mũi Xoang Đúng Cách Tại Nhà Bằng Nước Muối',
            readTime: 'Thời gian đọc: 3 phút',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          // Article 2
          _buildArticleCard(
            context: context,
            icon: '🍵',
            title: 'Các Loại Trà Thảo Mộc Tự Nhiên Giúp Giảm Nghẹt Mũi Tức Thì',
            readTime: 'Thời gian đọc: 4 phút',
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Emergency O2O Pharmacist Call Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEBF2FF),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFD0E1FD),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '🧑‍⚕️',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Cần Tư Vấn Thuốc Ngay?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primaryBlueDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Kết nối ngay với dược sĩ chuyên môn Long Châu gần nhất.',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đang kết nối cuộc gọi đến dược sĩ Long Châu... 📞'),
                        backgroundColor: AppColors.primaryBlue,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryBlue,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.phone,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'GỌI ĐIỆN',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard({
    required BuildContext context,
    required String icon,
    required String title,
    required String readTime,
    required bool isDark,
  }) {
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF131C2E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
        ),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đang mở bài viết: "$title"...'),
              backgroundColor: AppColors.primaryBlue,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF4F7F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.primaryBlueDark,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      readTime,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
