import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/entities/sound_event.dart';
import '../../domain/entities/cough_assessment.dart';
import '../cubit/recommendation_cubit.dart';
import '../cubit/recommendation_state.dart';

class AssessmentPage extends StatefulWidget {
  final AnalysisResult analysisResult;

  const AssessmentPage({
    super.key,
    required this.analysisResult,
  });

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  // Form selections
  late String _coughType;
  String _duration = 'acute';
  String _subject = 'adult';
  String _coughFrequency = 'moderate';
  final List<String> _redFlags = [];
  bool _nightCough = false;
  bool _postFlu = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill cough type if V2 AI model has already detected it
    _coughType = widget.analysisResult.coughTypeAnalysis?.coughType ?? 'dry';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('KHẢO SÁT LÂM SÀNG'),
      ),
      body: BlocConsumer<RecommendationCubit, RecommendationState>(
        listener: (context, state) {
          if (state is RecommendationSuccess) {
            context.pushReplacement('/recommendation', extra: state.result);
          } else if (state is RecommendationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is RecommendationLoading;

          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    spacing: 20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(context),

                      // Q1: Cough Type
                      _buildQuestionCard(
                        context,
                        title: '1. Triệu chứng ho của bạn như thế nào? *',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildChoicePill('dry', '🌵 Ho khan', 'Họng khô, không đờm', _coughType, (v) => setState(() => _coughType = v)),
                            _buildChoicePill('phlegm', '💧 Ho có đờm', 'Dịch nhầy, khò khè', _coughType, (v) => setState(() => _coughType = v)),
                            _buildChoicePill('irritant', '💨 Ho kích ứng', 'Khói bụi, máy lạnh', _coughType, (v) => setState(() => _coughType = v)),
                            _buildChoicePill('allergic', '🌸 Ho dị ứng', 'Thời tiết, phấn hoa', _coughType, (v) => setState(() => _coughType = v)),
                            _buildChoicePill('whooping', '⚠️ Ho gà / Khác', 'Ho rít dài, quặn ngực', _coughType, (v) => setState(() => _coughType = v)),
                          ],
                        ),
                      ),

                      // Q2: Duration
                      _buildQuestionCard(
                        context,
                        title: '2. Bạn đã ho bao lâu rồi? *',
                        child: Row(
                          spacing: 8,
                          children: [
                            Expanded(child: _buildSimplePill('acute', 'Cấp tính', 'Dưới 3 tuần', _duration, (v) => setState(() => _duration = v))),
                            Expanded(child: _buildSimplePill('subacute', 'Bán cấp', 'Từ 3-8 tuần', _duration, (v) => setState(() => _duration = v))),
                            Expanded(child: _buildSimplePill('chronic', 'Mạn tính', 'Trên 8 tuần', _duration, (v) => setState(() => _duration = v))),
                          ],
                        ),
                      ),

                      // Q3: Subject
                      _buildQuestionCard(
                        context,
                        title: '3. Đối tượng cần kiểm tra điều trị là ai? *',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildIconChoice('adult', Icons.person, 'Người lớn', _subject, (v) => setState(() => _subject = v)),
                            _buildIconChoice('child', Icons.child_care, 'Trẻ em (2-12t)', _subject, (v) => setState(() => _subject = v)),
                            _buildIconChoice('infant', Icons.baby_changing_station, 'Trẻ nhỏ (<2t)', _subject, (v) => setState(() => _subject = v)),
                            _buildIconChoice('pregnant', Icons.pregnant_woman, 'Bà bầu / Mẹ', _subject, (v) => setState(() => _subject = v)),
                            _buildIconChoice('elderly', Icons.elderly, 'Người cao tuổi', _subject, (v) => setState(() => _subject = v)),
                            _buildIconChoice('chronic_disease', Icons.medical_services, 'Có bệnh nền', _subject, (v) => setState(() => _subject = v)),
                          ],
                        ),
                      ),

                      // Q4: Severity
                      _buildQuestionCard(
                        context,
                        title: '4. Mức độ ho cảm nhận thế nào? *',
                        child: Row(
                          spacing: 8,
                          children: [
                            Expanded(child: _buildIconChoice('mild', Icons.sentiment_satisfied, 'Nhẹ (Húng hắng)', _coughFrequency, (v) => setState(() => _coughFrequency = v))),
                            Expanded(child: _buildIconChoice('moderate', Icons.sentiment_neutral, 'Vừa (Ngắt quãng)', _coughFrequency, (v) => setState(() => _coughFrequency = v))),
                            Expanded(child: _buildIconChoice('severe', Icons.sentiment_very_dissatisfied, 'Nặng (Liên tục)', _coughFrequency, (v) => setState(() => _coughFrequency = v))),
                          ],
                        ),
                      ),

                      // Q5: Red Flags
                      _buildQuestionCard(
                        context,
                        title: '5. Dấu hiệu cảnh báo nguy hiểm đi kèm (nếu có):',
                        child: Column(
                          spacing: 8,
                          children: [
                            _buildCheckboxTile('bloody_cough', '🩸 Ho ra máu'),
                            _buildCheckboxTile('difficulty_breathing', '🫁 Khó thở / Thở rít'),
                            _buildCheckboxTile('prolonged_fever', '🌡️ Sốt cao kéo dài'),
                            _buildCheckboxTile('chest_pain', '💥 Đau buốt tức ngực'),
                            _buildCheckboxTile('cyanosis', '🟣 Tím tái môi/đầu chi'),
                            _buildCheckboxTile('weight_loss', '⚖️ Sụt cân bất thường'),
                            _buildCheckboxTile('prolonged_cough', '⏰ Cơn ho kéo dài liên tục nhiều tuần'),
                          ],
                        ),
                      ),

                      // Extra Checkboxes
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            children: [
                              SwitchListTile(
                                activeThumbColor: AppColors.primaryBlue,
                                title: const Text('🌙 Hay ho về đêm', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                value: _nightCough,
                                onChanged: (val) => setState(() => _nightCough = val),
                              ),
                              const Divider(),
                              SwitchListTile(
                                activeThumbColor: AppColors.primaryBlue,
                                title: const Text('🤧 Ho khan hậu cảm cúm / Covid', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                value: _postFlu,
                                onChanged: (val) => setState(() => _postFlu = val),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentOrange,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.security, size: 20),
                          label: const Text('NHẬN KHUYẾN NGHỊ Y KHOA & ĐỀ XUẤT THUỐC'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black38,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryBlue),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      color: AppColors.primaryBlueLight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 6,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.healing, color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'BỔ SUNG THÔNG TIN LÂM SÀNG',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Text(
              'Cung cấp thông tin triệu chứng chính xác để nhận khuyến nghị thuốc và phác đồ điều trị an toàn từ dược sĩ.',
              style: TextStyle(fontSize: 11, color: AppColors.primaryBlueDark),
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

  Widget _buildChoicePill(String value, String title, String subtitle, String groupValue, ValueChanged<String> onChanged) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: (MediaQuery.of(context).size.width - 48) / 2, // 2 items per row approximation
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlueLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 9, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimplePill(String value, String title, String subtitle, String groupValue, ValueChanged<String> onChanged) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlueLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 8, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconChoice(String value, IconData icon, String label, String groupValue, ValueChanged<String> onChanged) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlueLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primaryBlue : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxTile(String value, String title) {
    final isChecked = _redFlags.contains(value);
    return InkWell(
      onTap: () {
        setState(() {
          if (isChecked) {
            _redFlags.remove(value);
          } else {
            _redFlags.add(value);
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isChecked ? Colors.red.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isChecked ? Colors.red.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              activeColor: Colors.red,
              value: isChecked,
              onChanged: (val) {
                setState(() {
                  if (isChecked) {
                    _redFlags.remove(value);
                  } else {
                    _redFlags.add(value);
                  }
                });
              },
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    // Collect stats from widget's analysis result
    final events = widget.analysisResult.events.where((e) => e.className == 'Cough').toList();
    final double maxConf = events.isNotEmpty
        ? events.map((e) => eventToConfidence(e)).reduce((a, b) => a > b ? a : b)
        : 0.5;

    final assessment = CoughAssessment(
      coughType: _coughType,
      duration: _duration,
      subject: _subject,
      coughFrequency: _coughFrequency,
      redFlags: _redFlags,
      nightCough: _nightCough,
      postFlu: _postFlu,
      audioHasCough: widget.analysisResult.hasCough,
      audioCoughCount: events.length,
      audioConfidence: maxConf,
    );

    context.read<RecommendationCubit>().submitCoughAssessment(assessment);
  }

  double eventToConfidence(SoundEvent e) {
    return e.confidence;
  }
}
