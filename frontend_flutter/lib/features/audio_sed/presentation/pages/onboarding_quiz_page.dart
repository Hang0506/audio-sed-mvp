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
  // Local state for interactive choices matching specifications
  int _selectedQ1 = 0; // Default: Option 1 Selected
  int _selectedQ2 = 1; // Default: Option 2 Selected
  
  final List<bool> _selectedQ3 = [false, true, false, true, false, false];
  final List<bool> _selectedQ4 = [true, true, false, true, false, false, false, false];
  final List<bool> _selectedQ5 = [true, true, false, false, false, false];

  final List<String> _q1Options = [
    'Tôi đang có triệu chứng và muốn AI phân tích',
    'Tôi muốn theo dõi để phòng bệnh',
    'Tôi chỉ muốn nhận cảnh báo nguy cơ mỗi ngày',
    'Tôi muốn kiểm tra sức khỏe định kỳ',
  ];

  final List<String> _q2Options = [
    'Tôi hoàn toàn khỏe mạnh',
    'Tôi hiện chưa có triệu chứng',
    'Thỉnh thoảng mới khó chịu',
    'Tôi đang có triệu chứng',
  ];

  final List<String> _q3Options = [
    'Hay đi ngoài đường',
    'Làm việc văn phòng máy lạnh',
    'Thường xuyên tiếp xúc bụi',
    'Có trẻ nhỏ trong gia đình',
    'Có người bị dị ứng',
    'Muốn theo dõi sức khỏe hô hấp',
  ];

  final List<String> _q4Options = [
    'AQI xấu',
    'PM2.5 tăng',
    'Thời tiết thay đổi',
    'Độ ẩm thấp',
    'Phấn hoa cao',
    'Thực phẩm dễ kích ứng',
    'Nguy cơ ngủ ngáy',
    'Tất cả',
  ];

  final List<String> _q5Options = [
    'Không bị viêm mũi theo mùa',
    'Giảm nguy cơ dị ứng',
    'Ngủ ngon hơn',
    'Bảo vệ cổ họng',
    'Theo dõi sức khỏe gia đình',
    'Chỉ muốn nhận cảnh báo',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // FPT Long Châu Design System & App Theming Alignment
    final primaryColor = isDark ? const Color(0xFF38BDF8) : AppColors.primaryBlue;
    final appBarBg = isDark ? const Color(0xFF0C1220) : AppColors.primaryBlue;
    final scaffoldBg = isDark ? const Color(0xFF020617) : const Color(0xFFF4F7F6);
    final cardBg = isDark ? const Color(0xFF131C2E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E0E0);
    final titleColor = isDark ? Colors.white : AppColors.primaryBlueDark;
    final textColor = isDark ? const Color(0xFFF8FAFC) : Colors.black87;
    final unselectedTagBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F0F0);
    final unselectedTagText = isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600;

    const accentTeal = Color(0xFF00A896);
    final lightTealBg = isDark ? const Color(0xFF004D40) : const Color(0xFFE0F2F1);

    return BlocBuilder<Health360Cubit, Health360State>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            backgroundColor: appBarBg,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                context.read<Health360Cubit>().resetSurvey();
              },
            ),
            title: const Text(
              'KHẢO SÁT SỨC KHỎE AICARE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // QUESTION 1 (Single Choice / Radio Style)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? const Color(0x33000000) : const Color(0x0A000000),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎯 Mục tiêu của bạn hôm nay là gì?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600, // Semi-Bold
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(_q1Options.length, (index) {
                        final isSelected = _selectedQ1 == index;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedQ1 = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? accentTeal : borderColor,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                                color: cardBg,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? accentTeal : Colors.grey,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Center(
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: accentTeal,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _q1Options[index],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal, // Regular
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // QUESTION 2 (Single Choice / Radio Style)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? const Color(0x33000000) : const Color(0x0A000000),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✅ Hiện tại tình trạng sức khỏe của bạn như thế nào?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600, // Semi-Bold
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(_q2Options.length, (index) {
                        final isSelected = _selectedQ2 == index;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedQ2 = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? accentTeal : borderColor,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                                color: cardBg,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? accentTeal : Colors.grey,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Center(
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: accentTeal,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _q2Options[index],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal, // Regular
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // QUESTION 3 (Multiple Choice / Checkbox Style)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? const Color(0x33000000) : const Color(0x0A000000),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '👥 Bạn thuộc nhóm đối tượng nào? (Chọn nhiều mục)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600, // Semi-Bold
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(_q3Options.length, (index) {
                        final isSelected = _selectedQ3[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedQ3[index] = !_selectedQ3[index];
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? accentTeal : borderColor,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                                color: cardBg,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: isSelected ? accentTeal : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected ? accentTeal : Colors.grey,
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
                                      _q3Options[index],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal, // Regular
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // QUESTION 4 (Multiple Choice / Checkbox Style / Pill Tags)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? const Color(0x33000000) : const Color(0x0A000000),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔔 Bạn muốn AI cảnh báo điều gì? (Chọn nhiều mục)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600, // Semi-Bold
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_q4Options.length, (index) {
                          final isSelected = _selectedQ4[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (index == _q4Options.length - 1) {
                                  // 'Tất cả' toggles everything
                                  final turnOn = !_selectedQ4[index];
                                  for (int i = 0; i < _selectedQ4.length; i++) {
                                    _selectedQ4[i] = turnOn;
                                  }
                                } else {
                                  _selectedQ4[index] = !_selectedQ4[index];
                                  // Turn off 'Tất cả' if any item is deselected
                                  if (!_selectedQ4[index]) {
                                    _selectedQ4[_q4Options.length - 1] = false;
                                  }
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: isSelected ? lightTealBg : unselectedTagBg,
                                border: isSelected 
                                    ? Border.all(color: accentTeal, width: 1)
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) ...[
                                    const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: accentTeal,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    _q4Options[index],
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500, // Medium weight
                                      color: isSelected ? accentTeal : unselectedTagText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                // QUESTION 5 (Multiple Choice / Checkbox Style)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? const Color(0x33000000) : const Color(0x0A000000),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🏆 Mục tiêu sức khỏe bạn muốn đạt được?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600, // Semi-Bold
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(_q5Options.length, (index) {
                        final isSelected = _selectedQ5[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedQ5[index] = !_selectedQ5[index];
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? accentTeal : borderColor,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                                color: cardBg,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: isSelected ? accentTeal : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected ? accentTeal : Colors.grey,
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
                                      _q5Options[index],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal, // Regular
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 80), // Extra bottom padding for floating action bar
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0C1220) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating Reward Text
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🎁 Hoàn thành khảo sát nhận ngay ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500, // Medium weight
                        color: Color(0xFFF39C12),
                      ),
                    ),
                    Text(
                      '+50 Lxu',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500, // Medium weight
                        color: Color(0xFFF39C12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Primary action button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: state.isOnboardingLoading
                        ? null
                        : () {
                            // Compile and submit survey answers
                            final symptoms = <String>[];
                            final tags = <String>['ENT']; // AICare is always ENT tags
                            
                            // Map Q1 (Mục tiêu)
                            symptoms.add('muc_tieu_${_selectedQ1 + 1}');
                            
                            // Map Q2 (Tình trạng sức khỏe)
                            symptoms.add('suc_khoe_${_selectedQ2 + 1}');
                            
                            // Map Q3 (Nhóm đối tượng)
                            for (int i = 0; i < _selectedQ3.length; i++) {
                              if (_selectedQ3[i]) {
                                symptoms.add('doi_tuong_${i + 1}');
                              }
                            }
                            
                            // Map Q4 (AI Cảnh báo)
                            for (int i = 0; i < _selectedQ4.length; i++) {
                              if (_selectedQ4[i]) {
                                symptoms.add('canh_bao_${i + 1}');
                              }
                            }
                            
                            // Map Q5 (Mục tiêu sức khỏe)
                            for (int i = 0; i < _selectedQ5.length; i++) {
                              if (_selectedQ5[i]) {
                                symptoms.add('muc_tieu_suc_khoe_${i + 1}');
                              }
                            }

                            context.read<Health360Cubit>().submitSurvey(
                              symptoms: symptoms,
                              diseaseTags: tags,
                            );
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
                        : Text(
                            'TIẾP TỤC ĐỂ ĐÁNH GIÁ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF0F172A) : Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
