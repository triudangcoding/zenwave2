import 'package:flutter/material.dart';

import 'StartMeditation.dart';
import '../../core/theme/app_colors.dart';
import '../health_management/HealthTabMenu.dart';

class DetailLessonMeditationPage extends StatelessWidget {
  const DetailLessonMeditationPage({
    super.key,
    required this.lessonNumber,
    required this.lessonTitle,
    required this.isResume,
  });

  final int lessonNumber;
  final String lessonTitle;
  final bool isResume;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      bottomNavigationBar: const HealthTabMenu(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
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
                        color: AppColors.neutral700,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bài $lessonNumber: $lessonTitle',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInstructionCard(),
                    const SizedBox(height: 8),
                    _buildMainContentCard(),
                    const SizedBox(height: 8),
                    const Text(
                      'Video/ Hình ảnh minh họa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(child: _buildMediaPlaceholder()),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const StartMeditationPage(),
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.cyan600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isResume ? 'Tiếp tục Thiền' : 'Bắt đầu Thiền',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFBCEAF0),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hướng dẫn',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.cyan600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Bài tập này giúp bạn kết nối tâm trí với cảm giác cơ thể, để đưa sự chú ý về hiện tại.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.neutral900,
              height: 1.25,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Các bước chuẩn bị:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.cyan600,
            ),
          ),
          SizedBox(height: 2),
          Text(
            '• Tìm nơi yên tĩnh, ngồi thoải mái với lưng thẳng.\n• Đặt tay lên đùi, lòng bàn tay ngửa hoặc úp.\n• Nhắm mắt nhẹ hoặc nhìn xuống sàn.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.neutral900,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContentCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cyan500),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nội dung chính:',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.cyan600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Chúng ta sẽ bắt đầu quét từ đỉnh đầu xuống ngón chân. Hãy chú ý đến bất kỳ cảm giác nào - căng thẳng, nóng, lạnh, hoặc rung nhẹ - mà không phán xét.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.neutral900,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPlaceholder() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF9A9A9A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Container(
          width: 62,
          height: 62,
          decoration: const BoxDecoration(
            color: Color(0x66000000),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: AppColors.white,
            size: 36,
          ),
        ),
      ),
    );
  }
}
