import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'HealthTabMenu.dart';
import 'MeditationSessionSummaryPage.dart';

class AnalysisResultPage extends StatelessWidget {
  const AnalysisResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      bottomNavigationBar: const HealthTabMenu(currentIndex: 2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
          child: Column(
            children: [
              _ResultHeader(onBack: () => Navigator.of(context).maybePop()),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle('Phân phối trạng thái sóng não'),
                      const SizedBox(height: 8),
                      const _DistributionCard(),
                      const SizedBox(height: 16),
                      _SectionTitle('Điểm hiệu suất Băng Tần'),
                      const SizedBox(height: 8),
                      const _BandScoresGrid(),
                      const SizedBox(height: 13),
                      const _RecommendationCard(),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const MeditationSessionSummaryPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D98AF),
                            foregroundColor: AppColors.white,
                            minimumSize: const Size.fromHeight(55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Xem tóm tắt',
                            style: TextStyle(
                              fontSize: 19,
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

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Phân tích kết quả',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral800,
                ),
              ),
            ),
          ),
          const _CircleIconButton(icon: Icons.arrow_forward_ios_rounded),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFFE4E4E4),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 14,
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.neutral700),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.neutral800,
      ),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE1E1E1)),
      ),
      child: Column(
        children: [
          const _DonutChart(),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 6,
            children: const [
              _LegendDot(label: 'Alpha - Thư giãn', color: Color(0xFF1CA33B)),
              _LegendDot(label: 'Theta - Tiền thiền', color: Color(0xFFF3A300)),
              _LegendDot(label: 'Delta - Ngủ sâu', color: Color(0xFFF54A4A)),
              _LegendDot(label: 'Beta - Tập trung', color: Color(0xFF1AA1D2)),
              _LegendDot(label: 'Gamma - Nhận thức cao', color: Color(0xFFAF2CC6)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  const _DonutChart();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 166,
      height: 166,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _DonutPainter(
              values: const [28, 24, 16, 22, 10],
              colors: const [
                Color(0xFF1CA33B),
                Color(0xFFF3A300),
                Color(0xFFF54A4A),
                Color(0xFF1AA1D2),
                Color(0xFFAF2CC6),
              ],
            ),
          ),
          const Center(
            child: Text(
              '100%',
              style: TextStyle(
                fontSize: 31,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1296AC),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.7,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _BandScoresGrid extends StatelessWidget {
  const _BandScoresGrid();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Column(
        children: [
        Row(
          children: [
            Expanded(
              child: _ScoreCard(
                value: '9.2',
                label: 'Alpha (Thư giãn)',
                color: Color(0xFF34A853),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: _ScoreCard(
                value: '8.5',
                label: 'Theta (Thiền sâu)',
                color: Color(0xFFF39C12),
              ),
            ),
          ],
        ),
        SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _ScoreCard(
                value: '2.5',
                label: 'Delta (Ngủ sâu)',
                color: Color(0xFFF54A4A),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: _ScoreCard(
                value: '3.1',
                label: 'Beta (Tập trung)',
                color: Color(0xFF1AA1D2),
              ),
            ),
          ],
        ),
        SizedBox(height: 14),
        _ScoreCard(
          value: '7.0',
          label: 'Gamma (Nhận thức cao)',
          color: Color(0xFFAF2CC6),
          isFullWidth: true,
        ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.value,
    required this.label,
    required this.color,
    this.isFullWidth = false,
  });

  final String value;
  final String label;
  final Color color;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.75), width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 49,
              height: 1,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.6,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kết luận chuyên sâu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFF4DB5C8), width: 1),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InsightBullet(
                text:
                    'Điểm Alpha (9.2) và Theta (8.5) cực kỳ cao, cho thấy bạn đã duy trì trạng thái thư giãn và thiền sâu lý tưởng.',
              ),
              SizedBox(height: 6),
              _InsightBullet(
                text:
                    'Điểm Beta (3.1) thấp chứng tỏ không có căng thẳng đáng kể.',
              ),
              SizedBox(height: 6),
              _InsightBullet(
                text:
                    'Điểm Delta (2.5) thấp là mong muốn để giữ một phiên thiền tỉnh táo.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsightBullet extends StatelessWidget {
  const _InsightBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(
            Icons.circle,
            size: 5,
            color: Color(0xFF2E3A44),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
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

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.values, required this.colors});

  final List<double> values;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 23
      ..strokeCap = StrokeCap.butt;

    const double startOffset = -90;
    final double total = values.fold<double>(0, (sum, v) => sum + v);
    double startRadian = startOffset * 3.141592653589793 / 180;

    for (int i = 0; i < values.length; i++) {
      final double sweep = (values[i] / total) * 2 * 3.141592653589793;
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect.deflate(11), startRadian, sweep, false, paint);
      startRadian += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
}