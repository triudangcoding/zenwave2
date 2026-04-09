import 'package:flutter/material.dart';

import 'DetailLessonMeditation.dart';
import '../../core/theme/app_colors.dart';
import '../health_management/HealthTabMenu.dart';

enum LessonState { completed, inProgress, ready, locked }

class MeditationLesson {
  const MeditationLesson({
    required this.number,
    required this.title,
    required this.durationLabel,
    required this.state,
  });
  final int number;
  final String title;
  final String durationLabel;
  final LessonState state;
}

class LessonTestMeditationPage extends StatefulWidget {
  const LessonTestMeditationPage({
    super.key,
    required this.courseTitle,
    this.totalLessons = 10,
    this.completedProgress = 5,
    this.inProgressLesson = 4,
  });

  final String courseTitle;
  final int totalLessons;
  final int completedProgress;
  final int inProgressLesson;

  @override
  State<LessonTestMeditationPage> createState() =>
      _LessonTestMeditationPageState();
}

class _LessonTestMeditationPageState extends State<LessonTestMeditationPage> {
  late final List<MeditationLesson> _lessons;

  @override
  void initState() {
    super.initState();
    _lessons = _buildLessons();
  }

  List<MeditationLesson> _buildLessons() {
    final List<String> lessonTitles = [
      'Nền tảng hơi thở',
      'Thả lỏng cơ thể',
      'Nhận Diện Suy Nghĩ',
      'Cảm Giác Cơ Thể',
      'Xử Lý Cảm Xúc Tiêu Cực',
      'Thiền Từ Bi (Metta)',
      'Thiền Chấp Nhận',
      'Thiền Lưu Thông',
      'Thiền Khai Mở',
      'Thiền Giác Ngộ',
    ];

    return List<MeditationLesson>.generate(widget.totalLessons, (index) {
      final int lessonNumber = index + 1;

      LessonState state;
      if (lessonNumber < widget.inProgressLesson) {
        state = LessonState.completed;
      } else if (lessonNumber == widget.inProgressLesson) {
        state = LessonState.inProgress;
      } else if (lessonNumber == widget.inProgressLesson + 1) {
        state = LessonState.ready;
      } else {
        state = LessonState.locked;
      }

      return MeditationLesson(
        number: lessonNumber,
        title: lessonTitles[index % lessonTitles.length],
        durationLabel: lessonNumber <= 4
            ? 'Bài tập nhanh • 5 phút'
            : 'Thời gian • 15 phút',
        state: state,
      );
    });
  }

  void _onLessonTap(MeditationLesson lesson) {
    String message;
    switch (lesson.state) {
      case LessonState.completed:
        message = 'Mở lại Bài ${lesson.number}: ${lesson.title}';
        break;
      case LessonState.inProgress:
        message = 'Tiếp tục Bài ${lesson.number}: ${lesson.title}';
        break;
      case LessonState.ready:
        message = 'Bắt đầu Bài ${lesson.number}: ${lesson.title}';
        break;
      case LessonState.locked:
        message =
            'Bài ${lesson.number} chưa mở. Hãy hoàn thành bài trước để mở khóa.';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1300),
      ),
    );
  }

  void _openLessonDetail(MeditationLesson lesson) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailLessonMeditationPage(
          lessonNumber: lesson.number,
          lessonTitle: lesson.title,
          isResume: lesson.state == LessonState.inProgress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progressValue =
        (widget.completedProgress / widget.totalLessons).clamp(0, 1).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      bottomNavigationBar: const HealthTabMenu(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: AppColors.neutral700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.courseTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral900,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    decoration: BoxDecoration(
                      color: _LessonColors.progressSectionBackground,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: _LessonColors.softShadow,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tiến trình của bạn',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.cyan600,
                              ),
                            ),
                            Text(
                              '${widget.completedProgress}/${widget.totalLessons}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutral700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 9,
                            value: progressValue,
                            backgroundColor: AppColors.neutral300,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.cyan600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Danh sách bài thiền',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._lessons.map(
                    (lesson) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _LessonMeditationTile(
                        lesson: lesson,
                        onTap: () => _onLessonTap(lesson),
                        onActionPressed: () {
                          if (lesson.state == LessonState.inProgress ||
                              lesson.state == LessonState.ready) {
                            _openLessonDetail(lesson);
                            return;
                          }
                          _onLessonTap(lesson);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonMeditationTile extends StatelessWidget {
  const _LessonMeditationTile({
    required this.lesson,
    required this.onTap,
    required this.onActionPressed,
  });

  final MeditationLesson lesson;
  final VoidCallback onTap;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    final _TileTokens tokens = _resolveTokens(lesson.state);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: tokens.backgroundColor,
            border: Border.all(color: tokens.borderColor),
            boxShadow: const [
              BoxShadow(
                color: _LessonColors.softShadow,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tokens.leadingBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: tokens.leadingBorder),
                ),
                child: Icon(
                  Icons.self_improvement_outlined,
                  size: 22,
                  color: tokens.leadingIcon,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bài ${lesson.number}: ${lesson.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: tokens.titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lesson.state == LessonState.completed
                          ? 'Hoàn thành • ${lesson.number}/10'
                          : lesson.durationLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: tokens.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 86,
                height: 36,
                child: FilledButton(
                  onPressed: onActionPressed,
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    backgroundColor: tokens.buttonBackground,
                    disabledBackgroundColor: tokens.buttonBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    tokens.buttonLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: tokens.buttonText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _TileTokens _resolveTokens(LessonState state) {
    switch (state) {
      case LessonState.completed:
        return const _TileTokens(
          backgroundColor: _LessonColors.completedBackground,
          borderColor: _LessonColors.completedBorder,
          titleColor: _LessonColors.completedTitle,
          subtitleColor: _LessonColors.completedSubtitle,
          leadingBackground: _LessonColors.completedLeadingBackground,
          leadingBorder: _LessonColors.completedLeadingBorder,
          leadingIcon: _LessonColors.completedLeadingIcon,
          buttonBackground: _LessonColors.completedButtonBackground,
          buttonText: _LessonColors.completedButtonText,
          buttonLabel: 'Hoàn thành',
        );
      case LessonState.inProgress:
        return const _TileTokens(
          backgroundColor: _LessonColors.inProgressBackground,
          borderColor: _LessonColors.inProgressBorder,
          titleColor: _LessonColors.inProgressTitle,
          subtitleColor: _LessonColors.inProgressSubtitle,
          leadingBackground: _LessonColors.inProgressLeadingBackground,
          leadingBorder: _LessonColors.inProgressLeadingBorder,
          leadingIcon: _LessonColors.inProgressLeadingIcon,
          buttonBackground: _LessonColors.inProgressButtonBackground,
          buttonText: _LessonColors.inProgressButtonText,
          buttonLabel: 'Đang thiền',
        );
      case LessonState.ready:
        return const _TileTokens(
          backgroundColor: _LessonColors.readyBackground,
          borderColor: _LessonColors.readyBorder,
          titleColor: _LessonColors.readyTitle,
          subtitleColor: _LessonColors.readySubtitle,
          leadingBackground: _LessonColors.readyLeadingBackground,
          leadingBorder: _LessonColors.readyLeadingBorder,
          leadingIcon: _LessonColors.readyLeadingIcon,
          buttonBackground: _LessonColors.readyButtonBackground,
          buttonText: _LessonColors.readyButtonText,
          buttonLabel: 'Bắt đầu',
        );
      case LessonState.locked:
        return const _TileTokens(
          backgroundColor: _LessonColors.lockedBackground,
          borderColor: _LessonColors.lockedBorder,
          titleColor: _LessonColors.lockedTitle,
          subtitleColor: _LessonColors.lockedSubtitle,
          leadingBackground: _LessonColors.lockedLeadingBackground,
          leadingBorder: _LessonColors.lockedLeadingBorder,
          leadingIcon: _LessonColors.lockedLeadingIcon,
          buttonBackground: _LessonColors.lockedButtonBackground,
          buttonText: _LessonColors.lockedButtonText,
          buttonLabel: 'Chưa mở',
        );
    }
  }
}

class _LessonColors {
  const _LessonColors._();

  // Global
  static const Color softShadow = Color(0x12000000);

  // Progress card
  static const Color progressSectionBackground = Color(0xFFDBFCFF);

  // Completed state palette (from design reference)
  static const Color completedBackground = Color(0xFFD0F4D5);
  static const Color completedBorder = Color(0x4D0D971F);
  static const Color completedTitle = Color(0xFF0D971F);
  static const Color completedSubtitle = Color(0xFF555555);
  static const Color completedLeadingBackground = Color(0xFFFFFFFF);
  static const Color completedLeadingBorder = Color(0x4D0D971F);
  static const Color completedLeadingIcon = Color(0xFF008713);
  static const Color completedButtonBackground = Color(0xFFFFFFFF);
  static const Color completedButtonText = Color(0xFF008713);

  // In-progress state
  static const Color inProgressBackground = Color(0xFFD7F3F9);
  static const Color inProgressBorder = Color(0xFFB7E5EF);
  static const Color inProgressTitle = AppColors.cyan600;
  static const Color inProgressSubtitle = Color(0xFF56737A);
  static const Color inProgressLeadingBackground = Color(0xFFF0FAFD);
  static const Color inProgressLeadingBorder = Color(0xFF9FD8E6);
  static const Color inProgressLeadingIcon = AppColors.cyan500;
  static const Color inProgressButtonBackground = Color(0xFFFFFFFF);
  static const Color inProgressButtonText = AppColors.cyan600;

  // Ready/Start state palette (from design reference)
  static const Color readyBackground = Color(0xFFDBFCFF);
  static const Color readyBorder = Color(0xFF0093AD);
  static const Color readyTitle = Color(0xFF0093AD);
  static const Color readySubtitle = Color(0xFF555555);
  static const Color readyLeadingBackground = Color(0xFFFFFFFF);
  static const Color readyLeadingBorder = Color(0x660093AD);
  static const Color readyLeadingIcon = Color(0xFF0093AD);
  static const Color readyButtonBackground = Color(0xFF0093AD);
  static const Color readyButtonText = Color(0xFFFFFFFF);

  // Locked state palette (from design reference)
  static const Color lockedBackground = Color(0xFFD8D8D8);
  static const Color lockedBorder = Color(0xFFBABABA);
  static const Color lockedTitle = Color(0xFF555555);
  static const Color lockedSubtitle = Color(0xFF555555);
  static const Color lockedLeadingBackground = Color(0xFFFFFFFF);
  static const Color lockedLeadingBorder = Color(0xFFD8D8D8);
  static const Color lockedLeadingIcon = Color(0xFF969696);
  static const Color lockedButtonBackground = Color(0xFF969696);
  static const Color lockedButtonText = Color(0xFFFFFFFF);
}

class _TileTokens {
  const _TileTokens({
    required this.backgroundColor,
    required this.borderColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.leadingBackground,
    required this.leadingBorder,
    required this.leadingIcon,
    required this.buttonBackground,
    required this.buttonText,
    required this.buttonLabel,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color leadingBackground;
  final Color leadingBorder;
  final Color leadingIcon;
  final Color buttonBackground;
  final Color buttonText;
  final String buttonLabel;
}
