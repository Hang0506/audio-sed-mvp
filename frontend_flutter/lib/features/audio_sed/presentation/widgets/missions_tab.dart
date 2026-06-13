import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../health_360/presentation/cubit/health_360_cubit.dart';
import '../../../health_360/presentation/cubit/health_360_state.dart';
import 'dashboard_shared_widgets.dart';

class MissionsTab extends StatelessWidget {
  final Health360State state;

  const MissionsTab({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate completed count
    final nwDone = state.completedTasks['morn_task_1'] == true;
    final nfDone = state.completedTasks['noon_task_1'] == true;
    final tcDone = state.completedTasks['night_task_1'] == true;
    int completedCount = 0;
    if (nwDone) completedCount++;
    if (nfDone) completedCount++;
    if (tcDone) completedCount++;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardProfileRow(coins: state.coins, symptomProfile: _getSymptomProfile(state.symptoms)),
          const SizedBox(height: 12),
          const CriticalAlertBanner(),
          const SizedBox(height: 12),

          // Missions Tracker Card
          Card(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '🪙',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nhiệm vụ sức khỏe hôm nay: $completedCount/3',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primaryBlueDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: completedCount / 3.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Missions List
          // Mission 1
          _buildMissionRow(
            context: context,
            icon: '☁️',
            text: 'Đọc bản tin chỉ số môi trường sáng nay (+5 Lxu)',
            isCompleted: nwDone,
            onAction: () {
              context.read<Health360Cubit>().completeTask('morn_task_1', 5);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chúc mừng bạn đã hoàn thành nhiệm vụ và nhận +5 Lxu!'),
                  backgroundColor: AppColors.primaryBlue,
                ),
              );
            },
            actionText: 'Nhận Lxu',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          // Mission 2
          _buildMissionRow(
            context: context,
            icon: '📸',
            text: 'Quét ảnh món ăn trưa chống viêm xoang (+10 Lxu)',
            isCompleted: nfDone,
            onAction: () => context.push('/food-checker'),
            actionText: 'Làm ngay',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          // Mission 3
          _buildMissionRow(
            context: context,
            icon: '🎙️',
            text: 'Ghi âm phân tích giọng nói buổi tối (+15 Lxu)',
            isCompleted: tcDone,
            onAction: () => context.push('/audio-analysis'),
            actionText: 'Làm ngay',
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // Loyalty Title
          const Text(
            'ĐỔI QUÀ LOYALTY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Quick Rewards Marketplace
          Row(
            children: [
              Expanded(
                child: _buildRewardCard(
                  context: context,
                  icon: '🧴',
                  title: 'Voucher giảm 20k xịt mũi',
                  cost: 100,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRewardCard(
                  context: context,
                  icon: '😷',
                  title: 'Voucher FreeShip đơn thuốc',
                  cost: 200,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionRow({
    required BuildContext context,
    required String icon,
    required String text,
    required bool isCompleted,
    required VoidCallback onAction,
    required String actionText,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : AppColors.primaryBlueDark,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            isCompleted
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Đã nhận',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  )
                : OutlinedButton(
                    onPressed: onAction,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      actionText,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard({
    required BuildContext context,
    required String icon,
    required String title,
    required int cost,
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
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 72,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF4F7F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.primaryBlueDark,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$cost Lxu',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF39C12),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 28,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  if (state.coins < cost) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Số dư Lxu của bạn không đủ!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  final success = await context.read<Health360Cubit>().redeemVoucher(title, cost);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đổi quà thành công: $title!'),
                        backgroundColor: const Color(0xFF2ECC71),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Đổi quà',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSymptomProfile(Map<String, bool> symptoms) {
    final nw = symptoms['nose_weather'] ?? false;
    final nf = symptoms['nose_food'] ?? false;
    final tc = symptoms['throat_cough'] ?? false;
    final ts = symptoms['throat_snore'] ?? false;

    if (nw && nf && tc && ts) return 'Hồ sơ: SÀNG LỌC TMH';
    if (nw && tc && ts) return 'Hồ sơ: XOANG & HO NGÁY';
    if (nw && ts) return 'Hồ sơ: XOANG & NGỦ NGÁY';
    if (nw && tc) return 'Hồ sơ: XOANG & HO KHAN';
    if (nw) return 'Hồ sơ: Xoang Mãn Tính';
    if (tc || ts) return 'Hồ sơ: HO KHAN / NGÁY ĐÊM';
    if (nf) return 'Hồ sơ: KÍCH ỨNG THỨC ĂN';
    return 'Hồ sơ: CHƯA XÁC ĐỊNH';
  }
}
