import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AssessmentTheme {
  AssessmentTheme._();

  static const Color pageBackground = AppColors.homeBackground;
  static const Color textPrimary = AppColors.neutral900;
  static const Color textSecondary = AppColors.neutral700;
  static const Color cardBorder = AppColors.homeQuickTileBorder;
  static const Color shadow = AppColors.homeCardShadow;

  static const Color hubHeroStart = AppColors.teal400;
  static const Color hubHeroEnd = AppColors.cyan600;

  static const Color stressAccent = AppColors.orange700;
  static const Color stressSoft = AppColors.orange100;

  static const Color nutritionAccent = AppColors.green700;
  static const Color nutritionSoft = AppColors.green100;

  static const Color ecogAccent = AppColors.cyan700;
  static const Color ecogSoft = AppColors.cyan100;

  static const Color sleepAccent = AppColors.red700;
  static const Color sleepSoft = AppColors.red200;

  static BoxDecoration softCard({required Color softColor}) {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: cardBorder),
      boxShadow: const [
        BoxShadow(color: shadow, blurRadius: 6, offset: Offset(0, 2)),
      ],
    );
  }
}
