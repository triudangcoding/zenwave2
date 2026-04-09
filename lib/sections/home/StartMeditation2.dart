import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../health_management/HealthTabMenu.dart';

class StartMeditationPage extends StatefulWidget {
  const StartMeditationPage({super.key});

  @override
  State<StartMeditationPage> createState() => _StartMeditationPageState();
}

class _StartMeditationPageState extends State<StartMeditationPage> {
  static const int _totalSeconds = 10 * 60;

  int _elapsedSeconds = 0;
  bool _isPaused = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isPaused || _elapsedSeconds >= _totalSeconds) {
        return;
      }

      setState(() {
        _elapsedSeconds += 1;
      });
    });
  }

  String get _formattedTime {
    final int minutes = _elapsedSeconds ~/ 60;
    final int seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress => (_elapsedSeconds / _totalSeconds).clamp(0.0, 1.0);

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _finishSession() {
    _ticker?.cancel();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      bottomNavigationBar: const HealthTabMenu(currentIndex: 2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: AppColors.neutral700,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Phiên thiền',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: 250,
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size.square(250),
                      painter: _MeditationRingPainter(progress: _progress),
                    ),
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD0F4D5),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Text(
                      'Trạng thái: Thư giãn sâu',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D971F),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Đạt 80% thời gian tĩnh tâm',
                      style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Mục tiêu : Duy trì Alpha/Theta',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF858B95),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(flex: 2),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _finishSession,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3030),
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Kết thúc',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _togglePause,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.cyan500),
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isPaused ? 'Tiếp tục' : 'Tạm dừng',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cyan600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeditationRingPainter extends CustomPainter {
  const _MeditationRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 14;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - strokeWidth) / 2;

    final Paint backgroundRing = Paint()
      ..color = const Color(0xFFCBEAF0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint progressRing = Paint()
      ..color = AppColors.cyan600
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundRing);

    const double startAngle = math.pi * -0.5;
    final double sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressRing,
    );
  }

  @override
  bool shouldRepaint(covariant _MeditationRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
