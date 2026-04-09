import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'AnalysisResultPage.dart';
import 'HealthTabMenu.dart';

class DetailBrainPage extends StatelessWidget {
  const DetailBrainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      bottomNavigationBar: const HealthTabMenu(currentIndex: 2),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              children: [
                _BrainHeader(
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(height: 12),
                const _SessionSummaryCard(),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2AA1B5),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('← Quay lại phiên thiền'),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Expanded(
                      child: _BrainWaveCard(
                        title: 'Alpha',
                        value: '01',
                        unit: 'Hz',
                        status: 'Tốt',
                        color: Color(0xFF48C768),
                        icon: Icons.bolt,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _BrainWaveCard(
                        title: 'Theta',
                        value: '03',
                        unit: 'Hz',
                        status: 'Tốt',
                        color: Color(0xFFF7B62D),
                        icon: Icons.self_improvement,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Expanded(
                      child: _BrainWaveCard(
                        title: 'Delta',
                        value: '02',
                        unit: 'Hz',
                        status: 'Trung bình',
                        color: Color(0xFFF06266),
                        icon: Icons.psychology_alt_outlined,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _BrainWaveCard(
                        title: 'Beta',
                        value: '0.9',
                        unit: 'Hz',
                        status: 'Bình thường',
                        color: Color(0xFF47C6E8),
                        icon: Icons.waves,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const _BrainWaveCard(
                  title: 'Gamma',
                  value: '05',
                  unit: 'Hz',
                  status: 'Bình thường',
                  color: Color(0xFFD15AE7),
                  icon: Icons.auto_awesome,
                  fullWidth: true,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AnalysisResultPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E9BB1),
                      foregroundColor: AppColors.white,
                      minimumSize: const Size.fromHeight(44),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Kết thúc & Phân tích',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrainHeader extends StatelessWidget {
  const _BrainHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE4E4E4),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 12,
              splashRadius: 13,
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
                'Chi tiết sóng não',
                style: TextStyle(
                  fontSize: 16,
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

class _SessionSummaryCard extends StatelessWidget {
  const _SessionSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDFDFDF)),
      ),
      child: const Column(
        children: [
          _SummaryRow(
            icon: Icons.schedule,
            label: 'Thời gian thiền:',
            value: '10:00 phút',
            valueColor: Color(0xFF3CAA58),
          ),
          SizedBox(height: 6),
          _SummaryRow(
            icon: Icons.monitor_heart_outlined,
            label: 'Trạng thái:',
            value: 'Thư giãn',
            valueColor: Color(0xFF3CAA58),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.neutral700),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral800,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _BrainWaveCard extends StatelessWidget {
  const _BrainWaveCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
    required this.color,
    required this.icon,
    this.fullWidth = false,
  });

  final String title;
  final String value;
  final String unit;
  final String status;
  final Color color;
  final IconData icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final double cardHeight = fullWidth ? 146 : 138;
    final double waveHeight = fullWidth ? 26 : 30;

    return Container(
      height: cardHeight,
      padding: const EdgeInsets.fromLTRB(9, 9, 9, 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE1E1E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(icon, size: 13, color: color),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 37,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          Text(
            status,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.85),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: waveHeight,
            width: double.infinity,
            child: CustomPaint(
              painter: _WavePainter(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(0, size.height * 0.75);

    path.cubicTo(
      size.width * 0.18,
      size.height * 0.35,
      size.width * 0.3,
      size.height,
      size.width * 0.48,
      size.height * 0.62,
    );
    path.cubicTo(
      size.width * 0.62,
      size.height * 0.28,
      size.width * 0.78,
      size.height * 0.92,
      size.width,
      size.height * 0.58,
    );

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color.withValues(alpha: 0.95)
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, stroke);

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.28),
            color.withValues(alpha: 0.02),
          ],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}