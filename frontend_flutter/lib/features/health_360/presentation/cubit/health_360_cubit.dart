import 'dart:async';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/usecases/submit_user_intake.dart';
import '../../domain/usecases/get_context_weather.dart';
import '../../domain/usecases/scan_food.dart';
import '../../domain/usecases/redeem_voucher.dart';
import '../../domain/usecases/track_event.dart';
import '../../domain/usecases/get_weekly_summary.dart';
import 'health_360_state.dart';

class Health360Cubit extends Cubit<Health360State> {
  final SubmitUserIntake _submitUserIntake;
  final GetContextWeather _getContextWeather;
  final ScanFood _scanFood;
  final RedeemVoucher _redeemVoucher;
  final TrackEvent _trackEvent;
  final GetWeeklySummary _getWeeklySummary;

  final _audioRecorder = AudioRecorder();
  String? _nightRecordingPath;

  Health360Cubit({
    required SubmitUserIntake submitUserIntake,
    required GetContextWeather getContextWeather,
    required ScanFood scanFood,
    required RedeemVoucher redeemVoucher,
    required TrackEvent trackEvent,
    required GetWeeklySummary getWeeklySummary,
  })  : _submitUserIntake = submitUserIntake,
      _getContextWeather = getContextWeather,
      _scanFood = scanFood,
      _redeemVoucher = redeemVoucher,
      _trackEvent = trackEvent,
      _getWeeklySummary = getWeeklySummary,
      super(const Health360State());

  void toggleSymptom(String key) {
    final updatedSymptoms = Map<String, bool>.from(state.symptoms);
    updatedSymptoms[key] = !(updatedSymptoms[key] ?? false);
    emit(state.copyWith(symptoms: updatedSymptoms));
  }

  Future<void> submitSurvey() async {
    emit(state.copyWith(isOnboardingLoading: true, clearError: true));
    try {
      final symptomList = <String>[];
      if (state.symptoms['nose_weather'] == true) symptomList.add('hat_hoi_giao_mua');
      if (state.symptoms['nose_food'] == true) symptomList.add('nghet_mui_sau_an');
      if (state.symptoms['throat_cough'] == true) symptomList.add('ho_khan_ve_dem');
      if (state.symptoms['throat_snore'] == true) symptomList.add('ngu_ngay_tho_mieng');

      // 1. Call User Intake Use Case
      final intakeResult = await _submitUserIntake(
        SubmitUserIntakeParams(
          name: 'Minh Tuấn',
          symptoms: symptomList,
          diseaseTags: const ['ENT'],
          lat: 10.78,
          long: 106.7,
          deviceToken: 'fcm_token_health360',
        ),
      );

      final String userId = await intakeResult.fold(
        (failure) => throw Exception(failure.message),
        (id) => id,
      );

      // 2. Fetch aggregated user context
      final contextResult = await _getContextWeather(userId);
      final weatherData = contextResult.fold(
        (failure) => throw Exception(failure.message),
        (data) => data['weather'] as Map<String, dynamic>,
      );

      // Track onboarding sync analytics event
      await _trackEvent(
        TrackEventParams(
          userId: userId,
          eventType: 'onboarding_sync_success',
          metadata: {'symptoms_count': symptomList.length},
        ),
      );

      emit(state.copyWith(
        userId: userId,
        weatherData: weatherData,
        isOnboardingLoading: false,
        isSurveyCompleted: true,
        timeOfDay: 'morning',
      ));
      
      // Fetch initial summary stats
      await fetchWeeklySummary();
    } catch (e) {
      emit(state.copyWith(
        isOnboardingLoading: false,
        errorMsg: 'Lỗi đồng bộ API: $e',
      ));
    }
  }

  void setTab(int tab) {
    emit(state.copyWith(currentTab: tab));
    if (tab == 1) {
      fetchWeeklySummary();
    }
  }

  void setTimeOfDay(String time) {
    emit(state.copyWith(timeOfDay: time));
  }

  Future<void> fetchWeeklySummary() async {
    if (state.userId == null) return;
    final result = await _getWeeklySummary(state.userId!);
    result.fold(
      (failure) => emit(state.copyWith(errorMsg: 'Lỗi lấy tổng kết tuần: ${failure.message}')),
      (summary) => emit(state.copyWith(weeklySummary: summary)),
    );
  }

  Future<void> completeTask(String taskId, int reward) async {
    if (state.completedTasks[taskId] == true) return;
    
    final updatedTasks = Map<String, bool>.from(state.completedTasks);
    updatedTasks[taskId] = true;
    
    emit(state.copyWith(
      completedTasks: updatedTasks,
      coins: state.coins + reward,
    ));

    if (state.userId != null) {
      final result = await _trackEvent(
        TrackEventParams(
          userId: state.userId!,
          eventType: 'complete_habit_task',
          metadata: {'task_id': taskId, 'coins_earned': reward},
        ),
      );
      result.fold(
        (failure) => null,
        (_) => fetchWeeklySummary(),
      );
    }
  }

  Future<void> runScanner(String foodKey, {Uint8List? customImageBytes}) async {
    emit(state.copyWith(
      isScanning: true,
      clearScannedFood: true,
    ));

    try {
      final userId = state.userId ?? 'user_001';
      
      // Load real image bytes from assets based on the foodKey or custom image bytes
      Uint8List imageBytes;
      if (customImageBytes != null) {
        imageBytes = customImageBytes;
      } else {
        try {
          final byteData = await rootBundle.load('assets/$foodKey.png');
          imageBytes = byteData.buffer.asUint8List();
        } catch (_) {
          // Fallback to 1x1 dummy PNG if asset not loaded
          imageBytes = Uint8List.fromList([
            137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
            0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 108, 137
          ]);
        }
      }

      final scanResult = await _scanFood(
        ScanFoodParams(
          userId: userId,
          foodKey: foodKey,
          imageBytes: imageBytes,
        ),
      );

      scanResult.fold(
        (failure) => emit(state.copyWith(isScanning: false, errorMsg: 'Lỗi phân tích: ${failure.message}')),
        (response) async {
          final int coinReward = state.isScanRewarded ? 0 : 50;

          emit(state.copyWith(
            isScanning: false,
            scannedFoodKey: foodKey,
            scannedFoodResponse: response,
            isScanRewarded: true,
            coins: state.coins + coinReward,
          ));

          await _trackEvent(
            TrackEventParams(
              userId: userId,
              eventType: 'food_scan_success',
              metadata: {'food_key': foodKey},
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isScanning: false,
        errorMsg: 'Lỗi quét camera: $e',
      ));
    }
  }

  Future<void> toggleNightMic(bool active) async {
    emit(state.copyWith(isNightMicActive: active, clearError: true));
    try {
      if (active) {
        // Enforce microphone permission
        final status = await Permission.microphone.request();
        if (!status.isGranted) {
          emit(state.copyWith(
            isNightMicActive: false,
            errorMsg: 'Không có quyền truy cập microphone để giám sát đêm.',
          ));
          return;
        }

        final tempDir = await getTemporaryDirectory();
        _nightRecordingPath = '${tempDir.path}/night_monitor_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            numChannels: 1,
            sampleRate: 16000,
          ),
          path: _nightRecordingPath!,
        );

        if (state.userId != null) {
          await _trackEvent(
            TrackEventParams(
              userId: state.userId!,
              eventType: 'activate_night_monitoring',
              metadata: const {'mic_active': true},
            ),
          );
        }
      } else {
        // Stop recording
        if (await _audioRecorder.isRecording()) {
          await _audioRecorder.stop();
        }
      }
    } catch (e) {
      emit(state.copyWith(
        isNightMicActive: false,
        errorMsg: 'Lỗi mic giám sát đêm: $e',
      ));
    }
  }

  Future<void> claimNightlyBonus() async {
    if (state.isNightBonusClaimed) return;
    emit(state.copyWith(
      isNightBonusClaimed: true,
      coins: state.coins + 100,
    ));

    if (state.userId != null) {
      final result = await _trackEvent(
        TrackEventParams(
          userId: state.userId!,
          eventType: 'claim_nightly_bonus',
          metadata: const {'coins': 100},
        ),
      );
      result.fold(
        (failure) => null,
        (_) => fetchWeeklySummary(),
      );
    }
  }

  Future<void> claimWeeklyBonus() async {
    if (state.isWeeklyBonusClaimed) return;
    emit(state.copyWith(
      isWeeklyBonusClaimed: true,
      coins: state.coins + 450,
    ));

    if (state.userId != null) {
      final result = await _trackEvent(
        TrackEventParams(
          userId: state.userId!,
          eventType: 'claim_weekly_bonus',
          metadata: const {'coins': 450},
        ),
      );
      result.fold(
        (failure) => null,
        (_) => fetchWeeklySummary(),
      );
    }
  }

  Future<bool> redeemVoucher(String name, int cost) async {
    if (state.coins >= cost) {
      try {
        final userId = state.userId ?? 'user_001';
        
        final orderResult = await _redeemVoucher(
          RedeemVoucherParams(
            userId: userId,
            productId: 'voucher_sinufresh_50k',
            productName: 'Voucher 50K Xịt Mũi Sinufresh',
            cost: cost,
            lat: 10.78,
            long: 106.7,
          ),
        );

        return await orderResult.fold(
          (failure) {
            emit(state.copyWith(errorMsg: 'Lỗi tạo đơn hàng: ${failure.message}'));
            return false;
          },
          (response) async {
            final updatedVouchers = List<String>.from(state.redeemedVouchers);
            updatedVouchers.add(name);
            
            emit(state.copyWith(
              coins: state.coins - cost,
              redeemedVouchers: updatedVouchers,
              lastOrderResponse: response,
            ));

            await _trackEvent(
              TrackEventParams(
                userId: userId,
                eventType: 'order_voucher_success',
                metadata: {'product_name': 'Voucher 50K Xịt Mũi Sinufresh', 'cost': cost},
              ),
            );

            return true;
          },
        );
      } catch (e) {
        emit(state.copyWith(errorMsg: 'Lỗi tạo đơn hàng: $e'));
        return false;
      }
    }
    return false;
  }

  void resetSurvey() {
    emit(const Health360State(
      coins: 750,
      isSurveyCompleted: false,
      isOnboardingLoading: false,
      symptoms: {
        'nose_weather': true,
        'nose_food': true,
        'throat_cough': true,
        'throat_snore': true,
      },
      currentTab: 0,
      timeOfDay: 'morning',
      completedTasks: {},
      scannedFoodKey: null,
      isScanning: false,
      isScanRewarded: false,
      isNightMicActive: false,
      isNightBonusClaimed: false,
      isWeeklyBonusClaimed: false,
      redeemedVouchers: [],
      userId: null,
      weatherData: null,
      lastOrderResponse: null,
      scannedFoodResponse: null,
      weeklySummary: null,
      errorMsg: null,
    ));
  }

  @override
  Future<void> close() async {
    if (await _audioRecorder.isRecording()) {
      await _audioRecorder.stop();
    }
    _audioRecorder.dispose();
    return super.close();
  }
}
