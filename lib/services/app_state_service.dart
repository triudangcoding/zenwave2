import 'package:flutter/foundation.dart';

import 'ble_service.dart';

/// Simple in-memory global state for the demo app.
/// No backend / SharedPreferences required.
class AppStateService {
  AppStateService._();

  // ── Onboarding ────────────────────────────────────────────────────────────

  static bool _hasCompletedOnboarding = false;
  static bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  /// Stores 0-based answer indices for the 3 quick psych questions.
  static final List<int> quickPsychAnswers = <int>[];

  static void completeOnboarding(List<int> answers) {
    quickPsychAnswers
      ..clear()
      ..addAll(answers);
    _hasCompletedOnboarding = true;
    isOnboardedNotifier.value = true;
  }

  static final ValueNotifier<bool> isOnboardedNotifier = ValueNotifier<bool>(
    false,
  );

  // ── Device ────────────────────────────────────────────────────────────────

  static final ValueNotifier<bool> deviceConnectedNotifier =
      ValueNotifier<bool>(false);
  static final ValueNotifier<String?> connectedDeviceNameNotifier =
      ValueNotifier<String?>(null);
  static final ValueNotifier<bool?> touchDetectedNotifier =
      ValueNotifier<bool?>(null);

  static bool get isDeviceConnected => deviceConnectedNotifier.value;
  static String? get connectedDeviceName => connectedDeviceNameNotifier.value;
  static bool? get isTouchDetected => touchDetectedNotifier.value;

  static void bindBleState() {
    final ble = BleService.instance;

    void sync() {
      connectedDeviceNameNotifier.value = ble.connectedDeviceNameNotifier.value;
      deviceConnectedNotifier.value = ble.connectedDeviceNameNotifier.value != null;
      touchDetectedNotifier.value = ble.touchDetectedNotifier.value;
    }

    ble.connectedDeviceNameNotifier.addListener(sync);
    ble.touchDetectedNotifier.addListener(sync);
    sync();
  }

  // ── EEG Scores ────────────────────────────────────────────────────────────

  /// null = no data yet; 1-10 = measured score
  static final ValueNotifier<int?> stressScoreNotifier = ValueNotifier<int?>(
    null,
  );

  static final ValueNotifier<int?> relaxationScoreNotifier =
      ValueNotifier<int?>(null);

  static int? get stressScore => stressScoreNotifier.value;
  static int? get relaxationScore => relaxationScoreNotifier.value;

  // ── Predicted vs EEG flag ─────────────────────────────────────────────────

  /// true = score came from questionnaire prediction; false = EEG headband
  static final ValueNotifier<bool> isPredictedScoreNotifier =
      ValueNotifier<bool>(false);

  static bool get isPredictedScore => isPredictedScoreNotifier.value;

  /// Derives approximate stress/relaxation scores from 10 onboarding answers.
  /// Each answer is 0-based index; option 0 = most stressed, 4 = most relaxed.
  static void predictScoresFromAnswers(List<int> answers) {
    if (answers.isEmpty) return;
    final double avg = answers.fold<int>(0, (a, b) => a + b) / answers.length;
    // avg range 0.0–4.0 → stress 10→1, relax 1→10
    final int stress = (10 - (avg / 4.0 * 9)).round().clamp(1, 10);
    final int relax = (1 + (avg / 4.0 * 9)).round().clamp(1, 10);
    stressScoreNotifier.value = stress;
    relaxationScoreNotifier.value = relax;
    isPredictedScoreNotifier.value = true;
  }

  static void updateScores({required int stress, required int relaxation}) {
    stressScoreNotifier.value = stress;
    relaxationScoreNotifier.value = relaxation;
    isPredictedScoreNotifier.value = false; // EEG overrides prediction
  }

  static void resetScores() {
    stressScoreNotifier.value = null;
    relaxationScoreNotifier.value = null;
    isPredictedScoreNotifier.value = false;
  }

  // ── Recommendation helpers ────────────────────────────────────────────────

  static AppRecommendation get currentRecommendation {
    final int? stress = stressScore;
    final int? relax = relaxationScore;

    if (stress == null || relax == null) {
      return AppRecommendation.defaultTip;
    }
    if (stress >= 7) return AppRecommendation.breathing;
    if (relax <= 3) return AppRecommendation.music;
    return AppRecommendation.meditation;
  }
}

enum AppRecommendation { defaultTip, breathing, music, meditation }

extension RecommendationDetails on AppRecommendation {
  String get headline {
    switch (this) {
      case AppRecommendation.breathing:
        return 'Hít thở sâu ngay bây giờ';
      case AppRecommendation.music:
        return 'Thư giãn cùng âm nhạc';
      case AppRecommendation.meditation:
        return 'Ổn định tâm trí hôm nay';
      case AppRecommendation.defaultTip:
        return 'Hãy giữ nhịp hôm nay';
    }
  }

  String get description {
    switch (this) {
      case AppRecommendation.breathing:
        return 'Mức căng thẳng của bạn đang cao. Bài tập hít thở 4-7-8 sẽ giúp bạn hạ nhiệt nhanh chóng.';
      case AppRecommendation.music:
        return 'Mức thư giãn còn thấp. Hãy thử nghe nhạc thiền định nhẹ nhàng để lấy lại cân bằng.';
      case AppRecommendation.meditation:
        return 'Tâm trạng ổn định tốt. Một buổi thiền định ngắn sẽ củng cố thêm sự bình tâm của bạn.';
      case AppRecommendation.defaultTip:
        return 'Kết nối headband để nhận phân tích sóng não và gợi ý cá nhân hoá.';
    }
  }

  String get actionLabel {
    switch (this) {
      case AppRecommendation.breathing:
        return 'Bắt đầu bài thở';
      case AppRecommendation.music:
        return 'Nghe nhạc thư giãn';
      case AppRecommendation.meditation:
        return 'Bắt đầu thiền ngay';
      case AppRecommendation.defaultTip:
        return 'Bắt đầu thiền ngay';
    }
  }
}
