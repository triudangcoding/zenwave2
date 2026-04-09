import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'HealthTabMenu.dart';

class SumaryHealthPage extends StatelessWidget {
  const SumaryHealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      bottomNavigationBar: const HealthTabMenu(currentIndex: 2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          child: Column(
            children: [
              _OverviewHeader(onBack: () => Navigator.of(context).maybePop()),
              const SizedBox(height: 13),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BrainPerformanceCard(),
                      const SizedBox(height: 22),
                      const _ImprovementRow(),
                      const SizedBox(height: 22),
                      const _DeepInsightCard(),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0E9BB1),
                            foregroundColor: AppColors.white,
                            minimumSize: const Size.fromHeight(62),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Bắt đầu phiên thiền mới',
                            style: TextStyle(
                              fontSize: 16.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
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

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: Row(
        children: [
          Container(
            width: 31,
            height: 31,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE5E5E5),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 13,
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
                'Tổng quan',
                style: TextStyle(
                  fontSize: 17.9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 31),
        ],
      ),
    );
  }
}

class _BrainPerformanceCard extends StatelessWidget {
  const _BrainPerformanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 13, 13, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          const Text(
            'Hiệu suất sóng não (7 ngày)',
            style: TextStyle(
              fontSize: 14.6,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 204,
            child: CustomPaint(
              painter: _WeeklyLineChartPainter(),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ChartLabel('T2'),
              _ChartLabel('T3'),
              _ChartLabel('T4'),
              _ChartLabel('T5'),
              _ChartLabel('T6'),
              _ChartLabel('T7'),
              _ChartLabel('CN'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartLabel extends StatelessWidget {
  const _ChartLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 10.6,
        fontWeight: FontWeight.w700,
        color: AppColors.neutral600,
      ),
    );
  }
}

class _ImprovementRow extends StatelessWidget {
  const _ImprovementRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _ImprovementCard(
            title: 'Alpha (Tần suất)',
            value: 'Tăng 40%',
            subtitle: 'So với tuần trước',
            color: Color(0xFF2AAA51),
            background: Color(0xFFE8F7EB),
          ),
        ),
        SizedBox(width: 13),
        Expanded(
          child: _ImprovementCard(
            title: 'Beta (Nhiễm stress)',
            value: 'Giảm 10%',
            subtitle: 'So với tuần trước',
            color: Color(0xFFE53935),
            background: Color(0xFFFFEFEF),
          ),
        ),
      ],
    );
  }
}

class _ImprovementCard extends StatelessWidget {
  const _ImprovementCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.background,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              height: 1,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeepInsightCard extends StatelessWidget {
  const _DeepInsightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFF6AC18C), width: 1),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thành tích Cải thiện Tuyệt vời',
            style: TextStyle(
              fontSize: 15.7,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B9E47),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Bạn đã thành công trong việc tăng cường khả năng thư giãn (Alpha) và giảm mức độ căng thẳng (Beta) trong suốt tuần qua. Sự kiên trì này đang tạo ra sự khác biệt lớn trong sức khỏe tinh thần của bạn.',
            style: TextStyle(
              fontSize: 12.3,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = const Color(0xFFE3E3E3)
      ..strokeWidth = 1.3;

    for (int i = 1; i <= 4; i++) {
      final double y = size.height * (i / 5);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final Path greenPath = Path()..moveTo(0, size.height * 0.72);
    greenPath.cubicTo(
      size.width * 0.2,
      size.height * 0.45,
      size.width * 0.34,
      size.height * 0.95,
      size.width * 0.46,
      size.height * 0.25,
    );
    greenPath.cubicTo(
      size.width * 0.56,
      size.height * 0.05,
      size.width * 0.72,
      size.height * 0.62,
      size.width,
      size.height * 0.35,
    );

    final Path redPath = Path()..moveTo(0, size.height * 0.42);
    redPath.cubicTo(
      size.width * 0.17,
      size.height * 0.78,
      size.width * 0.34,
      size.height * 0.12,
      size.width * 0.5,
      size.height * 0.48,
    );
    redPath.cubicTo(
      size.width * 0.68,
      size.height * 0.82,
      size.width * 0.83,
      size.height * 0.94,
      size.width,
      size.height * 0.7,
    );

    final Paint greenPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF4CAF50)
      ..strokeCap = StrokeCap.round;

    final Paint redPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFFF25454)
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(greenPath, greenPaint);
    canvas.drawPath(redPath, redPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}