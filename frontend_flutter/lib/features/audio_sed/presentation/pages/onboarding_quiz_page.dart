import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../health_360/presentation/cubit/health_360_cubit.dart';
import '../../../health_360/presentation/cubit/health_360_state.dart';
import '../../../../app/theme/app_theme.dart';

class OnboardingQuizPage extends StatefulWidget {
  const OnboardingQuizPage({super.key});

  @override
  State<OnboardingQuizPage> createState() => _OnboardingQuizPageState();
}

class _OnboardingQuizPageState extends State<OnboardingQuizPage> {
  bool _isChronic = true; // Selected by default (Chronic vs Acute)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<Health360Cubit, Health360State>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF4F7F6),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF0C1220) : AppColors.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Go back or reset survey
                context.read<Health360Cubit>().resetSurvey();
              },
            ),
            title: const Text(
              'KHẢO SÁT SỨC KHỎE XOANG',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: Container(
                width: double.infinity,
                height: 4,
                color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade300,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(color: AppColors.primaryBlue),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Q1 Card
                Card(
                  elevation: 0,
                  color: isDark ? const Color(0xFF131C2E) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF1E293B) : Colors.transparent,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Câu 1/2',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMuted,
                              ),
                            ),
                            Text(
                              'Sau >',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? theme.colorScheme.primary : AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tình trạng viêm xoang hiện tại của bạn?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.navyText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Option A: Mãn tính
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isChronic = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? (_isChronic ? const Color(0xFF0C2540) : Colors.transparent)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isChronic
                                    ? AppColors.primaryBlue
                                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E0E0)),
                                width: _isChronic ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _isChronic ? AppColors.primaryBlue : Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                  child: _isChronic
                                      ? Center(
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.primaryBlue,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Mãn tính (Bị quanh năm, dễ tái phát)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: _isChronic ? FontWeight.bold : FontWeight.normal,
                                      color: _isChronic
                                          ? AppColors.primaryBlue
                                          : (isDark ? Colors.grey.shade400 : AppColors.textDark),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Option B: Cấp tính
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isChronic = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? (!_isChronic ? const Color(0xFF0C2540) : Colors.transparent)
                                  : (isDark ? const Color(0xFF131C2E) : const Color(0xFFF0F2F5)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: !_isChronic
                                    ? AppColors.primaryBlue
                                    : (isDark ? const Color(0xFF1E293B) : Colors.transparent),
                                width: !_isChronic ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: !_isChronic ? AppColors.primaryBlue : Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                  child: !_isChronic
                                      ? Center(
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.primaryBlue,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Cấp tính (Chỉ bị khi giao mùa/trời lạnh)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: !_isChronic ? FontWeight.bold : FontWeight.normal,
                                      color: !_isChronic
                                          ? AppColors.primaryBlue
                                          : (isDark ? Colors.grey.shade400 : AppColors.textMuted),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Q2 Card
                Card(
                  elevation: 0,
                  color: isDark ? const Color(0xFF131C2E) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF1E293B) : Colors.transparent,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Các triệu chứng bạn đang gặp phải?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.navyText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Symptom A: Nghẹt mũi
                        _buildCheckboxOption(
                          isSelected: state.symptoms['nose_weather'] == true,
                          label: 'Nghẹt mũi, khó thở',
                          onTap: () {
                            context.read<Health360Cubit>().toggleSymptom('nose_weather');
                          },
                          isDark: isDark,
                        ),
                        const SizedBox(height: 8),
                        // Symptom B: Đau nhức trán
                        _buildCheckboxOption(
                          isSelected: state.symptoms['throat_cough'] == true,
                          label: 'Đau nhức vùng trán, má',
                          onTap: () {
                            context.read<Health360Cubit>().toggleSymptom('throat_cough');
                          },
                          isDark: isDark,
                        ),
                        const SizedBox(height: 8),
                        // Symptom C: Chảy dịch sau
                        _buildCheckboxOption(
                          isSelected: state.symptoms['throat_snore'] == true,
                          label: 'Chảy dịch mũi sau (Đờm họng)',
                          onTap: () {
                            context.read<Health360Cubit>().toggleSymptom('throat_snore');
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.errorMsg != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    state.errorMsg!,
                    style: const TextStyle(color: Colors.red, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0C1220) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: state.isOnboardingLoading
                    ? null
                    : () {
                        context.read<Health360Cubit>().submitSurvey();
                      },
                child: state.isOnboardingLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'TIẾP TỤC',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckboxOption({
    required bool isSelected,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? (isSelected ? const Color(0xFF0C2540) : Colors.transparent)
              : (isSelected ? Colors.white : const Color(0xFFF0F2F5)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : (isDark ? const Color(0xFF1E293B) : Colors.transparent),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primaryBlue
                      : (isDark ? Colors.grey.shade400 : AppColors.textDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
