import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../health_360/presentation/cubit/health_360_cubit.dart';
import '../../../health_360/presentation/cubit/health_360_state.dart';
import '../../../../app/theme/app_theme.dart';

class FoodCheckerDetailPage extends StatefulWidget {
  const FoodCheckerDetailPage({super.key});

  @override
  State<FoodCheckerDetailPage> createState() => _FoodCheckerDetailPageState();
}

class _FoodCheckerDetailPageState extends State<FoodCheckerDetailPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isInitializingCamera = false;
  String _selectedFoodKey = 'phoga'; // 'phoga', 'haisan', 'dalanh'

  XFile? _capturedFile;
  bool _isCaptured = false;
  bool _isTakingPicture = false;

  final List<Map<String, String>> _foodOptions = [
    {'key': 'phoga', 'name': 'Phở Gà (Chicken Noodle)'},
    {'key': 'haisan', 'name': 'Lẩu Hải Sản Cay'},
    {'key': 'dalanh', 'name': 'Kem Trái Cây Lạnh'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (_isInitializingCamera || _isCameraInitialized) return;
    if (!mounted) return;
    setState(() {
      _isInitializingCamera = true;
    });
    try {
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        final requestStatus = await Permission.camera.request();
        if (!requestStatus.isGranted) {
          if (mounted) {
            setState(() {
              _isInitializingCamera = false;
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
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _isInitializingCamera = false;
        });
      }
    }
  }

  void _disposeCamera({bool isDisposing = false}) {
    if (!isDisposing && mounted) {
      setState(() {
        _isCameraInitialized = false;
        _isInitializingCamera = false;
      });
      // Clear scanned food results from Cubit
      context.read<Health360Cubit>().clearScannedFood();
    }
    if (_cameraController != null) {
      final controller = _cameraController;
      _cameraController = null;
      controller?.dispose();
    }
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized || _cameraController == null || _isTakingPicture) return;
    setState(() {
      _isTakingPicture = true;
    });
    try {
      final file = await _cameraController!.takePicture();
      setState(() {
        _capturedFile = file;
        _isCaptured = true;
        _isTakingPicture = false;
      });
    } catch (e) {
      debugPrint('Error taking picture: $e');
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  @override
  void dispose() {
    try {
      context.read<Health360Cubit>().clearScannedFood();
    } catch (_) {}
    _disposeCamera(isDisposing: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<Health360Cubit, Health360State>(
      builder: (context, state) {
        final hasResults = state.scannedFoodResponse != null && !state.isScanning;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF4F7F6),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF0C1220) : AppColors.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text(
              'KIỂM TRA ĐỒ ĂN CHỐNG VIÊM',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dropdown to choose mock food to scan
                if (!hasResults && !state.isScanning) ...[
                  Card(
                    elevation: 0,
                    color: isDark ? const Color(0xFF131C2E) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Chọn món ăn giả lập để quét:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.primaryBlueDark,
                            ),
                          ),
                          DropdownButton<String>(
                            value: _selectedFoodKey,
                            dropdownColor: isDark ? const Color(0xFF131C2E) : Colors.white,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.primaryBlue,
                            ),
                            items: _foodOptions.map((opt) {
                              return DropdownMenuItem<String>(
                                value: opt['key'],
                                child: Text(opt['name']!),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedFoodKey = val;
                                  _isCaptured = false;
                                  _capturedFile = null;
                                });
                                context.read<Health360Cubit>().clearScannedFood();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Viewfinder Card (Always visible)
                Card(
                  elevation: 0,
                  color: isDark ? const Color(0xFF131C2E) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Camera quét đồ ăn thực tế',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.primaryBlueDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: GestureDetector(
                              onTap: (!_isCameraInitialized || _isTakingPicture || state.isScanning)
                                  ? null
                                  : () {
                                      if (!_isCaptured) {
                                        _takePicture();
                                      }
                                    },
                              child: Stack(
                                children: [
                                  // Camera stream or captured image or loading preview placeholder
                                  _isCaptured && _capturedFile != null
                                      ? Positioned.fill(
                                          child: Image.file(
                                            File(_capturedFile!.path),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : (_isCameraInitialized && _cameraController != null
                                          ? Positioned.fill(
                                              child: FittedBox(
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
                                              ),
                                            )
                                          : Container(
                                              color: isDark ? Colors.black26 : Colors.black87,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.white,
                                                  size: 48,
                                                ),
                                              ),
                                            )),
                                  // Laser line overlay
                                  if (state.isScanning) ...[
                                    const LoopingScanningBar(),
                                    const Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding: EdgeInsets.only(bottom: 16.0),
                                        child: Text(
                                          '[ Scanning... ]',
                                          style: TextStyle(
                                            color: Color(0xFF2ECC71),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (!_isCaptured) ...[
                              if (_isCameraInitialized) ...[
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    icon: const Icon(Icons.videocam_off, size: 16),
                                    label: const Text(
                                      'TẮT CAMERA',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: _isInitializingCamera ? null : () => _disposeCamera(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      elevation: 0,
                                    ),
                                    icon: _isTakingPicture
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Icon(Icons.camera, size: 16),
                                    label: const Text(
                                      'CHỤP ẢNH',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: _isTakingPicture ? null : _takePicture,
                                  ),
                                ),
                              ] else ...[
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primaryBlue,
                                      side: const BorderSide(color: AppColors.primaryBlue),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    icon: const Icon(Icons.videocam, size: 16),
                                    label: const Text(
                                      'BẬT CAMERA',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: _isInitializingCamera ? null : _initializeCamera,
                                  ),
                                ),
                              ],
                            ] else ...[
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primaryBlue,
                                    side: const BorderSide(color: AppColors.primaryBlue),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  icon: const Icon(Icons.replay, size: 16),
                                  label: const Text(
                                    'CHỤP LẠI',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: state.isScanning
                                      ? null
                                      : () {
                                          setState(() {
                                            _isCaptured = false;
                                            _capturedFile = null;
                                          });
                                          context.read<Health360Cubit>().clearScannedFood();
                                        },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2ECC71),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    elevation: 0,
                                  ),
                                  icon: state.isScanning
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Icon(Icons.check, size: 16),
                                  label: const Text(
                                    'XÁC NHẬN SCAN',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: state.isScanning
                                      ? null
                                      : () {
                                          context.read<Health360Cubit>().runScanner(_selectedFoodKey);
                                        },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Results Card
                if (hasResults) ...[
                  _buildResultsCard(context, state, isDark),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsCard(BuildContext context, Health360State state, bool isDark) {
    final response = state.scannedFoodResponse!;
    
    // Parse detected foods
    final List<dynamic> foods = response['foods'] ?? [];
    final List<String> foodNames = foods.map((f) => (f['name_vi'] ?? f['name'] ?? '').toString()).toList();
    final String foodName = foodNames.isNotEmpty ? foodNames.join(', ') : 'Món Ăn';

    // Parse nutrition
    final Map<String, dynamic> nutrition = response['total_nutrition'] ?? {};
    final num calories = nutrition['Calories'] ?? 0;
    final num fat = nutrition['Fat'] ?? 0;
    final num saturates = nutrition['Saturates'] ?? 0;
    final num sugar = nutrition['Sugar'] ?? 0;
    final num salt = nutrition['Salt'] ?? 0;

    // Parse alerts
    final List<dynamic> alerts = response['risk_alerts'] ?? [];

    String statusLabel = 'An toàn - Chống viêm';
    Color badgeColor = const Color(0xFF2ECC71);
    Color badgeBg = const Color(0xFFE8F8F5);
    Color badgeBorder = const Color(0xFFA3E4D7);

    final bool hasDanger = alerts.any((a) => a['severity'] == 'danger');
    final bool hasWarning = alerts.any((a) => a['severity'] == 'warning');

    if (hasDanger) {
      statusLabel = 'Nguy cơ cao';
      badgeColor = const Color(0xFFE74C3C);
      badgeBg = const Color(0xFFFDEDEC);
      badgeBorder = const Color(0xFFFADBD8);
    } else if (hasWarning) {
      statusLabel = 'Cần hạn chế';
      badgeColor = const Color(0xFFF39C12);
      badgeBg = const Color(0xFFFEF5E7);
      badgeBorder = const Color(0xFFFDEBD0);
    }

    final double antiInflamScore = hasDanger ? 3.5 : (hasWarning ? 5.5 : 8.5);
    final String ratingText = 'Điểm đánh giá sức khỏe: $antiInflamScore/10';

    String adviceText = 'Món ăn không chứa thành phần gây kích ứng, an toàn để sử dụng.';
    if (hasDanger) {
      adviceText = 'Phát hiện có thành phần nguy cơ cao gây viêm hoặc kích ứng đường hô hấp. Khuyên dùng hạn chế tối đa hoặc thay thế bằng món ăn lành tính hơn.';
    } else if (hasWarning) {
      adviceText = 'Món ăn có thành phần cần kiểm soát liều lượng đối với tình trạng sức khỏe hiện tại của bạn. Vui lòng ăn với khẩu phần vừa phải.';
    }

    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF131C2E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    foodName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primaryBlueDark,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    border: Border.all(color: badgeBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Rating Highlight Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: badgeBg,
                border: Border.all(color: badgeBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ratingText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Nutrition Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildNutritionChip('Calo', '${calories.toStringAsFixed(0)} kcal', Colors.orange),
                  const SizedBox(width: 6),
                  _buildNutritionChip('Chất béo', '${fat.toStringAsFixed(1)}g', Colors.blue),
                  const SizedBox(width: 6),
                  _buildNutritionChip('Béo bão hòa', '${saturates.toStringAsFixed(1)}g', Colors.purple),
                  const SizedBox(width: 6),
                  _buildNutritionChip('Đường', '${sugar.toStringAsFixed(1)}g', Colors.red),
                  const SizedBox(width: 6),
                  _buildNutritionChip('Muối', '${salt.toStringAsFixed(2)}g', Colors.teal),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Warnings/Alerts Section
            if (alerts.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8F5),
                  border: Border.all(color: const Color(0xFFA3E4D7)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Text('✅', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Thực phẩm an toàn, không phát hiện nguy cơ kích ứng cho hồ sơ của bạn.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2ECC71),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ...alerts.map((alert) {
                final String msg = alert['message_vi'] ?? '';
                final String severity = alert['severity'] ?? 'warning';
                final bool isDanger = severity == 'danger';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDanger ? const Color(0xFFFDEDEC) : const Color(0xFFFEF5E7),
                      border: Border.all(color: isDanger ? const Color(0xFFFADBD8) : const Color(0xFFFDEBD0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          isDanger ? '⚠️' : '🔔',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            msg,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDanger ? const Color(0xFFE74C3C) : const Color(0xFFD35400),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: 12),

            // AI Recommendation text
            Text(
              adviceText,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha((0.08 * 255).round()),
        border: Border.all(color: color.withAlpha((0.2 * 255).round())),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 8, color: AppColors.textMuted, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class LoopingScanningBar extends StatefulWidget {
  const LoopingScanningBar({super.key});

  @override
  State<LoopingScanningBar> createState() => _LoopingScanningBarState();
}

class _LoopingScanningBarState extends State<LoopingScanningBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Align(
          alignment: Alignment(0, -1.0 + (_animationController.value * 2.0)),
          child: Container(
            width: double.infinity,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF2ECC71),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF2ECC71),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
