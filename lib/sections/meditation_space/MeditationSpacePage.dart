import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class MeditationSpacePage extends StatelessWidget {
  const MeditationSpacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(onBack: () => Navigator.of(context).maybePop()),
              const SizedBox(height: 14),
              const _SearchField(),
              const SizedBox(height: 18),
              const Text(
                'Danh mục nổi bật',
                style: TextStyle(
                  fontSize: 34 / 2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Expanded(
                    child: _FeaturedCategoryCard(
                      iconPath: 'assets/Icons/solar_sleeping-circle-broken.png',
                      title: 'Giấc Ngủ',
                      color: AppColors.meditationSpacePrimary,
                      backgroundColor: AppColors.meditationSpaceBlueBackground,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _FeaturedCategoryCard(
                      iconPath: 'assets/Icons/Vector.png',
                      title: 'Giảm Stress',
                      color: AppColors.meditationSpaceOrange,
                      backgroundColor: AppColors.meditationSpacePeachBackground,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _FeaturedCategoryCard(
                      iconPath: 'assets/Icons/Group.png',
                      title: 'Tập Trung',
                      color: AppColors.meditationSpaceGreen,
                      backgroundColor: AppColors.meditationSpaceMintBackground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Đề xuất (Dựa trên phân tích sóng não)',
                style: TextStyle(
                  fontSize: 34 / 2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 10),
              const _MeditationProgramCard(
                title: 'Thiền Cân Bằng Cảm Xúc',
                subtitle: 'Bài 1/5 của khóa học • 15 phút',
                backgroundColor: AppColors.white,
                borderColor: AppColors.meditationSpacePrimary,
                titleColor: AppColors.meditationSpacePrimary,
                buttonFilled: true,
                buttonColor: AppColors.meditationSpacePrimary,
                iconColor: AppColors.meditationSpacePrimary,
              ),
              const SizedBox(height: 20),
              const Text(
                'Lộ trình Cơ Bản (Chưa hoàn thành)',
                style: TextStyle(
                  fontSize: 34 / 2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 10),
              const _MeditationProgramCard(
                title: 'Thiền Cân Bằng Cảm Xúc',
                subtitle: 'Bài 1/5 của khóa học • 15 phút',
                backgroundColor: AppColors.meditationSpaceBlueBackground,
                borderColor: Color(0xFFD6EEF2),
                titleColor: AppColors.meditationSpacePrimary,
                buttonFilled: false,
                buttonColor: AppColors.meditationSpacePrimary,
                iconColor: AppColors.meditationSpacePrimary,
              ),
              const SizedBox(height: 10),
              const _MeditationProgramCard(
                title: 'Hít Thở Sâu 5 Phút',
                subtitle: 'Bài tập nhanh • 5 phút',
                backgroundColor: AppColors.meditationSpaceBlueBackground,
                borderColor: Color(0xFFD6EEF2),
                titleColor: AppColors.meditationSpacePrimary,
                buttonFilled: false,
                buttonColor: AppColors.meditationSpacePrimary,
                iconColor: AppColors.meditationSpacePrimary,
              ),
              const SizedBox(height: 20),
              const Text(
                'Bài đã tập gần đây',
                style: TextStyle(
                  fontSize: 34 / 2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 10),
              const _MeditationProgramCard(
                title: 'Thiền cân bằng cảm xúc',
                subtitle: 'Bài 1/5 của khóa học • 15 phút',
                backgroundColor: AppColors.meditationSpaceMintBackground,
                borderColor: Color(0xFFD1F5D7),
                titleColor: AppColors.meditationSpaceGreen,
                buttonFilled: true,
                buttonColor: Color(0xFF68D178),
                iconColor: AppColors.meditationSpaceGreen,
              ),
              const SizedBox(height: 10),
              const _MeditationProgramCard(
                title: 'Hít thở sâu 5 phút',
                subtitle: 'Bài tập nhanh • 5 phút',
                backgroundColor: AppColors.meditationSpaceMintBackground,
                borderColor: Color(0xFFD1F5D7),
                titleColor: AppColors.meditationSpaceGreen,
                buttonFilled: true,
                buttonColor: Color(0xFF68D178),
                iconColor: AppColors.meditationSpaceGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.neutral100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: onBack,
              iconSize: 17,
              splashRadius: 17,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, color: AppColors.neutral700),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Không gian thiền định',
                style: TextStyle(
                  fontSize: 36 / 2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: AppColors.neutral400),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tìm kiếm bài thiền....',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.mic_none_rounded, color: AppColors.neutral400),
        ],
      ),
    );
  }
}

class _FeaturedCategoryCard extends StatelessWidget {
  const _FeaturedCategoryCard({
    required this.iconPath,
    required this.title,
    required this.color,
    required this.backgroundColor,
  });

  final String iconPath;
  final String title;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 102,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: 42,
            height: 42,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(height: 7),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 31 / 2,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MeditationProgramCard extends StatelessWidget {
  const _MeditationProgramCard({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.borderColor,
    required this.titleColor,
    required this.buttonFilled,
    required this.buttonColor,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final bool buttonFilled;
  final Color buttonColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: iconColor.withValues(alpha: 0.25)),
            ),
            child: Icon(Icons.self_improvement_outlined, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 86,
            height: 36,
            child: buttonFilled
                ? FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Bắt đầu',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  )
                : OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: buttonColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Bắt đầu',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: buttonColor,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
