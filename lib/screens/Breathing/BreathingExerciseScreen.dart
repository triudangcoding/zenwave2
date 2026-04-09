import 'dart:async';
import 'dart:math' show pi, sin;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../../models/breathing_exercise.dart';

enum BreathingPhase { inhale, hold, exhale, wait }

class BreathingCirclePainter extends CustomPainter {
  final double animationValue;
  final BreathingPhase currentPhase;

  BreathingCirclePainter({
    required this.animationValue,
    required this.currentPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final fullCircleRect = Rect.fromCircle(
      center: center,
      radius: radius * 0.9,
    );

    const inhaleColor = Color(0xFF24B0B0);
    const holdColor = Color(0xFF3D5A80);
    const exhaleColor = Color(0xFF24B0B0);

    final backgroundPaint = Paint()
      ..color = const Color(0xFF3D5A80).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30.0;
    canvas.drawCircle(center, radius * 0.9, backgroundPaint);

    late Paint progressPaint;
    late double sweepAngle;

    switch (currentPhase) {
      case BreathingPhase.inhale:
        progressPaint = Paint()
          ..color = inhaleColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 30.0
          ..strokeCap = StrokeCap.round;

        sweepAngle = 2 * pi * animationValue;
        canvas.drawArc(
          fullCircleRect,
          -pi / 2,
          sweepAngle,
          false,
          progressPaint,
        );
        break;

      case BreathingPhase.hold:
        progressPaint = Paint()
          ..color = holdColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 30.0;

        final opacity = 0.8 + 0.2 * sin(animationValue * 2 * pi);
        progressPaint.color = holdColor.withValues(alpha: opacity);
        canvas.drawCircle(center, radius * 0.9, progressPaint);
        break;

      case BreathingPhase.exhale:
        progressPaint = Paint()
          ..color = exhaleColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 30.0
          ..strokeCap = StrokeCap.round;

        sweepAngle = 2 * pi * (1 - animationValue);
        canvas.drawArc(
          fullCircleRect,
          -pi / 2,
          sweepAngle,
          false,
          progressPaint,
        );
        break;

      case BreathingPhase.wait:
        progressPaint = Paint()
          ..color = holdColor.withValues(
            alpha: 0.3 + 0.2 * sin(animationValue * 3 * pi),
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20.0;

        canvas.drawCircle(center, radius * 0.85, progressPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(BreathingCirclePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.currentPhase != currentPhase;
  }
}

class BreathingExerciseScreen extends StatefulWidget {
  final BreathingExercise exercise;

  const BreathingExerciseScreen({super.key, required this.exercise});

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  BreathingPhase _currentPhase = BreathingPhase.inhale;
  int _currentStep = 1;
  final int _totalSteps = 7;
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _secondsRemaining = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.exercise.inhaleTime),
    );

    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _onPhaseCompleted();
            }
          });

    _startBreathingCycle();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Color _getPhaseColor() {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return const Color(0xFF24B0B0);
      case BreathingPhase.hold:
        return const Color(0xFF3D5A80);
      case BreathingPhase.exhale:
        return const Color(0xFF24B0B0);
      case BreathingPhase.wait:
        return const Color(0xFF186289);
    }
  }

  String _getPhaseText() {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return 'Hít vào';
      case BreathingPhase.hold:
        return 'Giữ';
      case BreathingPhase.exhale:
        return 'Thở ra';
      case BreathingPhase.wait:
        return 'Chờ';
    }
  }

  String _getPhaseDescription() {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return 'Hít vào từ từ qua mũi';
      case BreathingPhase.hold:
        return 'Giữ hơi trong lồng ngực';
      case BreathingPhase.exhale:
        return 'Thở ra từ từ qua miệng';
      case BreathingPhase.wait:
        return 'Thư giãn và chuẩn bị cho chu kỳ tiếp theo';
    }
  }

  void _startBreathingCycle() {
    _currentPhase = BreathingPhase.inhale;
    _secondsRemaining = widget.exercise.inhaleTime;
    _startTimer();
    _animationController.duration = Duration(
      seconds: widget.exercise.inhaleTime,
    );
    _animationController.forward(from: 0.0);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  void _advanceToNextStepOrComplete() {
    if (!mounted) {
      return;
    }

    if (_currentStep < _totalSteps) {
      setState(() {
        _currentStep++;
      });
      _startBreathingCycle();
      return;
    }

    _showCompletionDialog();
  }

  Future<void> _playTransitionCue() async {
    try {
      await _audioPlayer.play(AssetSource('sound/beep.mp3'));
    } catch (_) {
      // Ignore cue playback failures so breathing flow can continue.
    }

    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        await Vibration.vibrate(duration: 200);
      }
    } catch (_) {
      // Ignore vibration failures on unsupported devices/emulators.
    }
  }

  Future<void> _onPhaseCompleted() async {
    await _playTransitionCue();

    if (!mounted) {
      return;
    }

    switch (_currentPhase) {
      case BreathingPhase.inhale:
        setState(() {
          _currentPhase = BreathingPhase.hold;
          _secondsRemaining = widget.exercise.holdTime;
        });
        _startTimer();
        _animationController.duration = Duration(
          seconds: widget.exercise.holdTime,
        );
        _animationController.forward(from: 0.0);
        break;
      case BreathingPhase.hold:
        setState(() {
          _currentPhase = BreathingPhase.exhale;
          _secondsRemaining = widget.exercise.exhaleTime;
        });
        _startTimer();
        _animationController.duration = Duration(
          seconds: widget.exercise.exhaleTime,
        );
        _animationController.forward(from: 0.0);
        break;
      case BreathingPhase.exhale:
        if (widget.exercise.waitTime > 0) {
          setState(() {
            _currentPhase = BreathingPhase.wait;
            _secondsRemaining = widget.exercise.waitTime;
          });
          _startTimer();
          _animationController.duration = Duration(
            seconds: widget.exercise.waitTime,
          );
          _animationController.forward(from: 0.0);
        } else {
          _advanceToNextStepOrComplete();
        }
        break;
      case BreathingPhase.wait:
        _advanceToNextStepOrComplete();
        break;
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Hoàn thành'),
        content: const Text(
          'Bạn đã hoàn thành bài tập thở. Cảm ơn bạn đã tham gia!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        backgroundColor: widget.exercise.primaryColor,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: _currentStep / _totalSteps,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.exercise.primaryColor,
            ),
            minHeight: 8,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bước $_currentStep/$_totalSteps',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: CustomPaint(
                          painter: BreathingCirclePainter(
                            animationValue: _animation.value,
                            currentPhase: _currentPhase,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getPhaseText(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: widget.exercise.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_secondsRemaining',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: _getPhaseColor(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    _getPhaseDescription(),
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
