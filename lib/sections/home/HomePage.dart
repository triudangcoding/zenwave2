import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../brain_overview/BrainOverviewPage.dart';
import '../meditation_space/MeditationSpacePage.dart';
import 'StartMeditation2.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              child: _buildHeader(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRecommendedCard(context),
                    const SizedBox(height: 10),
                    _buildStatsCard(),
                    const SizedBox(height: 12),
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
                        const _OverviewCard(
                          title: 'Theo Dõi Tâm Trạng',
                          backgroundColor: AppColors.homeOverviewMood,
                          imagePath: 'assets/Images/HomePage3.png',
                        ),
                        const _OverviewCard(
                          title: 'Các Bài Luyện Tập Hơi Thở',
                          backgroundColor: AppColors.homeOverviewAi,
                          imagePath: 'assets/Images/HomePage5.png',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildDailySection(),
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

  Widget _buildHeader() {
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
            child: const Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 21,
                  color: AppColors.neutral900,
                ),
                Positioned(
                  right: 9,
                  top: 10,
                  child: CircleAvatar(radius: 3, backgroundColor: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 0),
      decoration: BoxDecoration(
        color: AppColors.homeRecommendedCard,
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
              padding: EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hãy giữ nhịp hôm nay',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bài tập được đề xuất:',
                    style: TextStyle(fontSize: 13, color: AppColors.neutral900),
                  ),
                  Text(
                    'Thiền thở (10 phút)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral900,
                    ),
                  ),
                  SizedBox(height: 10),
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
                      child: const Text(
                        'Bắt đầu thiền ngay',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
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

  Widget _buildDailySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hằng ngày',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
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
            children: const [
              Text(
                'Chưa có dữ liệu sóng não',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.homeDailyHeadline,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Hãy kết nối thiết bị để bắt đầu theo dõi chỉ số tập trung và thư giãn.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.35,
                  color: AppColors.homeDailyBody,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Xem hướng dẫn kết nối thiết bị ->',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.homeDailyLink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
