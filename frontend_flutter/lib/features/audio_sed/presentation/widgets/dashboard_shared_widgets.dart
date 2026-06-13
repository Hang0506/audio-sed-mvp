import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

class DashboardProfileRow extends StatelessWidget {
  final int coins;
  final String symptomProfile;

  const DashboardProfileRow({
    super.key,
    required this.coins,
    required this.symptomProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE5E7EB),
              ),
              child: const Center(
                child: Text(
                  '👤',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Xin chào, Nguyễn Văn A',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primaryBlueDark,
                  ),
                ),
                Text(
                  'Thành viên Vàng | $coins Lxu',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFF39C12),
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF2FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            symptomProfile,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }
}

class CriticalAlertBanner extends StatelessWidget {
  const CriticalAlertBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDEDEC),
        border: Border.all(color: const Color(0xFFFADBD8)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚠️',
            style: TextStyle(fontSize: 14, color: Color(0xFFE74C3C)),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'CẢNH BÁO XOANG: Độ ẩm giảm sâu 45% (Hanh khô) & Chỉ số bụi mịn PM2.5 vượt ngưỡng 150. Nguy cơ kích ứng biểu mô xoang cao!',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE74C3C),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
