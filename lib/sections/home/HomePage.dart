import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../screens/assessment/AssessmentHubScreen.dart';
import '../../screens/Breathing/BreathingListScreen.dart';
import '../../services/app_state_service.dart';
import '../brain_overview/BrainOverviewPage.dart';
import '../meditation_space/MeditationSpacePage.dart';
import 'StartMeditation2.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _openBrainOverview(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const BrainOverviewPage()));
  }

  void _openMeditationSpace(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const MeditationSpacePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: _buildHeader(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recommendation card is reactive to EEG scores
                    ValueListenableBuilder<int?>(
                      valueListenable: AppStateService.stressScoreNotifier,
                      builder: (_, __, ___) => ValueListenableBuilder<int?>(
                        valueListenable:
                            AppStateService.relaxationScoreNotifier,
                        builder: (_, __, ___) =>
                            _buildRecommendedCard(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildStatsCard(),
                    const SizedBox(height: 12),
                    // EEG scores section (replaces the old "daily" section)
                    ValueListenableBuilder<bool>(
                      valueListenable: AppStateService.deviceConnectedNotifier,
                      builder: (_, __, ___) =>
                          ValueListenableBuilder<int?>(
                            valueListenable:
                                AppStateService.stressScoreNotifier,
                            builder: (_, __, ___) =>
                                ValueListenableBuilder<int?>(
                                  valueListenable:
                                      AppStateService.relaxationScoreNotifier,
                                  builder: (_, __, ___) =>
                                      _buildEegSection(context),
                                ),
                          ),
                    ),
                    const SizedBox(height: 14),
                    // Stress scale section
                    ValueListenableBuilder<int?>(
                      valueListenable: AppStateService.stressScoreNotifier,
                      builder: (_, __, ___) => _buildStressScaleSection(),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Tổng quan',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.55,
                      children: [
                        _OverviewCard(
                          title: 'Tổng Quan Sóng Não',
                          backgroundColor: AppColors.homeOverviewBrain,
                          imagePath: 'assets/Images/HomePage2.png',
                          onTap: () => _openBrainOverview(context),
                        ),
                        _OverviewCard(
                          title: 'Không gian thiền định',
                          backgroundColor: AppColors.homeOverviewSpace,
                          imagePath: 'assets/Images/HomePage4.png',
                          onTap: () => _openMeditationSpace(context),
                        ),
                        _OverviewCard(
                          title: 'Bài tập thở',
                          backgroundColor: AppColors.homeOverviewMood,
                          imagePath: 'assets/Images/HomePage3.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const BreathingListScreen(),
                              ),
                            );
                          },
                        ),
                        _OverviewCard(
                          title: 'Bài tập đánh giá sức khỏe',
                          backgroundColor: AppColors.homeOverviewAi,
                          imagePath: 'assets/Images/HomePage5.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AssessmentHubScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildQuickActionsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openConnectDeviceSheet(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierLabel: 'Connect Device',
      barrierDismissible: true,
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: FractionallySizedBox(
              widthFactor: 0.88,
              heightFactor: 1,
              child: const _ConnectDeviceSideSheet(),
            ),
          ),
        );
      },
      transitionBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.homeWelcomeAvatar,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/Images/HomePage3.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  size: 21,
                  color: AppColors.neutral700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Chào buổi sáng, Zenwave',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.neutral100,
              shape: BoxShape.circle,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _openConnectDeviceSheet(context),
              child: const Icon(
                Icons.bluetooth_searching,
                size: 21,
                color: AppColors.neutral900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(BuildContext context) {
    final rec = AppStateService.currentRecommendation;
    final int? stress = AppStateService.stressScore;

    // Card accent colour changes based on recommendation
    final Color cardBg;
    final IconData recIcon;
    if (stress != null && stress >= 7) {
      cardBg = const Color(0xFFFFE8CC);
      recIcon = Icons.air;
    } else if (AppStateService.relaxationScore != null &&
        AppStateService.relaxationScore! <= 3) {
      cardBg = const Color(0xFFD6EFF9);
      recIcon = Icons.music_note_outlined;
    } else {
      cardBg = AppColors.homeRecommendedCard;
      recIcon = Icons.self_improvement_outlined;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.homeCardShadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(recIcon, size: 16, color: AppColors.neutral700),
                      const SizedBox(width: 5),
                      const Text(
                        'Gợi ý hôm nay',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.neutral700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rec.headline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rec.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: AppColors.neutral700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 34,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const StartMeditationPage(),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.cyan500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      child: Text(
                        rec.actionLabel,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: Image.asset(
                  'assets/Images/HomePage1.png',
                  height: 144,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.self_improvement,
                    size: 90,
                    color: AppColors.cyan600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.homeStatsBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.homeCardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            value: '600\'',
            label: 'Tổng thời gian',
            color: AppColors.homeStatsTime,
          ),
          _StatItem(
            value: '21',
            label: 'Chuỗi Ngày',
            color: AppColors.homeStatsStreak,
          ),
          _StatItem(
            value: '92',
            label: 'Health Score',
            color: AppColors.homeStatsScore,
          ),
        ],
      ),
    );
  }

  Widget _buildEegSection(BuildContext context) {
    final int? stress = AppStateService.stressScore;
    final int? relax = AppStateService.relaxationScore;
    final bool connected = AppStateService.isDeviceConnected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chỉ số sóng não',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 8),
        if (stress == null || relax == null)
          // ── No data state ──────────────────────────────────────────────
          GestureDetector(
            onTap: () => _openConnectDeviceSheet(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              decoration: BoxDecoration(
                color: AppColors.homeSectionCardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.homeSectionCardBorder),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.homeCardShadow,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: connected
                          ? AppColors.teal100
                          : AppColors.neutral100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      connected
                          ? Icons.sensors
                          : Icons.bluetooth_searching,
                      color: connected
                          ? AppColors.cyan600
                          : AppColors.neutral500,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          connected
                              ? 'Đang chờ dữ liệu EEG...'
                              : 'Chưa kết nối thiết bị',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          connected
                              ? 'Nhận dữ liệu từ headband để xem chỉ số.'
                              : 'Nhấn để kết nối headband và bắt đầu đo.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.neutral500,
                  ),
                ],
              ),
            ),
          )
        else
          // ── Has data state ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.homeSectionCardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.homeSectionCardBorder),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.homeCardShadow,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.green500,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Dữ liệu thời gian thực',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.neutral600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ScoreGauge(
                        label: 'Căng thẳng',
                        score: stress,
                        highIsBad: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ScoreGauge(
                        label: 'Thư giãn',
                        score: relax,
                        highIsBad: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _eegInterpretation(stress, relax),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutral700,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _eegInterpretation(int stress, int relax) {
    if (stress >= 7) {
      return 'Mức căng thẳng đang cao ($stress/10). Hãy thử bài tập hít thở để hạ nhiệt.';
    } else if (relax <= 3) {
      return 'Mức thư giãn còn thấp ($relax/10). Nghe nhạc nhẹ hoặc thiền có thể giúp bạn.';
    } else if (stress <= 3 && relax >= 7) {
      return 'Tuyệt vời! Tâm trí bạn đang rất cân bằng. Tiếp tục duy trì nhé.';
    }
    return 'Chỉ số tương đối ổn định. Một bài thiền ngắn sẽ giúp bạn củng cố thêm.';
  }

  // ── Stress scale 1-10 section ─────────────────────────────────────────────

  Widget _buildStressScaleSection() {
    final int? stress = AppStateService.stressScore;

    // Zone definitions: label, range, color
    const List<_StressZone> zones = [
      _StressZone(label: 'Bình tĩnh', range: '1–2', from: 1, to: 2,
          color: Color(0xFF22C55E)),
      _StressZone(label: 'Bình thường', range: '3–4', from: 3, to: 4,
          color: Color(0xFF86EFAC)),
      _StressZone(label: 'Nhẹ', range: '5–6', from: 5, to: 6,
          color: Color(0xFFFACC15)),
      _StressZone(label: 'Vừa', range: '7–8', from: 7, to: 8,
          color: Color(0xFFF97316)),
      _StressZone(label: 'Cao', range: '9–10', from: 9, to: 10,
          color: Color(0xFFEF4444)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Mức độ căng thẳng',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const Spacer(),
            if (stress != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _stressColor(stress).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _stressColor(stress).withValues(alpha: 0.4)),
                ),
                child: Text(
                  '$stress / 10',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _stressColor(stress),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.homeSectionCardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.homeSectionCardBorder),
            boxShadow: const [
              BoxShadow(
                color: AppColors.homeCardShadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Gradient bar with pointer ──────────────────────────────
              LayoutBuilder(
                builder: (context, constraints) {
                  final double barWidth = constraints.maxWidth;
                  final double thumbX = stress != null
                      ? ((stress - 1) / 9) * barWidth
                      : -1;

                  return Column(
                    children: [
                      if (stress != null)
                        Padding(
                          padding: EdgeInsets.only(
                            left: (thumbX - 18).clamp(0, barWidth - 36),
                          ),
                          child: Container(
                            width: 36,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _stressColor(stress),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$stress',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      if (stress != null) const SizedBox(height: 4),
                      // Gradient bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 18,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF22C55E),
                                Color(0xFF86EFAC),
                                Color(0xFFFACC15),
                                Color(0xFFF97316),
                                Color(0xFFEF4444),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Tick marks: 1 … 10
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List<Widget>.generate(10, (i) {
                            final int val = i + 1;
                            final bool active = stress == val;
                            return Text(
                              '$val',
                              style: TextStyle(
                                fontSize: active ? 13 : 11,
                                fontWeight: active
                                    ? FontWeight.w800
                                    : FontWeight.w400,
                                color: active
                                    ? _stressColor(stress!)
                                    : AppColors.neutral500,
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              // ── Zone chips ─────────────────────────────────────────────
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: zones.map((zone) {
                  final bool active = stress != null &&
                      stress >= zone.from && stress <= zone.to;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: active
                          ? zone.color.withValues(alpha: 0.18)
                          : AppColors.neutral100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active
                            ? zone.color
                            : AppColors.neutral200,
                        width: active ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active ? zone.color : AppColors.neutral300,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${zone.label} (${zone.range})',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: active
                                ? zone.color
                                : AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              // ── Advice text when there is a score ──────────────────────
              if (stress != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _stressColor(stress).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _stressAdvice(stress),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: _stressColor(stress),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                const Text(
                  'Kết nối headband để đo mức độ căng thẳng của bạn.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static Color _stressColor(int score) {
    if (score <= 2) return const Color(0xFF22C55E);
    if (score <= 4) return const Color(0xFF65A30D);
    if (score <= 6) return const Color(0xFFCA8A04);
    if (score <= 8) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  static String _stressAdvice(int score) {
    if (score <= 2) return '✦ Bạn đang rất bình tĩnh. Duy trì trạng thái này thật tuyệt vời!';
    if (score <= 4) return '✦ Mức căng thẳng ở ngưỡng bình thường. Bạn đang kiểm soát tốt.';
    if (score <= 6) return '✦ Căng thẳng ở mức nhẹ. Thử một bài thiền ngắn để giữ cân bằng.';
    if (score <= 8) return '✦ Mức căng thẳng khá cao. Hãy thực hành hít thở 4-7-8 ngay bây giờ.';
    return '✦ Căng thẳng ở mức cao nhất. Dừng lại, hít thở sâu và thư giãn hoàn toàn.';
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tác vụ nhanh',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.0,
          children: const [
            _QuickActionTile(
              icon: Icons.self_improvement_outlined,
              label: 'Bắt đầu\nthiền 10 phút',
              iconColor: AppColors.homeQuickMeditationIcon,
              iconBackground: AppColors.homeQuickMeditationBg,
            ),
            _QuickActionTile(
              icon: Icons.calendar_month_outlined,
              label: 'Đặt lịch\nnhắc nhở',
              iconColor: AppColors.homeQuickReminderIcon,
              iconBackground: AppColors.homeQuickReminderBg,
            ),
            _QuickActionTile(
              icon: Icons.description_outlined,
              label: 'Xem tiến\ntrình tuần',
              iconColor: AppColors.homeQuickWeeklyIcon,
              iconBackground: AppColors.homeQuickWeeklyBg,
            ),
            _QuickActionTile(
              icon: Icons.handshake_outlined,
              label: 'Kết nối\nchuyên gia',
              iconColor: AppColors.homeQuickExpertIcon,
              iconBackground: AppColors.homeQuickExpertBg,
            ),
          ],
        ),
      ],
    );
  }
}

class _ConnectDeviceSideSheet extends StatefulWidget {
  const _ConnectDeviceSideSheet();

  @override
  State<_ConnectDeviceSideSheet> createState() =>
      _ConnectDeviceSideSheetState();
}

class _ConnectDeviceSideSheetState extends State<_ConnectDeviceSideSheet> {
  bool _isScanning = true;
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isReceivingData = false;
  String _selectedDevice = 'ZenWave NeuroBand X2';
  double _batteryLevel = 0.78;
  Timer? _scanTimer;

  final List<String> _devices = <String>[
    'ZenWave NeuroBand X2',
    'ZenWave NeuroBand Pro',
    'MindFlow Sensor A1',
  ];

  @override
  void initState() {
    super.initState();
    _isConnected = AppStateService.isDeviceConnected;
    _scanTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _isScanning = false;
      });
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }

  Future<void> _connectToDevice() async {
    setState(() {
      _isConnecting = true;
      _isConnected = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) {
      return;
    }

    setState(() {
      _isConnecting = false;
      _isConnected = true;
      _batteryLevel = 0.82;
    });
    AppStateService.deviceConnectedNotifier.value = true;
    AppStateService.resetScores();
  }

  /// Simulates receiving an EEG measurement from the headband.
  Future<void> _receiveEegData() async {
    setState(() => _isReceivingData = true);
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    // Generate demo scores — vary each call for a realistic feel
    final now = DateTime.now().millisecondsSinceEpoch;
    final stress = 4 + (now % 5).toInt(); // 4-8
    final relax = 10 - stress + 1;        // inverse trend ~2-7

    AppStateService.updateScores(stress: stress, relaxation: relax);
    setState(() => _isReceivingData = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Kết nối thiết bị sóng não',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.neutral700),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.teal100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.teal300),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 46,
                      height: 46,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _batteryLevel,
                            strokeWidth: 4,
                            backgroundColor: AppColors.teal200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.cyan500,
                            ),
                          ),
                          Text(
                            '${(_batteryLevel * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cyan700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isConnected
                            ? 'Đã kết nối với $_selectedDevice'
                            : 'Trạng thái pin thiết bị khả dụng',
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.neutral900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text(
                    'Thiết bị gần đây',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral800,
                    ),
                  ),
                  const Spacer(),
                  if (_isScanning)
                    const Text(
                      'Đang quét...',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.cyan700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: _devices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final deviceName = _devices[index];
                    final selected = _selectedDevice == deviceName;
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _selectedDevice = deviceName;
                          _isConnected = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.teal100 : AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.cyan500
                                : AppColors.homeQuickTileBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.cyan200
                                    : AppColors.neutral100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.sensors,
                                color: selected
                                    ? AppColors.cyan700
                                    : AppColors.neutral700,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    deviceName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.neutral900,
                                    ),
                                  ),
                                  Text(
                                    _isConnected && selected
                                        ? 'Đã ghép nối'
                                        : 'Sẵn sàng kết nối',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.neutral700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_isConnected && selected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.green600,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isConnecting || _isConnected
                      ? null
                      : _connectToDevice,
                  style: FilledButton.styleFrom(
                    backgroundColor: _isConnected
                        ? AppColors.green600
                        : AppColors.cyan500,
                    disabledBackgroundColor: _isConnected
                        ? AppColors.green600
                        : AppColors.neutral300,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isConnecting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isConnected
                                  ? Icons.check_circle_outline
                                  : Icons.bluetooth,
                              size: 18,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isConnected
                                  ? 'Đã kết nối thành công'
                                  : 'Kết nối thiết bị',
                              style: const TextStyle(color: AppColors.white),
                            ),
                          ],
                        ),
                ),
              ),
              if (_isConnected) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isReceivingData ? null : _receiveEegData,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.teal700,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isReceivingData
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Đang đo sóng não...',
                                style: TextStyle(color: AppColors.white),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.graphic_eq,
                                size: 18,
                                color: AppColors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Nhận dữ liệu EEG',
                                style: TextStyle(color: AppColors.white),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.neutral900),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.title,
    required this.backgroundColor,
    required this.imagePath,
    this.onTap,
  });

  final String title;
  final Color backgroundColor;
  final String imagePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.homeCardShadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: backgroundColor),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 48,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(color: AppColors.homeOverviewFrost),
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      bottom: 16,
                    ),
                    child: Image.asset(
                      imagePath,
                      height: 80,
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.white,
                        size: 34,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.homeOverviewInnerShadowTop,
                          Colors.transparent,
                          Colors.transparent,
                          AppColors.homeOverviewInnerShadowBottom,
                        ],
                        stops: [0.0, 0.15, 0.72, 1.0],
                      ),
                      border: Border.all(color: AppColors.homeOverviewStroke),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 12,
                right: 12,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14.3,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
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

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBackground,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.homeQuickTileBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 34, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: AppColors.neutral900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stress zone data class ────────────────────────────────────────────────

class _StressZone {
  final String label;
  final String range;
  final int from;
  final int to;
  final Color color;
  const _StressZone({
    required this.label,
    required this.range,
    required this.from,
    required this.to,
    required this.color,
  });
}

// ── Score gauge widget ────────────────────────────────────────────────────

class _ScoreGauge extends StatelessWidget {
  const _ScoreGauge({
    required this.label,
    required this.score,
    required this.highIsBad,
  });

  final String label;
  final int score;
  final bool highIsBad;

  Color get _barColor {
    final double pct = score / 10;
    if (highIsBad) {
      if (pct >= 0.7) return AppColors.red500;
      if (pct >= 0.4) return AppColors.orange500;
      return AppColors.green500;
    } else {
      if (pct >= 0.7) return AppColors.green500;
      if (pct >= 0.4) return AppColors.orange400;
      return AppColors.red400;
    }
  }

  String get _statusLabel {
    final double pct = score / 10;
    if (highIsBad) {
      if (pct >= 0.7) return 'Cao';
      if (pct >= 0.4) return 'Trung bình';
      return 'Thấp';
    } else {
      if (pct >= 0.7) return 'Tốt';
      if (pct >= 0.4) return 'Trung bình';
      return 'Thấp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: _barColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _barColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.neutral600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _barColor,
                  height: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 3, left: 2),
                child: Text(
                  '/10',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.neutral500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 10,
              minHeight: 6,
              backgroundColor: AppColors.neutral100,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _barColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _statusLabel,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: _barColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
