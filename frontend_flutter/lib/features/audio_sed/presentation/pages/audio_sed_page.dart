import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../health_360/presentation/cubit/health_360_cubit.dart';
import '../../../health_360/presentation/cubit/health_360_state.dart';
import 'onboarding_quiz_page.dart';
import '../widgets/environment_tab.dart';
import '../widgets/ai_assistant_tab.dart';
import '../widgets/missions_tab.dart';
import '../widgets/handbook_tab.dart';

class AudioSedPage extends StatefulWidget {
  const AudioSedPage({super.key});

  @override
  State<AudioSedPage> createState() => _AudioSedPageState();
}

class _AudioSedPageState extends State<AudioSedPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<Health360Cubit, Health360State>(
      builder: (context, state) {
        // Render Onboarding Quiz if not completed
        if (!state.isSurveyCompleted) {
          if (state.isOnboardingLoading) {
            return const OnboardingSyncView();
          }
          return const OnboardingQuizPage();
        }

        // Render main dashboard with segmented tab controller
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF4F7F6),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF0C1220) : AppColors.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Return or exit app context
                Navigator.of(context).maybePop();
              },
            ),
            title: const Text(
              'LONG CHÂU AICARE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                tooltip: 'Làm lại khảo sát',
                onPressed: () {
                  context.read<Health360Cubit>().resetSurvey();
                },
              ),
              IconButton(
                icon: const Icon(Icons.history, color: Colors.white, size: 20),
                tooltip: 'Báo cáo tuần',
                onPressed: () {
                  context.push('/history');
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Segmented Tab Bar Controller
              Container(
                width: double.infinity,
                height: 44,
                color: isDark ? const Color(0xFF0C1220) : Colors.white,
                child: Row(
                  children: [
                    _buildTabItem(context, state, 0, 'Môi Trường'),
                    _buildTabItem(context, state, 1, 'Trợ Lý AI'),
                    _buildTabItem(context, state, 2, 'Nhiệm Vụ'),
                    _buildTabItem(context, state, 3, 'Cẩm Nang'),
                  ],
                ),
              ),
              // Tab Body Content
              Expanded(
                child: _buildTabBody(state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabItem(BuildContext context, Health360State state, int tabIndex, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = state.currentTab == tabIndex;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          context.read<Health360Cubit>().setTab(tabIndex);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.primaryBlue
                    : (isDark ? Colors.grey.shade400 : const Color(0xFF7F8C8D)),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Container(
                width: 40,
                height: 2,
                color: AppColors.primaryBlue,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabBody(Health360State state) {
    final symptomText = _getSymptomProfile(state.symptoms);

    switch (state.currentTab) {
      case 0:
        return EnvironmentTab(coins: state.coins, symptomProfile: symptomText);
      case 1:
        return AIAssistantTab(coins: state.coins, symptomProfile: symptomText);
      case 2:
        return MissionsTab(state: state);
      case 3:
        return HandbookTab(coins: state.coins, symptomProfile: symptomText);
      default:
        return EnvironmentTab(coins: state.coins, symptomProfile: symptomText);
    }
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

// OnboardingSyncView displays the syncing state during onboarding setup
class OnboardingSyncView extends StatefulWidget {
  const OnboardingSyncView({super.key});

  @override
  State<OnboardingSyncView> createState() => _OnboardingSyncViewState();
}

class _OnboardingSyncViewState extends State<OnboardingSyncView> {
  int _currentStep = 0;
  final List<String> _steps = [
    'Đang đồng bộ hồ sơ bệnh lý xoang...',
    'Đang phân tích điều kiện khí hậu trạm thực tế...',
    'Đang đo chỉ số chất lượng không khí PM2.5...',
    'Đồng bộ hoàn tất! Xin chào bạn.',
  ];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (mounted) {
        setState(() {
          if (_currentStep < _steps.length - 1) {
            _currentStep++;
          } else {
            _timer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C1220) : Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _steps[_currentStep],
                  key: ValueKey<int>(_currentStep),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
