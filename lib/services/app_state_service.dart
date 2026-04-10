import 'package:flutter/foundation.dart';

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

  static final ValueNotifier<bool> isOnboardedNotifier =
      ValueNotifier<bool>(false);

  // ── Device ────────────────────────────────────────────────────────────────

  static final ValueNotifier<bool> deviceConnectedNotifier =
      ValueNotifier<bool>(false);

  static bool get isDeviceConnected => deviceConnectedNotifier.value;

  // ── EEG Scores ────────────────────────────────────────────────────────────

  /// null = no data yet; 1-10 = measured score
  static final ValueNotifier<int?> stressScoreNotifier =
      ValueNotifier<int?>(null);

  static final ValueNotifier<int?> relaxationScoreNotifier =
      ValueNotifier<int?>(null);

  static int? get stressScore => stressScoreNotifier.value;
  static int? get relaxationScore => relaxationScoreNotifier.value;

  static void updateScores({required int stress, required int relaxation}) {
    stressScoreNotifier.value = stress;
    relaxationScoreNotifier.value = relaxation;
  }

  static void resetScores() {
    stressScoreNotifier.value = null;
    relaxationScoreNotifier.value = null;
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
