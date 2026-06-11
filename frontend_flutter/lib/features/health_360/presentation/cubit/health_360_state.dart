import 'package:equatable/equatable.dart';

class Health360State extends Equatable {
  final int coins;
  final bool isSurveyCompleted;
  final bool isOnboardingLoading;
  final Map<String, bool> symptoms; // 'nose_weather', 'nose_food', 'throat_cough', 'throat_snore'
  final int currentTab; // 0: Home, 1: Summary, 2: Reward
  final String timeOfDay; // 'morning', 'noon', 'night'
  final Map<String, bool> completedTasks; // e.g. 'morn_task_1'
  final String? scannedFoodKey; // 'haisan', 'dalanh', or null
  final bool isScanning;
  final bool isScanRewarded;
  final bool isNightMicActive;
  final bool isNightBonusClaimed;
  final bool isWeeklyBonusClaimed;
  final List<String> redeemedVouchers;

  // New API Fields
  final String? userId;
  final Map<String, dynamic>? weatherData;
  final Map<String, dynamic>? lastOrderResponse;
  final Map<String, dynamic>? scannedFoodResponse;
  final Map<String, dynamic>? weeklySummary;
  final String? errorMsg;

  const Health360State({
    this.coins = 750,
    this.isSurveyCompleted = false,
    this.isOnboardingLoading = false,
    this.symptoms = const {
      'nose_weather': true,
      'nose_food': true,
      'throat_cough': true,
      'throat_snore': true,
    },
    this.currentTab = 0,
    this.timeOfDay = 'morning',
    this.completedTasks = const {},
    this.scannedFoodKey,
    this.isScanning = false,
    this.isScanRewarded = false,
    this.isNightMicActive = false,
    this.isNightBonusClaimed = false,
    this.isWeeklyBonusClaimed = false,
    this.redeemedVouchers = const [],
    this.userId,
    this.weatherData,
    this.lastOrderResponse,
    this.scannedFoodResponse,
    this.weeklySummary,
    this.errorMsg,
  });

  Health360State copyWith({
    int? coins,
    bool? isSurveyCompleted,
    bool? isOnboardingLoading,
    Map<String, bool>? symptoms,
    int? currentTab,
    String? timeOfDay,
    Map<String, bool>? completedTasks,
    String? scannedFoodKey,
    bool? isScanning,
    bool? isScanRewarded,
    bool? isNightMicActive,
    bool? isNightBonusClaimed,
    bool? isWeeklyBonusClaimed,
    List<String>? redeemedVouchers,
    bool clearScannedFood = false,
    String? userId,
    Map<String, dynamic>? weatherData,
    Map<String, dynamic>? lastOrderResponse,
    Map<String, dynamic>? scannedFoodResponse,
    Map<String, dynamic>? weeklySummary,
    String? errorMsg,
    bool clearError = false,
  }) {
    return Health360State(
      coins: coins ?? this.coins,
      isSurveyCompleted: isSurveyCompleted ?? this.isSurveyCompleted,
      isOnboardingLoading: isOnboardingLoading ?? this.isOnboardingLoading,
      symptoms: symptoms ?? this.symptoms,
      currentTab: currentTab ?? this.currentTab,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      completedTasks: completedTasks ?? this.completedTasks,
      scannedFoodKey: clearScannedFood ? null : (scannedFoodKey ?? this.scannedFoodKey),
      isScanning: isScanning ?? this.isScanning,
      isScanRewarded: isScanRewarded ?? this.isScanRewarded,
      isNightMicActive: isNightMicActive ?? this.isNightMicActive,
      isNightBonusClaimed: isNightBonusClaimed ?? this.isNightBonusClaimed,
      isWeeklyBonusClaimed: isWeeklyBonusClaimed ?? this.isWeeklyBonusClaimed,
      redeemedVouchers: redeemedVouchers ?? this.redeemedVouchers,
      userId: userId ?? this.userId,
      weatherData: weatherData ?? this.weatherData,
      lastOrderResponse: lastOrderResponse ?? this.lastOrderResponse,
      scannedFoodResponse: scannedFoodResponse ?? this.scannedFoodResponse,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      errorMsg: clearError ? null : (errorMsg ?? this.errorMsg),
    );
  }

  @override
  List<Object?> get props => [
        coins,
        isSurveyCompleted,
        isOnboardingLoading,
        symptoms,
        currentTab,
        timeOfDay,
        completedTasks,
        scannedFoodKey,
        isScanning,
        isScanRewarded,
        isNightMicActive,
        isNightBonusClaimed,
        isWeeklyBonusClaimed,
        redeemedVouchers,
        userId,
        weatherData,
        lastOrderResponse,
        scannedFoodResponse,
        weeklySummary,
        errorMsg,
      ];
}
