import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/product.dart';
import '../cubit/recommendation_cubit.dart';
import '../cubit/recommendation_state.dart';

class SleepAssessmentPage extends StatefulWidget {
  const SleepAssessmentPage({super.key});

  @override
  State<SleepAssessmentPage> createState() => _SleepAssessmentPageState();
}

class _SleepAssessmentPageState extends State<SleepAssessmentPage> {
  // Form values
  String _snoringFreq = 'often';
  String _daytimeSleepiness = 'mild';
  String _apneaObserved = 'no';
  String _bodyType = 'normal';
  final List<String> _sleepSymptoms = [];

  // Mock sleep products for visual flair
  final List<Product> _sleepProducts = const [
    Product(
      name: 'Kẹo dẻo hỗ trợ giấc ngủ Melatonin Gummies 5mg',
      brand: 'Natrol (Mỹ)',
      price: '320.000đ',
      unit: 'Hộp 90 viên',
      iconType: ProductIconType.pill,
      desc: 'Bổ sung Melatonin tự nhiên giúp dễ ngủ, ngủ sâu giấc',
      tag: 'Bán chạy nhất',
    ),
    Product(
      name: 'Gối chống ngáy thông minh định hình cao cấp',
      brand: 'Liên Á (Việt Nam)',
      price: '450.000đ',
      unit: 'Cái',
      iconType: ProductIconType.droplet, // represented as support device
      desc: 'Thiết kế nâng đỡ cổ góc 15-30 độ, thông thoáng đường thở',
      tag: 'Lời khuyên bác sĩ',
    ),
    Product(
      name: 'Miếng dán cánh mũi hỗ trợ thở giảm ngáy',
      brand: 'Breathe Right (Mỹ)',
      price: '185.000đ',
      unit: 'Hộp 30 miếng',
      iconType: ProductIconType.spray,
      desc: 'Mở rộng đường thở cơ học, giảm nghẹt mũi, giảm ngáy',
      tag: 'Nhập khẩu Mỹ',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KHẢO SÁT GIẤC NGỦ'),
      ),
      body: BlocBuilder<RecommendationCubit, RecommendationState>(
        builder: (context, state) {
          if (state is RecommendationLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          if (state is RecommendationSleepSuccess) {
            return _buildResultReport(context, state.sleepData);
          }

          // Render the intake form
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(context),

                  // Q1: Snoring frequency
                  _buildQuestionCard(
                    context,
                    title: '1. Bạn ngáy thường xuyên như thế nào? *',
                    child: Row(
                      spacing: 8,
                      children: [
                        Expanded(child: _buildPill('rarely', 'Thỉnh thoảng', '1-2 đêm/tuần', _snoringFreq, (v) => setState(() => _snoringFreq = v))),
                        Expanded(child: _buildPill('often', 'Thường xuyên', '3-5 đêm/tuần', _snoringFreq, (v) => setState(() => _snoringFreq = v))),
                        Expanded(child: _buildPill('every_night', 'Mỗi đêm', '6-7 đêm/tuần', _snoringFreq, (v) => setState(() => _snoringFreq = v))),
                      ],
                    ),
                  ),

                  // Q2: Daytime sleepiness
                  _buildQuestionCard(
                    context,
                    title: '2. Ban ngày bạn có hay buồn ngủ không? *',
                    child: Row(
                      spacing: 8,
                      children: [
                        Expanded(child: _buildPill('none', 'Không', 'Tỉnh táo bình thường', _daytimeSleepiness, (v) => setState(() => _daytimeSleepiness = v))),
                        Expanded(child: _buildPill('mild', 'Hơi buồn ngủ', 'Ngủ gật khi xem TV', _daytimeSleepiness, (v) => setState(() => _daytimeSleepiness = v))),
                        Expanded(child: _buildPill('severe', 'Rất buồn ngủ', 'Ngủ gật khi lái xe/họp', _daytimeSleepiness, (v) => setState(() => _daytimeSleepiness = v))),
                      ],
                    ),
                  ),

                  // Q3: Apnea observed
                  _buildQuestionCard(
                    context,
                    title: '3. Người thân có thấy bạn ngưng thở khi ngủ? *',
                    child: Row(
                      spacing: 8,
                      children: [
                        Expanded(child: _buildSimplePill('no', 'Không / Không rõ', _apneaObserved, (v) => setState(() => _apneaObserved = v))),
                        Expanded(child: _buildSimplePill('yes', 'Có - Thỉnh thoảng', _apneaObserved, (v) => setState(() => _apneaObserved = v))),
                      ],
                    ),
                  ),

                  // Q4: BMI
                  _buildQuestionCard(
                    context,
                    title: '4. Thể trạng của bạn? *',
                    child: Row(
                      spacing: 8,
                      children: [
                        Expanded(child: _buildPill('normal', 'Bình thường', 'BMI < 25', _bodyType, (v) => setState(() => _bodyType = v))),
                        Expanded(child: _buildPill('overweight', 'Thừa cân', 'BMI 25-30', _bodyType, (v) => setState(() => _bodyType = v))),
                        Expanded(child: _buildPill('obese', 'Béo phì', 'BMI > 30', _bodyType, (v) => setState(() => _bodyType = v))),
                      ],
                    ),
                  ),

                  // Q5: Symptoms
                  _buildQuestionCard(
                    context,
                    title: '5. Triệu chứng kèm theo (nếu có):',
                    child: Column(
                      spacing: 8,
                      children: [
                        _buildCheckboxTile('dry_mouth', '🏜️ Khô miệng khi thức dậy'),
                        _buildCheckboxTile('morning_headache', '🤕 Đau đầu buổi sáng'),
                        _buildCheckboxTile('waking_up', '⏰ Hay tỉnh giấc giữa đêm'),
                        _buildCheckboxTile('concentration', '🧠 Khó tập trung, hay quên'),
                        _buildCheckboxTile('hypertension', '❤️‍🔥 Cao huyết áp'),
                        _buildCheckboxTile('nocturia', '🚽 Tiểu đêm nhiều lần'),
                      ],
                    ),
                  ),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9333EA), // Purple
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.nightlight_round, size: 20),
                          const SizedBox(width: 8),
                          const Flexible(
                            child: Text(
                              'NHẬN KHUYẾN NGHỊ GIẤC NGỦ',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      color: isDark ? theme.colorScheme.primaryContainer : const Color(0xFFFAF5FF), // Light purple
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? theme.colorScheme.outline : const Color(0xFFE9D5FF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 6,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.nights_stay, color: isDark ? theme.colorScheme.primary : const Color(0xFF9333EA), size: 20),
                const SizedBox(width: 8),
                Text(
                  'KHẢO SÁT GIẤC NGỦ LÂM SÀNG',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isDark ? theme.colorScheme.primary : const Color(0xFF7E22CE),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Text(
              'Hệ thống phát hiện tiếng ngáy hoặc thở bất thường. Hãy cung cấp thêm thông tin để sàng lọc hội chứng ngưng thở khi ngủ (OSA).',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? theme.colorScheme.onPrimaryContainer : const Color(0xFF6B21A8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, {required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildPill(String value, String title, String subtitle, String groupValue, ValueChanged<String> onChanged) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? theme.colorScheme.primaryContainer : const Color(0xFFFAF5FF))
              : (isDark ? theme.colorScheme.surface : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isDark ? theme.colorScheme.primary : const Color(0xFF9333EA))
                : (isDark ? theme.colorScheme.outline : Colors.grey.withValues(alpha: 0.2)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? (isDark ? theme.colorScheme.onPrimaryContainer : const Color(0xFF7E22CE))
                    : theme.colorScheme.onSurface,
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                color: isSelected
                    ? (isDark ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7) : const Color(0xFF6B21A8).withValues(alpha: 0.7))
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimplePill(String value, String label, String groupValue, ValueChanged<String> onChanged) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? theme.colorScheme.primaryContainer : const Color(0xFFFAF5FF))
              : (isDark ? theme.colorScheme.surface : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isDark ? theme.colorScheme.primary : const Color(0xFF9333EA))
                : (isDark ? theme.colorScheme.outline : Colors.grey.withValues(alpha: 0.2)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? (isDark ? theme.colorScheme.onPrimaryContainer : const Color(0xFF7E22CE))
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile(String value, String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isChecked = _sleepSymptoms.contains(value);
    return InkWell(
      onTap: () {
        setState(() {
          if (isChecked) {
            _sleepSymptoms.remove(value);
          } else {
            _sleepSymptoms.add(value);
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isChecked
              ? (isDark ? theme.colorScheme.primaryContainer : const Color(0xFFFAF5FF))
              : (isDark ? theme.colorScheme.surface : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isChecked
                ? (isDark ? theme.colorScheme.primary : const Color(0xFFE9D5FF))
                : (isDark ? theme.colorScheme.outline : Colors.grey.withValues(alpha: 0.2)),
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              activeColor: isDark ? theme.colorScheme.primary : const Color(0xFF9333EA),
              value: isChecked,
              onChanged: (val) {
                setState(() {
                  if (isChecked) {
                    _sleepSymptoms.remove(value);
                  } else {
                    _sleepSymptoms.add(value);
                  }
                });
              },
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? theme.colorScheme.onSurface : const Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    context.read<RecommendationCubit>().submitSleepAssessment(
          snoringFreq: _snoringFreq,
          daytimeSleepiness: _daytimeSleepiness,
          apneaObserved: _apneaObserved,
          bodyType: _bodyType,
          sleepSymptoms: _sleepSymptoms,
        );
  }

  Widget _buildResultReport(BuildContext context, Map<String, dynamic> data) {
    final theme = Theme.of(context);
    final classification = data['classification'] as Map<String, dynamic>;
    final riskInfo = classification['osa_risk'] as Map<String, dynamic>;
    final score = data['risk_score'] as int;
    final riskLevel = riskInfo['risk'] as String; // low, moderate, high
    final riskLevelVi = riskInfo['risk_vi'] as String;

    final recommendations = data['recommendations'] as List<dynamic>;
    final warnings = data['warnings'] as List<dynamic>;

    Color riskColor = Colors.green;
    if (riskLevel == 'moderate') {
      riskColor = Colors.orange;
    } else if (riskLevel == 'high') {
      riskColor = Colors.red;
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning box
            if (warnings.isNotEmpty)
              Column(
                spacing: 8,
                children: warnings.map((w) {
                  final isDarkWarning = theme.brightness == Brightness.dark;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkWarning ? Colors.red.withValues(alpha: 0.15) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDarkWarning ? Colors.red.withValues(alpha: 0.4) : const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚠️', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            w as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDarkWarning ? Colors.red.shade300 : const Color(0xFFB91C1C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            // Risk Gauge Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('📊', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          'Sàng lọc nguy cơ ngưng thở (OSA)',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                              Text(
                                'Độ nguy cơ: $riskLevelVi',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: riskColor),
                              ),
                              Text(
                                'Điểm số STOP-Bang: $score điểm',
                                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: riskColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$score / 15',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: riskColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Recommendations List
            Column(
              spacing: 12,
              children: recommendations.map((r) {
                final item = r as Map<String, dynamic>;
                final icon = item['category_icon'] as String? ?? '💡';
                final label = item['category_label'] as String? ?? '';
                final list = item['items'] as List<dynamic>;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                        : Colors.grey.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark
                          ? theme.colorScheme.outline
                          : Colors.grey.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Row(
                        children: [
                          Text(icon, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.brightness == Brightness.dark
                                  ? theme.colorScheme.onSurface
                                  : const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: list.map((bullet) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: theme.brightness == Brightness.dark
                                      ? theme.colorScheme.onSurfaceVariant
                                      : Colors.black54,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  bullet as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.brightness == Brightness.dark
                                        ? theme.colorScheme.onSurfaceVariant
                                        : const Color(0xFF4B5563),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            // Products section
            _buildSleepProductsSection(context),

            // Reset Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  context.read<RecommendationCubit>().resetSurvey();
                },
                child: const Text('LÀM LẠI KHẢO SÁT GIẤC NGỦ', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepProductsSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Row(
          children: [
            const Text('🛒', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              'Sản phẩm đề xuất hỗ trợ giấc ngủ',
              style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? theme.colorScheme.primary : AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        Column(
          spacing: 12,
          children: _sleepProducts.map((p) {
            final isDark = theme.brightness == Brightness.dark;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? theme.colorScheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? theme.colorScheme.outline : Colors.grey.withValues(alpha: 0.15),
                ),
                boxShadow: isDark ? null : const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? theme.colorScheme.primaryContainer : AppColors.primaryBlueLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      p.iconType == ProductIconType.pill
                          ? Icons.medication
                          : p.iconType == ProductIconType.droplet
                              ? Icons.airline_seat_flat
                              : Icons.health_and_safety,
                      color: isDark ? theme.colorScheme.primary : AppColors.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Row(
                          spacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? theme.colorScheme.primaryContainer : AppColors.primaryBlueLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                p.brand.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? theme.colorScheme.primary : AppColors.primaryBlue,
                                ),
                              ),
                            ),
                            if (p.tag != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? theme.colorScheme.secondaryContainer : AppColors.accentOrangeLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  p.tag!,
                                  style: TextStyle(
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? theme.colorScheme.secondary : AppColors.accentOrange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          p.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? theme.colorScheme.onSurface : const Color(0xFF111827),
                          ),
                        ),
                        Text(
                          '${p.unit} | ${p.desc}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? theme.colorScheme.onSurfaceVariant : Colors.grey,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              p.price,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isDark ? theme.colorScheme.secondary : AppColors.accentOrange,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Đã thêm "${p.name}" vào giỏ hàng!'),
                                    backgroundColor: AppColors.accentGreen,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Chọn mua', style: TextStyle(fontSize: 10)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
