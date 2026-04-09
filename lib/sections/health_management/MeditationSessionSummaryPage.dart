import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'HealthTabMenu.dart';
import 'SumaryHealthPage.dart';

class MeditationSessionSummaryPage extends StatelessWidget {
  const MeditationSessionSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      bottomNavigationBar: const HealthTabMenu(currentIndex: 2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              _SummaryHeader(onBack: () => Navigator.of(context).maybePop()),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ScoreOverviewCard(),
                      const SizedBox(height: 12),
                      const _TimelineSection(),
                      const SizedBox(height: 12),
                      const _CommentSection(),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const SumaryHealthPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0E9BB1),
                            foregroundColor: AppColors.white,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Tổng Quan',
                            style: TextStyle(
                              fontSize: 14.4,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
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

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE5E5E5),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 9.6,
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.neutral700,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Tóm tắt Phiên thiền',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _ScoreOverviewCard extends StatelessWidget {
  const _ScoreOverviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF79C88E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '9.1',
                      style: TextStyle(
                        fontSize: 60,
                        height: 0.95,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF139C39),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Điểm thiền',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF40A95A),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 88,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFADE8B9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Text(
                      '+0.8',
                      style: TextStyle(
                        fontSize: 21.6,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2F9E47),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'So với Trung Bình',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 8.4,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2F9E47),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: CustomPaint(
              painter: _ScoreTrendPainter(),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Rất tốt! Duy trì các nhịp tâm ấn tượng lần 3 của bạn',
            style: TextStyle(
              fontSize: 9.6,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: _MetricMiniCard(
                  value: '10:00',
                  label: 'Tổng thời gian',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _MetricMiniCard(
                  value: '08:25',
                  label: 'Thời gian tỉnh tâm',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _MetricMiniCard(
                  value: '91%',
                  label: 'Hiệu suất tập trung',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricMiniCard extends StatelessWidget {
  const _MetricMiniCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 26.4,
                height: 1,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2F9E47),
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10.8,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dòng thời gian & sự kiện chính',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(9, 10, 9, 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: const Column(
            children: [
              _TimelineEvent(
                time: '02:10 - 04:10',
                title: 'Khoảnh Khắc Alpha Đỉnh cao',
                detail:
                    'Duy trì rất lâu gần Alpha ổn định 95 giây. Đây là trạng thái tỉnh thức lý tưởng.',
                color: Color(0xFF39B25D),
              ),
              _TimelineDivider(),
              _TimelineEvent(
                time: '07:05',
                title: 'Thích thực: Tăng Beta nhẹ',
                detail:
                    'Sóng Beta tăng 15% chỉ số mới 10 giây nhẹ. Bạn nên ổn định chậm tốt, giảm Beta sau 12 giây',
                color: Color(0xFFF4A62A),
              ),
              _TimelineDivider(),
              _TimelineEvent(
                time: '09:15 - 10:00',
                title: 'Kết thúc Thiền sâu (Chuyển Theta)',
                detail:
                    'Mức Theta tăng lên, cho thấy bạn đạt trạng thái nghỉ ngơi sâu trước khi kết thúc phiên.',
                color: Color(0xFF1AA1D2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineEvent extends StatelessWidget {
  const _TimelineEvent({
    required this.time,
    required this.title,
    required this.detail,
    required this.color,
  });

  final String time;
  final String title;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
            Container(
              width: 2,
              height: 46,
              color: const Color(0xFFE1E1E1),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10.8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.2,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutral800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineDivider extends StatelessWidget {
  const _TimelineDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 2);
  }
}

class _CommentSection extends StatelessWidget {
  const _CommentSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nhận xét',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF6AC18C), width: 1),
          ),
          child: const Text(
            'Mục tiêu Alpha/Theta đã đạt được một cách xuất sắc. Khi năng nhịp của bạn sau thích thực Beta lúc 07:05 đã trở lại ổn định trên thành tựu tốt. Tiếp tục duy trì thói quen này!',
            style: TextStyle(
              fontSize: 13.2,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreTrendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()..moveTo(0, size.height * 0.85);
    path.cubicTo(
      size.width * 0.2,
      size.height * 0.35,
      size.width * 0.33,
      size.height * 0.95,
      size.width * 0.48,
      size.height * 0.55,
    );
    path.cubicTo(
      size.width * 0.65,
      0,
      size.width * 0.75,
      size.height * 0.7,
      size.width,
      size.height * 0.45,
    );

    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF59B96C)
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, stroke);

    final Path fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..style = PaintingStyle.fill
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x5959B96C),
            Color(0x0859B96C),
          ],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}