import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/cubit/theme_cubit.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/timeline_chart.dart';
import '../../../../shared/widgets/wave_visualizer.dart';
import '../../domain/entities/analysis_result.dart';
import '../cubit/audio_sed_cubit.dart';
import '../cubit/audio_sed_state.dart';
import 'package:frontend_flutter/features/health_360/presentation/cubit/health_360_cubit.dart';
import 'package:frontend_flutter/features/health_360/presentation/cubit/health_360_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

class AudioSedPage extends StatefulWidget {
  const AudioSedPage({super.key});

  @override
  State<AudioSedPage> createState() => _AudioSedPageState();
}

class _AudioSedPageState extends State<AudioSedPage> {
  String _selectedMode = 'v1'; // 'v1' or 'v2'

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isInitializingCamera = false;
  bool _isCameraActive = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initializeCamera() async {
    if (_isInitializingCamera || _isCameraInitialized) return;
    setState(() {
      _isInitializingCamera = true;
      _isCameraActive = true;
    });
    try {
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        final requestStatus = await Permission.camera.request();
        if (!requestStatus.isGranted) {
          if (mounted) {
            setState(() {
              _isInitializingCamera = false;
              _isCameraActive = false;
            });
          }
          return;
        }
      }

      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        final controller = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
        );
        _cameraController = controller;
        await controller.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
            _isInitializingCamera = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isInitializingCamera = false;
            _isCameraActive = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _isInitializingCamera = false;
          _isCameraActive = false;
        });
      }
    }
  }

  void _disposeCamera() {
    if (mounted) {
      setState(() {
        _isCameraActive = false;
        _isCameraInitialized = false;
        _isInitializingCamera = false;
      });
    } else {
      _isCameraActive = false;
      _isCameraInitialized = false;
      _isInitializingCamera = false;
    }
    if (_cameraController != null) {
      final controller = _cameraController;
      _cameraController = null;
      controller?.dispose();
    }
  }

  @override
  void dispose() {
    _disposeCamera();
    super.dispose();
  }

  String _getSymptomProfile(Map<String, bool> symptoms) {
    final nw = symptoms['nose_weather'] ?? false;
    final nf = symptoms['nose_food'] ?? false;
    final tc = symptoms['throat_cough'] ?? false;
    final ts = symptoms['throat_snore'] ?? false;

    if (nw && nf && tc && ts) return 'SÀNG LỌC TAI - MŨI - HỌNG';
    if (nw && tc && ts) return 'VIÊM XOANG & HO NGÁY ĐÊM';
    if (nw && ts) return 'VIÊM MŨI DỊ ỨNG & NGỦ NGÁY';
    if (nw && tc) return 'VIÊM MŨI DỊ ỨNG & HO KHAN ĐÊM';
    if (nw) return 'VIÊM MŨI DỊ ỨNG THỜI TIẾT';
    if (tc || ts) return 'HO KHAN KỊCH PHÁT / NGỦ NGÁY';
    if (nf) return 'KÍCH ỨNG DỊ NGUYÊN THỨC ĂN';
    return 'CHƯA XÁC ĐỊNH TRIỆU CHỨNG';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<Health360Cubit, Health360State>(
      listenWhen: (previous, current) =>
          previous.timeOfDay != current.timeOfDay ||
          previous.currentTab != current.currentTab ||
          previous.isSurveyCompleted != current.isSurveyCompleted ||
          (previous.isScanning && !current.isScanning),
      listener: (context, state) {
        if (state.isSurveyCompleted && state.currentTab == 0 && state.timeOfDay == 'noon') {
          if (state.scannedFoodKey != null && !state.isScanning) {
            _disposeCamera();
          }
        } else {
          _disposeCamera();
        }
      },
      child: BlocBuilder<Health360Cubit, Health360State>(
        builder: (context, state) {
          if (!state.isSurveyCompleted) {
            if (state.isOnboardingLoading) {
              return const OnboardingSyncView();
            }
            return _buildSurveyView(state);
          }

          return Scaffold(
            appBar: _buildDashboardAppBar(context, state, isDark),
            body: _buildTabContent(state),
            bottomNavigationBar: _buildBottomNavigationBar(context, state),
          );
        },
      ),
    );
  }

  // ==========================================
  // SURVEY SCREEN & ONBOARDING
  // ==========================================

  Widget _buildSurveyView(Health360State state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SÀNG LỌC LÂM SÀNG'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chỉ Số Tai-Mũi-Họng',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDark ? theme.colorScheme.primary : AppColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cặp triệu chứng nào đang làm phiền bạn nhất?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Chọn để AI kích hoạt cảm biến đo lường tương ứng phần cứng.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // NOSE SYMPTOMS GROUP
              const Text(
                '👃 NHÓM TRIỆU CHỨNG MŨI (NOSE)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF38BDF8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              _buildSurveyCheckboxTile(
                value: state.symptoms['nose_weather'] ?? false,
                title: 'Hắt hơi liên tục khi thời tiết giao mùa',
                subtitle: '➔ Kích hoạt Widget Định vị & Đo chỉ số thời tiết / PM2.5',
                onChanged: () => context.read<Health360Cubit>().toggleSymptom('nose_weather'),
                accentColor: const Color(0xFF38BDF8),
              ),
              _buildSurveyCheckboxTile(
                value: state.symptoms['nose_food'] ?? false,
                title: 'Nghẹt mũi, ngứa họng sau ăn đồ lạ, đồ lạnh',
                subtitle: '➔ Kích hoạt Máy Quét Camera AI phân tích dị nguyên thức ăn',
                onChanged: () => context.read<Health360Cubit>().toggleSymptom('nose_food'),
                accentColor: const Color(0xFF38BDF8),
              ),

              const SizedBox(height: 20),

              // THROAT / EAR GROUP
              const Text(
                '🗣️👂 NHÓM TAI - HỌNG & ĐÊM (THROAT & EAR)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFA78BFA),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              _buildSurveyCheckboxTile(
                value: state.symptoms['throat_cough'] ?? false,
                title: 'Ho khan kịch phát, ngứa cổ rát họng về đêm',
                subtitle: '➔ Kích hoạt Audio AI Mic ghi âm, phân tích tần suất Ho nền',
                onChanged: () => context.read<Health360Cubit>().toggleSymptom('throat_cough'),
                accentColor: const Color(0xFFA78BFA),
              ),
              _buildSurveyCheckboxTile(
                value: state.symptoms['throat_snore'] ?? false,
                title: 'Ngủ ngáy, thở bằng miệng, ù khò khè',
                subtitle: '➔ Kích hoạt Cảm biến âm thanh đo Oxy và tiếng thở ngáy ngủ',
                onChanged: () => context.read<Health360Cubit>().toggleSymptom('throat_snore'),
                accentColor: const Color(0xFFA78BFA),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.read<Health360Cubit>().submitSurvey(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: const Color(0xFF090D16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('PHÂN TÍCH HỒ SƠ GỐC', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurveyCheckboxTile({
    required bool value,
    required String title,
    required String subtitle,
    required VoidCallback onChanged,
    required Color accentColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onChanged,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131C2E) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value ? accentColor : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade300),
            width: value ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: (_) => onChanged(),
              activeColor: accentColor,
              checkColor: Colors.white,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  // ==========================================
  // APPBAR (WITH USER PROFILE & COINS)
  // ==========================================

  PreferredSizeWidget _buildDashboardAppBar(BuildContext context, Health360State state, bool isDark) {
    return AppBar(
      toolbarHeight: 80,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Chào Minh Tuấn 👋',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  _getSymptomProfile(state.symptoms),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF38BDF8),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFB923C).withValues(alpha: 0.12),
              border: Border.all(color: const Color(0xFFFB923C).withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${state.coins}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFB923C),
                  ),
                ),
                const SizedBox(width: 4),
                const Text('🪙', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          onPressed: () => context.read<ThemeCubit>().toggleTheme(),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, size: 20),
          tooltip: 'Làm lại',
          onPressed: () {
            context.read<Health360Cubit>().resetSurvey();
            context.read<AudioSedCubit>().reset();
          },
        ),
      ],
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF0C1220) : Colors.white,
      shape: Border(
        bottom: BorderSide(
          color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
          width: 1,
        ),
      ),
    );
  }

  // ==========================================
  // BOTTOM TAB NAVIGATION
  // ==========================================

  Widget _buildBottomNavigationBar(BuildContext context, Health360State state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: state.currentTab,
        onTap: (tab) => context.read<Health360Cubit>().setTab(tab),
        backgroundColor: isDark ? const Color(0xFF0C1220) : Colors.white,
        selectedItemColor: const Color(0xFF38BDF8),
        unselectedItemColor: Colors.grey.shade500,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Tổng kết'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Đổi thưởng'),
        ],
      ),
    );
  }

  // ==========================================
  // TAB ROUTING & VIEWS
  // ==========================================

  Widget _buildTabContent(Health360State state) {
    switch (state.currentTab) {
      case 0:
        return _buildHomeView(state);
      case 1:
        return _buildWeeklyReviewView(state);
      case 2:
        return _buildMarketplaceView(state);
      default:
        return _buildHomeView(state);
    }
  }

  // TAB 0: HOME VIEW
  Widget _buildHomeView(Health360State state) {
    return Column(
      children: [
        // Sub tabs for Morning / Noon / Night
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF090D16)
              : Colors.grey.shade100,
          child: Row(
            children: [
              _buildTimeSubTab('morning', '🌅 Sáng', state.timeOfDay),
              const SizedBox(width: 8),
              _buildTimeSubTab('noon', '🕒 Trưa', state.timeOfDay),
              const SizedBox(width: 8),
              _buildTimeSubTab('night', '🌙 Tối', state.timeOfDay),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _buildTimeOfDayContent(state),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSubTab(String timeKey, String label, String currentTime) {
    final isSelected = timeKey == currentTime;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: () => context.read<Health360Cubit>().setTimeOfDay(timeKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF38BDF8).withValues(alpha: 0.12)
                : Colors.transparent,
            border: Border.all(
              color: isSelected ? const Color(0xFF38BDF8) : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade300),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFF38BDF8) : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeOfDayContent(Health360State state) {
    switch (state.timeOfDay) {
      case 'morning':
        return _buildMorningContent(state);
      case 'noon':
        return _buildNoonContent(state);
      case 'night':
        return _buildNightContent(state);
      default:
        return _buildMorningContent(state);
    }
  }

  // ==========================================
  // MORNING CONTENT (Tab 0 - Sub 0)
  // ==========================================

  Widget _buildMorningContent(Health360State state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final temp = state.weatherData?['temperature'] as num? ?? 32.0;
    final hum = state.weatherData?['humidity'] as num? ?? 78;
    final pm25 = state.weatherData?['pm25'] as num? ?? 85.0;
    final aqi = state.weatherData?['aqi'] as int? ?? 4;
    final loc = state.weatherData?['location_name'] as String? ?? 'Ho Chi Minh City';

    String aqiLabel;
    switch (aqi) {
      case 1:
        aqiLabel = 'Tốt (L1) 😊';
        break;
      case 2:
        aqiLabel = 'Vừa (L2) 😐';
        break;
      case 3:
        aqiLabel = 'Kém (L3) 😷';
        break;
      case 4:
        aqiLabel = 'Xấu (L4) 🤢';
        break;
      case 5:
        aqiLabel = 'Rất xấu (L5) 🚨';
        break;
      default:
        aqiLabel = 'Kém (L3) 😷';
    }

    final int computedRisk = (pm25 * 1.2 + (100 - hum) * 0.4).clamp(30, 99).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Timeline
        const Row(
          children: [
            Text('🌅', style: TextStyle(fontSize: 16)),
            SizedBox(width: 8),
            Text(
              'BUỔI SÁNG • 07:00 • ĐỊNH VỊ GPS KHÍ TƯỢNG',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Weather/AQI Card with gradient background
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF241610), const Color(0xFF131C2E)]
                  : [const Color(0xFFFFF7ED), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFFFB923C).withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFB923C).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '⚠️ NGUY CƠ KÍCH ỨNG MŨI: $computedRisk%',
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFFB923C)),
                    ),
                  ),
                  Text(
                    'AQI: $aqiLabel',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFB923C)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Độ ẩm: ${hum.toStringAsFixed(0)}% | Nhiệt độ: ${temp.toStringAsFixed(1)}°C tại $loc.',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Chỉ số PM2.5 là ${pm25.toStringAsFixed(1)} µg/m³. Dựa trên triệu chứng hắt hơi của bạn, niêm mạc mũi có nguy cơ phù nề cao trong thời tiết này.',
                style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Habits Task List
        const Text(
          'Nhiệm vụ phòng bệnh nhận xu',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 10),

        _buildHabitRow(
          taskId: 'morn_task_1',
          title: 'Vệ sinh cuốn mũi bằng nước muối ấm',
          description: 'Loại bỏ bụi mịn bám dính gây kích ứng hắt hơi.',
          reward: 50,
          state: state,
        ),
      ],
    );
  }

  Widget _buildHabitRow({
    required String taskId,
    required String title,
    required String description,
    required int reward,
    required Health360State state,
  }) {
    final isCompleted = state.completedTasks[taskId] == true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        if (!isCompleted) {
          context.read<Health360Cubit>().completeTask(taskId, reward);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Nhiệm vụ hoàn thành! Nhận +$reward xu! 🪙'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCompleted
              ? const Color(0xFF10B981).withValues(alpha: 0.05)
              : (isDark ? const Color(0xFF131C2E) : Colors.white),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF10B981).withValues(alpha: 0.4)
                : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade300),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? Colors.grey : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF10B981).withValues(alpha: 0.1)
                    : const Color(0xFFFB923C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFFFB923C).withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                isCompleted ? '✓ +$reward' : '🪙 +$reward',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFFB923C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // NOON CONTENT (Tab 0 - Sub 1)
  // ==========================================

  Widget _buildNoonContent(Health360State state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Header
        const Row(
          children: [
            Text('🕒', style: TextStyle(fontSize: 16)),
            SizedBox(width: 8),
            Text(
              'TRONG NGÀY • 12:30 • KIỂM TRA DỊ NGUYÊN',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Camera AI Scan viewport
        _buildCameraScanViewport(state),

        const SizedBox(height: 16),

        // Scanning result
        if (state.scannedFoodKey != null) _buildScannerResult(state),
      ],
    );
  }

  Widget _buildCameraScanViewport(Health360State state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131C2E) : Colors.white,
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header view finder
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📸 MÁY QUÉT CAMERA AI (ENT NUTRITION)',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF38BDF8)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '● LENS LIVE',
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                  ),
                ),
              ],
            ),
          ),

          // Camera frame viewport
          Container(
            height: 220,
            color: isDark ? const Color(0xFF0B1324) : Colors.grey.shade200,
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Live Camera Stream
                  if (_isCameraActive && _isCameraInitialized && _cameraController != null)
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _cameraController!.value.previewSize != null
                            ? _cameraController!.value.previewSize!.height
                            : 100,
                        height: _cameraController!.value.previewSize != null
                            ? _cameraController!.value.previewSize!.width
                            : 100,
                        child: CameraPreview(_cameraController!),
                      ),
                    )
                  else if (!_isCameraActive && !_isInitializingCamera)
                    Container(
                      color: isDark ? const Color(0xFF0B1324) : Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Camera chưa được kích hoạt',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: _initializeCamera,
                            icon: const Icon(Icons.videocam, size: 14),
                            label: const Text('Bật Camera', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF38BDF8),
                              foregroundColor: const Color(0xFF090D16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      color: isDark ? const Color(0xFF0B1324) : Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
                      ),
                    ),

                  // Brackets UI
                  Positioned(
                    top: 15,
                    left: 35,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFF38BDF8), width: 2),
                          left: BorderSide(color: Color(0xFF38BDF8), width: 2),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 35,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFF38BDF8), width: 2),
                          right: BorderSide(color: Color(0xFF38BDF8), width: 2),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 15,
                    left: 35,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFF38BDF8), width: 2),
                          left: BorderSide(color: Color(0xFF38BDF8), width: 2),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 15,
                    right: 35,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFF38BDF8), width: 2),
                          right: BorderSide(color: Color(0xFF38BDF8), width: 2),
                        ),
                      ),
                    ),
                  ),

                  // Center spinner during active scanning
                  if (state.isScanning)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF38BDF8)),
                            SizedBox(height: 12),
                            Text(
                              'AI đang phân tích thực phẩm...',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Simulated scanning vertical bar line
                  if (!state.isScanning && _isCameraActive && _isCameraInitialized)
                    const LoopingScanningBar(),
                ],
              ),
            ),
          ),

          // Actions
          if (_isCameraActive)
            Container(
              padding: const EdgeInsets.all(12),
              color: isDark ? const Color(0xFF0C1424) : Colors.grey.shade100,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: (state.isScanning || !_isCameraInitialized || _cameraController == null)
                            ? null
                            : () async {
                                try {
                                  final XFile file = await _cameraController!.takePicture();
                                  final bytes = await file.readAsBytes();
                                  if (!mounted) return;
                                  context.read<Health360Cubit>().runScanner('custom_food', customImageBytes: bytes);
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Lỗi khi chụp hình: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        icon: const Text('📸', style: TextStyle(fontSize: 16)),
                        label: const Text('QUÉT THỰC PHẨM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: const Color(0xFF0C1424),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: state.isScanning
                            ? null
                            : () {
                                _disposeCamera();
                              },
                        icon: const Icon(Icons.videocam_off, size: 16),
                        label: const Text('TẮT CAM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScannerResult(Health360State state) {
    final foodKey = state.scannedFoodKey;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final nameMock = foodKey == 'haisan' ? 'MÓN ĂN: LẨU HẢI SẢN (92%)' : 'ĐỒ UỐNG: NƯỚC ĐÁ LẠNH (96%)';
    final riskMock = foodKey == 'haisan' ? '⚠️ Nguy cơ kích ứng: NHÓM TRIỆU CHỨNG MŨI' : '⚠️ Nguy cơ kích ứng: NHÓM HO / RÁT HỌNG ĐÊM';
    final descMock = foodKey == 'haisan'
        ? 'Thực phẩm chứa Histamine tự do. Theo khảo sát bạn dễ ngứa họng và ngạt mũi sau ăn, món ăn này sẽ tăng nguy cơ sung huyết niêm mạc xoang.'
        : 'Nhiệt độ thấp làm co mao mạch hầu họng đột ngột, làm tê liệt lông chuyển tuyến niêm mạc. Trực tiếp kích hoạt cơn ho rát kịch phát vào ban đêm mà bạn đã đánh dấu trong bản khảo sát.';
    final actionMock = foodKey == 'haisan'
        ? '💡 Khuyên dùng: Sử dụng nước lọc ấm sau ăn. Hãy dùng bình xịt rửa mũi trước khi đi ngủ tối nay để trung hoà dị nguyên bám dính.'
        : '💡 Khuyên dùng: Giữ ấm vùng cổ họng. Ngậm một ngụm nước ấm nhỏ ngay lập tức để làm ấm lại khu vực vòm họng.';

    final num? inferenceTimeMs = state.scannedFoodResponse?['inference_time_ms'] as num?;

    // Parse real API response
    final List<dynamic>? detectedFoods = state.scannedFoodResponse?['foods'] as List<dynamic>?;
    final List<dynamic>? riskAlerts = state.scannedFoodResponse?['risk_alerts'] as List<dynamic>?;
    final Map<String, dynamic>? totalNutrition = state.scannedFoodResponse?['total_nutrition'] as Map<String, dynamic>?;

    final hasRealFoods = detectedFoods != null && detectedFoods.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131C2E) : Colors.white,
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFFB923C),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                if (hasRealFoods)
                                  ...detectedFoods.map((f) {
                                    final foodMap = f as Map<String, dynamic>;
                                    final fName = foodMap['name_vi'] ?? foodMap['name'] ?? 'N/A';
                                    final fConf = ((foodMap['confidence'] as num? ?? 0.0) * 100).toStringAsFixed(0);
                                    return Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                                        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '$fName ($fConf%)',
                                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                                      ),
                                    );
                                  })
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFB923C).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      nameMock,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFB923C)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              '🪙 +50 Coins',
                              style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                            ),
                            if (inferenceTimeMs != null)
                              Text(
                                '⏱️ YOLOv10: ${inferenceTimeMs.toStringAsFixed(0)}ms',
                                style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Nutrition block if available
                    if (totalNutrition != null && totalNutrition.isNotEmpty && hasRealFoods) ...[
                      const Text(
                        'Dinh dưỡng ước tính:',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildNutritionText('Calo', '${(totalNutrition['Calories'] as num? ?? 0).toStringAsFixed(0)} kcal'),
                          _buildNutritionText('Đường', '${(totalNutrition['Sugar'] as num? ?? 0).toStringAsFixed(1)}g'),
                          _buildNutritionText('Muối', '${(totalNutrition['Salt'] as num? ?? 0).toStringAsFixed(1)}g'),
                          _buildNutritionText('Béo', '${(totalNutrition['Fat'] as num? ?? 0).toStringAsFixed(1)}g'),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Alerts or Clinical warnings
                    if (riskAlerts != null && riskAlerts.isNotEmpty && hasRealFoods) ...[
                      ...riskAlerts.map((a) {
                        final alertMap = a as Map<String, dynamic>;
                        final alertMsg = alertMap['message_vi'] ?? alertMap['message'] ?? 'Cảnh báo nguy cơ';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.05),
                            border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.15)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Text('⚠️ ', style: TextStyle(fontSize: 11)),
                              Expanded(
                                child: Text(
                                  alertMsg,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 6),
                    ] else ...[
                      Text(
                        riskMock,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        descMock,
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, height: 1.4),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.05),
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.15)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          actionMock,
                          style: const TextStyle(fontSize: 10.5, height: 1.4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ==========================================
  // NIGHT CONTENT (Tab 0 - Sub 2)
  // ==========================================

  Widget _buildNightContent(Health360State state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Header
        const Row(
          children: [
            Text('🌙', style: TextStyle(fontSize: 16)),
            SizedBox(width: 8),
            Text(
              'BUỔI TỐI • 22:00 • GIÁM SÁT GIẤC NGỦ',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Audio AI Tracker Mic Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFA78BFA).withValues(alpha: 0.03),
            border: Border.all(color: const Color(0xFFA78BFA).withValues(alpha: 0.15)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA78BFA).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '🎙️ TRỢ LÝ ĐÊM AUDIO AI',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFA78BFA)),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.isNightMicActive ? 'Đang bật' : 'Đang tắt',
                        style: TextStyle(fontSize: 9, color: state.isNightMicActive ? const Color(0xFF10B981) : Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Switch(
                        activeThumbColor: const Color(0xFFA78BFA),
                        value: state.isNightMicActive,
                        onChanged: (value) async {
                          if (value) {
                            // Check Mic permission
                            final status = await Permission.microphone.request();
                            if (!mounted) return;
                            if (!status.isGranted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cần cấp quyền microphone để ghi âm hơi thở đêm!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                          }
                          if (!mounted) return;
                          context.read<Health360Cubit>().toggleNightMic(value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                state.isNightMicActive
                    ? '🔊 MIC ĐANG LẮNG NGHE HƠI THỞ HO, NGÁY...'
                    : 'Tự động lắng nghe dấu hiệu Ho, Ngủ ngáy và Thở dốc vùng họng.',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Kết nối sâu với chỉ số khảo sát của bạn về việc rát họng, ngủ ngáy, ngạt thở về đêm nhằm đánh giá độ tắc nghẽn của đường thở.',
                style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, height: 1.4),
              ),

              const SizedBox(height: 14),

              // Wave sound simulator
              Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0B1222) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PulsingWaveBar(height: state.isNightMicActive ? 12 : 2, durationMs: 400),
                    const SizedBox(width: 3),
                    PulsingWaveBar(height: state.isNightMicActive ? 22 : 2, durationMs: 600),
                    const SizedBox(width: 3),
                    PulsingWaveBar(height: state.isNightMicActive ? 8 : 2, durationMs: 300),
                    const SizedBox(width: 3),
                    PulsingWaveBar(height: state.isNightMicActive ? 18 : 2, durationMs: 500),
                    const SizedBox(width: 3),
                    PulsingWaveBar(height: state.isNightMicActive ? 14 : 2, durationMs: 700),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Daily goal claim button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131C2E) : Colors.white,
            border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kết toán mục tiêu cuối ngày',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: (state.isNightBonusClaimed || !state.isNightMicActive)
                      ? null
                      : () {
                          context.read<Health360Cubit>().claimNightlyBonus();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã nhận +100 xu thưởng tối! 🪙'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: const Color(0xFF090D16),
                    disabledBackgroundColor: Colors.grey.shade800,
                    disabledForegroundColor: Colors.grey.shade500,
                  ),
                  child: Text(
                    state.isNightBonusClaimed
                        ? '✓ ĐÃ BẬT MIC AUDIO AI ĐO ĐÊM (+100)'
                        : (!state.isNightMicActive
                            ? '🎙️ VUI LÒNG BẬT MIC ĐỂ NHẬN THƯỞNG'
                            : '🎁 NHẬN THƯỞNG ĐO ĐÊM +100 COINS'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // INTEGRATE CORE AUDIO RECORDER & ANALYSIS WIDGETS
        const Text(
          'Chẩn Đoán Hô Hấp Bằng AI (V1/V2)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 10),

        // Mode Selector Header
        _buildModeSelector(context),
        const SizedBox(height: 14),

        // Health Consult Banner
        _buildBannerCard(context, context.watch<AudioSedCubit>().state),
        const SizedBox(height: 14),

        // Audio Recorder Card
        _buildAudioSedCard(context, context.watch<AudioSedCubit>().state),
        const SizedBox(height: 14),

        // Analysis Results
        _buildAnalysisCard(context, context.watch<AudioSedCubit>().state),
        const SizedBox(height: 14),

        // Sound Samples Selection
        _buildSamplesCard(context, _getSamplesFromState(context.watch<AudioSedCubit>().state)),
      ],
    );
  }

  // ==========================================
  // TAB 1: WEEKLY REVIEW (BEFORE / AFTER)
  // ==========================================

  Widget _buildWeeklyReviewView(Health360State state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String coughBefore = state.weeklySummary?['cough_before'] as String? ?? '6 lần/đêm';
    final String coughAfter = state.weeklySummary?['cough_after'] as String? ?? '1 lần/đêm';
    final String snoreBefore = state.weeklySummary?['snore_before'] as String? ?? '42 phút';
    final String snoreAfter = state.weeklySummary?['snore_after'] as String? ?? '12 phút';

    return SingleChildScrollView(
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
                  const Text(
                    '📅 Báo cáo chu kỳ tuần',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'TRIỆU CHỨNG ĐANG GIẢM DẦN',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Đối chiếu lâm sàng dựa trên khảo sát Tai-Mũi-Họng ban đầu.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Comparison Stats Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131C2E) : Colors.white,
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade300),
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
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Comparison 1: Cough Count
                _buildComparisonGrid(
                  title: 'CƠN HO KHAN',
                  before: coughBefore,
                  beforeColor: const Color(0xFFEF4444),
                  after: coughAfter,
                  afterColor: const Color(0xFF10B981),
                ),

                const SizedBox(height: 12),

                // Comparison 2: Snoring duration
                _buildComparisonGrid(
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
              border: Border.all(color: const Color(0xFFFB923C).withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  'Thành quả bảo vệ hệ hô hấp',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFB923C)),
                ),
                const SizedBox(height: 6),
                const Text(
                  '🪙 +450 COINS',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFFB923C)),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state.isWeeklyBonusClaimed
                        ? null
                        : () {
                            context.read<Health360Cubit>().claimWeeklyBonus();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã nhận +450 xu thưởng tuần! 🪙'),
                                backgroundColor: Color(0xFF10B981),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFB923C),
                      foregroundColor: const Color(0xFF090D16),
                      disabledBackgroundColor: Colors.grey.shade700,
                      disabledForegroundColor: Colors.grey.shade400,
                    ),
                    child: Text(
                      state.isWeeklyBonusClaimed ? '✓ ĐÃ NHẬN XU THƯỞNG TUẦN' : 'THU HOẠCH PHẦN THƯỞNG TUẦN',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonGrid({
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
                Text(title, style: TextStyle(fontSize: 8, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(before, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: beforeColor)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('HIỆN TẠI', style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(after, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: afterColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: MARKETPLACE & RETENTION
  // ==========================================

  Widget _buildMarketplaceView(Health360State state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trung Tâm Đổi Thưởng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          const Text(
            'TIẾT KIỆM TỪ SỨC KHỎE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
          ),
          const SizedBox(height: 16),

          // Voucher Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131C2E) : Colors.white,
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🎟️ Voucher 50K Xịt Mũi Sinufresh',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Voucher đổi bằng xu tích luỹ từ hành động bảo vệ hệ hô hấp.',
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '500 Xu',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFB923C)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () async {
                      final cubit = context.read<Health360Cubit>();
                      final success = await cubit.redeemVoucher('Sinufresh 50K', 500);
                      if (!mounted) return;
                      if (success) {
                        _showRedeemSuccessDialog(cubit.state);
                      } else {
                        _showRedeemFailureDialog();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: const Color(0xFF090D16),
                    ),
                    child: const Text('ĐỔI VOUCHER NGAY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Redeemed list
          if (state.redeemedVouchers.isNotEmpty) ...[
            const Text(
              'Voucher đã đổi của bạn',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Column(
              children: state.redeemedVouchers.map((v) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Text('🎟️', style: TextStyle(fontSize: 22)),
                    title: Text('Voucher $v', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    subtitle: const Text('Hạn sử dụng: 31/12/2026', style: TextStyle(fontSize: 9)),
                    trailing: ElevatedButton(
                      onPressed: () => _showQRVoucherDialog(v),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: const Color(0xFF090D16),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: Size.zero,
                      ),
                      child: const Text('Mở QR', style: TextStyle(fontSize: 9)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _showRedeemSuccessDialog(Health360State state) {
    final orderId = state.lastOrderResponse?['order_id'] as String? ?? 'N/A';
    final delivery = state.lastOrderResponse?['estimated_delivery'] as String? ?? '15 phút';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('🎉 Đổi thưởng thành công!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mã QR giảm giá Sinufresh 50K đã được đồng bộ.\nMã đơn hàng O2O: #$orderId\nDự kiến giao hàng: $delivery',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              MockQRCodeWidget(orderId: orderId),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  void _showRedeemFailureDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('❌ Không đủ xu'),
          content: const Text(
            'Thực hiện thêm các quét camera AI hoặc đo giấc ngủ đêm để tích luỹ thêm xu.',
            style: TextStyle(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );
  }

  void _showQRVoucherDialog(String voucherName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('🎟️ Voucher $voucherName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Đưa mã QR này cho dược sĩ tại quầy thuốc Pharmacity/Long Châu để áp dụng giảm giá.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11),
              ),
              const SizedBox(height: 16),
              MockQRCodeWidget(orderId: voucherName),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // CORE RECORDER INNER WIDGETS
  // ==========================================

  List<String> _getSamplesFromState(AudioSedState state) {
    if (state is AudioSedSamplesLoaded) {
      return state.samples;
    } else if (state is AudioSedAnalysisSuccess) {
      return state.samples;
    } else if (state is AudioSedError) {
      return state.samples;
    }
    return [];
  }

  Widget _buildModeSelector(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isV1 = _selectedMode == 'v1';

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() => _selectedMode = 'v1');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isV1 ? (isDark ? theme.colorScheme.primary : AppColors.primaryBlue) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Phát hiện ho (V1)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isV1 ? (isDark ? theme.colorScheme.onPrimary : Colors.white) : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() => _selectedMode = 'v2');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isV1 ? (isDark ? theme.colorScheme.primary : AppColors.primaryBlue) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Phân tích khan/đờm (V2)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: !isV1 ? (isDark ? theme.colorScheme.onPrimary : Colors.white) : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context, AudioSedState state) {
    if (state is! AudioSedAnalysisSuccess) return const SizedBox.shrink();

    final result = state.result;
    final hasCough = result.hasCough;
    final hasSnore = result.events.any((e) => e.className == 'Snoring');

    if (hasCough) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE6FBF1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF00A651).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF00A651),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phát Hiện Triệu Chứng Ho',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'Nhận tư vấn đề xuất sản phẩm thuốc phù hợp.',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.push('/assessment', extra: result);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A651),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
              ),
              child: const Text('Khảo sát', style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
      );
    } else if (hasSnore) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF5FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9D5FF)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF9333EA),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.nightlight_round, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phát Hiện Tiếng Ngáy/Thở',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'Đoạn ghi âm có tiếng ngáy. Sàng lọc ngưng thở lúc ngủ.',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.push('/sleep-assessment');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9333EA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
              ),
              child: const Text('Khảo sát', style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildAudioSedCard(BuildContext context, AudioSedState state) {
    final theme = Theme.of(context);
    final isRecording = state is AudioSedRecording;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text('🎙️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Kiểm tra tiếng ho',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF38BDF8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Recorder Card UI
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.light ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Column(
                children: [
                  const Text(
                    'THU ÂM TRỰC TIẾP',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Microphone Button
                  InkWell(
                    onTap: () {
                      if (isRecording) {
                        context.read<AudioSedCubit>().stopRecordingAndAnalyze(_selectedMode);
                      } else {
                        context.read<AudioSedCubit>().startRecording(_selectedMode);
                      }
                    },
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: isRecording ? Colors.red : const Color(0xFFFB923C),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isRecording ? Colors.red : const Color(0xFFFB923C)).withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Icon(
                        isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    isRecording ? 'Đang thu âm... ${state.elapsedSeconds}s' : 'Nhấn để thu âm 5 giây',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isRecording ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Waveform visualizer
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TRỰC QUAN SÓNG ÂM',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                WaveformVisualizer(isRecording: isRecording),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSamplesCard(BuildContext context, List<String> samples) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📁', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Mẫu âm thanh kiểm thử',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF38BDF8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (samples.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Không có mẫu âm thanh nào.',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: samples.map((filename) {
                  String icon = '🎵';
                  if (filename.contains('cough')) icon = '😷';
                  if (filename.contains('breathing')) icon = '🫁';
                  if (filename.contains('snoring')) icon = '💤';

                  return OutlinedButton.icon(
                    onPressed: () {
                      context.read<AudioSedCubit>().analyzeSampleFile(filename, _selectedMode);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Text(icon, style: const TextStyle(fontSize: 12)),
                    label: Text(
                      filename,
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context, AudioSedState state) {
    final theme = Theme.of(context);

    if (state is AudioSedSamplesLoading || state is AudioSedInitial) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const CircularProgressIndicator(strokeWidth: 2.5),
              const SizedBox(width: 16),
              Text(
                'Đang tải danh sách mẫu...',
                style: theme.textTheme.bodyMedium,
              )
            ],
          ),
        ),
      );
    }

    if (state is AudioSedAnalyzing) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF38BDF8),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Đang chẩn đoán giọng ho bằng mô hình AI...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is AudioSedAnalysisSuccess) {
      final result = state.result;
      final timeMs = result.inferenceTimeMs;
      final duration = result.durationSec;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('📊', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        'Phân tích từ AI',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF38BDF8),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '⏱️ ${timeMs.toStringAsFixed(0)}ms | ${duration.toStringAsFixed(1)}s audio',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Events list
              if (result.events.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '💨 Không phát hiện âm thanh hô hấp bất thường (ho, rít, thở dốc).',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                )
              else
                Column(
                  children: result.events.map((event) {
                    final color = TimelineChart.classColors[event.className] ?? Colors.blueGrey;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  event.classNameVi,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${event.start.toStringAsFixed(1)}s – ${event.end.toStringAsFixed(1)}s',
                                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${(event.confidence * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 12),

              // V2 dry/wet breakdown
              if (state.mode == 'v2' && result.coughTypeAnalysis != null) ...[
                _buildV2CoughBreakdown(context, result.coughTypeAnalysis!),
                const SizedBox(height: 12),
              ],

              // Timeline graph
              if (result.events.isNotEmpty) TimelineChart(events: result.events, durationSec: duration),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Center(
              child: Text(
                'Chưa có dữ liệu âm thanh.',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng bấm nút mic hoặc chọn mẫu kiểm thử để bắt đầu phân tích.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildV2CoughBreakdown(BuildContext context, CoughTypeAnalysis ct) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dryPct = ct.probabilities['dry'] ?? 0.0;
    final wetPct = ct.probabilities['wet'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.primaryContainer : AppColors.primaryBlueLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? theme.colorScheme.outline : AppColors.primaryBlue.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                ct.coughType == 'dry' ? '🌵' : '💧',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: isDark ? theme.colorScheme.onPrimaryContainer : Colors.black87,
                          fontSize: 13,
                        ),
                        children: [
                          const TextSpan(text: 'Chẩn đoán ho: ', style: TextStyle(fontWeight: FontWeight.w500)),
                          TextSpan(
                            text: ct.coughTypeVi,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF38BDF8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Đoạn ghi âm có tiếng ho. Độ chính xác AI: ${(ct.confidence * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: isDark ? theme.colorScheme.onSurfaceVariant : AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dry progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ho khan',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? theme.colorScheme.onSurfaceVariant : Colors.black54,
                    ),
                  ),
                  Text(
                    '${(dryPct * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: dryPct,
                  backgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
                  color: const Color(0xFFFB923C),
                  minHeight: 6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Wet progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ho có đờm',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? theme.colorScheme.onSurfaceVariant : Colors.black54,
                    ),
                  ),
                  Text(
                    '${(wetPct * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: wetPct,
                  backgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
                  color: const Color(0xFF38BDF8),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// CUSTOM HELPER WIDGETS
// ==========================================

class LoopingScanningBar extends StatefulWidget {
  const LoopingScanningBar({super.key});

  @override
  State<LoopingScanningBar> createState() => _LoopingScanningBarState();
}

class _LoopingScanningBarState extends State<LoopingScanningBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.15, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: 160 * _animation.value,
          left: 35,
          right: 35,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF38BDF8),
                  blurRadius: 8,
                  spreadRadius: 1.5,
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF38BDF8).withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class PulsingWaveBar extends StatefulWidget {
  final double height;
  final int durationMs;

  const PulsingWaveBar({
    super.key,
    required this.height,
    required this.durationMs,
  });

  @override
  State<PulsingWaveBar> createState() => _PulsingWaveBarState();
}

class _PulsingWaveBarState extends State<PulsingWaveBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.durationMs),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 3,
          height: widget.height * _animation.value,
          decoration: BoxDecoration(
            color: const Color(0xFFA78BFA),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}

class MockQRCodeWidget extends StatelessWidget {
  final String orderId;

  const MockQRCodeWidget({super.key, this.orderId = ''});

  bool _isPixelBlack(int row, int col) {
    // Top-left Finder Pattern
    if (row < 7 && col < 7) {
      return _isFinderPatternPixel(row, col);
    }
    // Top-right Finder Pattern
    if (row < 7 && col >= 14) {
      return _isFinderPatternPixel(row, col - 14);
    }
    // Bottom-left Finder Pattern
    if (row >= 14 && col < 7) {
      return _isFinderPatternPixel(row - 14, col);
    }

    // Timing patterns (alternating pixels on row 6/col 6)
    if (row == 6 && col >= 7 && col < 14) {
      return col % 2 == 0;
    }
    if (col == 6 && row >= 7 && row < 14) {
      return row % 2 == 0;
    }

    // Quiet zone separator lines (always white)
    if (row == 7 && col < 8 || col == 7 && row < 8) return false;
    if (row == 7 && col >= 13 || col == 13 && row < 8) return false;
    if (row >= 13 && col == 7 || col == 7 && row >= 13) return false;

    // Deterministic fake data bits for a real looking distribution
    // Avoid large solid regions, keep about 50% density
    final int baseHash = orderId.hashCode;
    final int hash = (row * 17 + col * 23 + (row + col) * 7 + baseHash);
    return hash % 2 == 0 || hash % 5 == 1;
  }

  bool _isFinderPatternPixel(int r, int c) {
    // Standard 7x7 Finder Pattern structure:
    // Outer border (solid 7x7):
    if (r == 0 || r == 6 || c == 0 || c == 6) return true;
    // Inner white separator ring (5x5):
    if (r == 1 || r == 5 || c == 1 || c == 5) return false;
    // Center solid block (3x3):
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pixelColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? const Color(0xFF131C2E) : Colors.grey.shade100;

    return Container(
      width: 160,
      height: 160,
      padding: const EdgeInsets.all(12),
      color: bgColor,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 21,
          crossAxisSpacing: 1.5,
          mainAxisSpacing: 1.5,
        ),
        itemCount: 441, // 21x21
        itemBuilder: (context, index) {
          final row = index ~/ 21;
          final col = index % 21;
          final isBlack = _isPixelBlack(row, col);

          return Container(
            color: isBlack ? pixelColor : Colors.transparent,
          );
        },
      ),
    );
  }
}

class OnboardingSyncView extends StatefulWidget {
  const OnboardingSyncView({super.key});

  @override
  State<OnboardingSyncView> createState() => _OnboardingSyncViewState();
}

class _OnboardingSyncViewState extends State<OnboardingSyncView> {
  bool _isSuccess = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isSuccess = true;
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF38BDF8),
                strokeWidth: 4,
              ),
              const SizedBox(height: 30),
              const Text(
                'Đang kết nối API phần cứng...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                color: isDark ? const Color(0xFF131C2E) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isSuccess ? '🎯 ĐỒNG BỘ PHẦN CỨNG THÀNH CÔNG:' : '⏳ KHỞI TẠO HỆ THỐNG CẢM BIẾN...',
                        style: TextStyle(
                          fontSize: 12,
                          color: _isSuccess ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isSuccess
                            ? '1. Kết nối Định vị đo ô nhiễm & thời tiết.\n2. Mở cổng Camera AI Lens tầm soát thực phẩm.\n3. Kích hoạt Audio Mic lắng nghe tiếng thở ngáy ban đêm.\n\nĐang chuyển hướng sang Nhật ký 24h...'
                            : 'Vui lòng giữ điện thoại ổn định để kết nối các cổng cảm biến hồng ngoại, camera và microphone...',
                        style: const TextStyle(fontSize: 11, height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
