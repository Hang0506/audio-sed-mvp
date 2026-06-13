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
    final String foodName = response['food_name'] ?? 'Món Ăn';
    
    // Custom logic to detect Pho Ga and details for Screen 5 specifications
    final bool isPhoGa = foodName.contains('Phở') || state.scannedFoodKey == 'phoga';
    
    // Extract info dynamically or fallback toPho Ga defaults
    final double antiInflamScore = isPhoGa ? 8.5 : 4.0;
    final String ratingText = 'Độ chống viêm: $antiInflamScore/10 (Tốt)';
    final String adviceText = isPhoGa 
        ? 'Món ăn chứa các gia vị làm ấm tỳ vị, làm loãng dịch nhầy, rất có lợi cho người bị xoang mãn tính. Hạn chế thêm ớt và tiêu.'
        : 'Chứa thành phần dễ gây kích ứng hoặc gây kích thích xoang. Cân nhắc giảm khẩu phần hoặc hạn chế gia vị đi kèm.';

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
                    color: const Color(0xFFE8F8F5),
                    border: Border.all(color: const Color(0xFFA3E4D7)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'An toàn - Chống viêm',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2ECC71),
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
                color: const Color(0xFFE8F8F5),
                border: Border.all(color: const Color(0xFF2ECC71)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ratingText,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2ECC71),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Ingredients Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTag('Gừng - Tốt', const Color(0xFFE8F8F5), const Color(0xFFA3E4D7), const Color(0xFF2ECC71)),
                _buildTag('Hành - Tốt', const Color(0xFFE8F8F5), const Color(0xFFA3E4D7), const Color(0xFF2ECC71)),
                _buildTag('Tiêu - Hạn chế', const Color(0xFFFDEDEC), const Color(0xFFFADBD8), const Color(0xFFE74C3C)),
              ],
            ),
            const SizedBox(height: 12),

            // Warning Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDEDEC),
                border: Border.all(color: const Color(0xFFFADBD8)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Text(
                    '⚠️',
                    style: TextStyle(fontSize: 14, color: Color(0xFFE74C3C)),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cảnh báo: Chứa hạt tiêu có thể gây kích ứng biểu mô xoang.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFE74C3C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildTag(String label, Color fill, Color stroke, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: stroke),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: text,
        ),
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
