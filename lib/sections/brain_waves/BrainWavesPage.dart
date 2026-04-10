import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/breathing_exercise.dart';
import '../../screens/Breathing/BreathingDetailScreen.dart';
import '../../sections/meditation/DetailLessonMeditation.dart';
import '../../services/app_state_service.dart';
import '../../services/ble_service.dart';

class BrainWavesPage extends StatefulWidget {
  const BrainWavesPage({super.key});

  @override
  State<BrainWavesPage> createState() => _BrainWavesPageState();
}

class _BrainWavesPageState extends State<BrainWavesPage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppStateService.deviceConnectedNotifier,
      builder: (_, connected, __) {
        if (connected) {
          return const _BrainMeasurementView();
        }
        return const _BleConnectView();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// View 1: BLE connection flow
// ─────────────────────────────────────────────────────────────────────────────

class _BleConnectView extends StatefulWidget {
  const _BleConnectView();

  @override
  State<_BleConnectView> createState() => _BleConnectViewState();
}

class _BleConnectViewState extends State<_BleConnectView> {
  final BleService _ble = BleService.instance;
  bool _isConnecting = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Header
              const Text(
                'Sóng não',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kết nối thiết bị ESP32 BLE\nđể bắt đầu đo sóng não',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.neutral600,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 2),
              // Circle icon
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFA7F0F1), width: 5),
                ),
                child: Center(
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF00B3BF),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.bluetooth_searching,
                        color: Colors.white,
                        size: 52,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Status text
              Text(
                _isConnecting ? 'Đang tìm thiết bị...' : 'CHƯA KẾT NỐI',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: _isConnecting
                      ? AppColors.orange600
                      : const Color(0xFF4F9A67),
                ),
              ),
              const SizedBox(height: 8),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.red600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const Text(
                'Hãy bật Bluetooth và đảm bảo thiết bị\nESP32 đang hoạt động gần bạn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.neutral600,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 2),
              // Scan results
              ValueListenableBuilder<List<BleDeviceInfo>>(
                valueListenable: _ble.scanResultsNotifier,
                builder: (_, devices, __) {
                  if (devices.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thiết bị tìm thấy:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...devices.map(
                        (d) => _DeviceTile(
                          device: d,
                          onTap: () => _connectDevice(d),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
              // Scan button
              SizedBox(
                width: double.infinity,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _ble.isScanningNotifier,
                  builder: (_, scanning, __) {
                    return ElevatedButton.icon(
                      onPressed: scanning || _isConnecting ? null : _startScan,
                      icon: scanning
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.bluetooth_searching),
                      label: Text(
                        scanning ? 'Đang quét...' : 'Quét thiết bị BLE',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF129EAF),
                        foregroundColor: AppColors.white,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startScan() async {
    setState(() {
      _error = null;
    });
    try {
      await _ble.startScan();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Không thể quét: $e';
        });
      }
    }
  }

  Future<void> _connectDevice(BleDeviceInfo device) async {
    setState(() {
      _isConnecting = true;
      _error = null;
    });
    try {
      await _ble.connect(device);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Kết nối thất bại: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.device, required this.onTap});

  final BleDeviceInfo device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.bluetooth, color: Color(0xFF129EAF), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    device.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral800,
                    ),
                  ),
                ),
                if (device.rssi != null)
                  Text(
                    '${device.rssi} dBm',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutral500,
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.neutral400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// View 2: Connected – brain wave measurement (mock)
// ─────────────────────────────────────────────────────────────────────────────

enum _MeasurePhase { idle, preparing, measuring, result }

class _BrainMeasurementView extends StatefulWidget {
  const _BrainMeasurementView();

  @override
  State<_BrainMeasurementView> createState() => _BrainMeasurementViewState();
}

class _BrainMeasurementViewState extends State<_BrainMeasurementView> {
  _MeasurePhase _phase = _MeasurePhase.idle;
  Timer? _phaseTimer;
  Timer? _chartTimer;
  Timer? _signalResumeTimer;

  // Prepare countdown
  int _prepCountdown = 5;

  // Measuring progress
  int _elapsedSeconds = 0;
  static const int _measureDurationSec = 35;

  // Live chart data (all points stored for scrollable chart)
  final List<double> _alphaPoints = [];
  final List<double> _betaPoints = [];
  final List<double> _deltaPoints = [];

  // ── Per-session random profile (makes each run unique) ──
  late double _alphaBase;
  late double _alphaRange;
  late double _betaBase;
  late double _betaRange;
  late double _deltaBase;
  late double _deltaRange;
  late double _phaseShift;
  late double _sineFreqAlpha;
  late double _sineFreqBeta;
  late double _sineFreqDelta;

  // ── Weak-signal pause state ──
  bool _signalWeak = false;
  int _ticksSinceLastPause = 0;
  late int _nextPauseTick; // random tick count until next pause

  // Final mock results
  double _alphaAvg = 0;
  double _betaAvg = 0;
  double _deltaAvg = 0;
  double _overallScore = 0;
  double _eegScore = 0;
  double _questionnaireScore = 0;
  String _evaluation = '';
  String _evaluationDetail = '';
  Color _evalColor = const Color(0xFF4F9A67);

  // Questionnaire-based insights for report
  String _sleepInsight = '';
  String _focusInsight = '';
  String _tensionInsight = '';
  String _copingInsight = '';

  // Wave definitions
  static const Color alphaColor = Color(0xFF149A33);
  static const Color betaColor = Color(0xFF009CC4);
  static const Color deltaColor = Color(0xFFE8575A);

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _chartTimer?.cancel();
    _signalResumeTimer?.cancel();
    super.dispose();
  }

  void _startFlow() {
    setState(() {
      _phase = _MeasurePhase.preparing;
      _prepCountdown = 5;
    });
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _prepCountdown--;
      });
      if (_prepCountdown <= 0) {
        timer.cancel();
        _beginMeasuring();
      }
    });
  }

  void _beginMeasuring() {
    _alphaPoints.clear();
    _betaPoints.clear();
    _deltaPoints.clear();
    _elapsedSeconds = 0;

    final rng = Random();

    // ── Questionnaire-based bias ──
    // answers: 0 = most stressed, 4 = most relaxed
    // avg 0→stressed profile (high beta, low alpha), avg 4→relaxed (high alpha, low beta)
    final answers = AppStateService.quickPsychAnswers;
    final double qAvg = answers.isEmpty
        ? 2.0
        : answers.fold<int>(0, (a, b) => a + b) / answers.length;
    // qBias: -1.0 (very stressed) to +1.0 (very relaxed)
    final double qBias = (qAvg - 2.0) / 2.0;

    // ── Per-session random profile (biased by questionnaire) ──
    // Relaxed person → alpha higher, beta lower; Stressed → opposite
    _alphaBase = 36.0 + rng.nextDouble() * 16.0 + qBias * 8.0; // ±8 shift
    _alphaRange = 22.0 + rng.nextDouble() * 18.0;
    _betaBase = 16.0 + rng.nextDouble() * 14.0 - qBias * 7.0; // inverse shift
    _betaRange = 18.0 + rng.nextDouble() * 18.0;
    _deltaBase = 4.0 + rng.nextDouble() * 8.0 + qBias * 2.0;
    _deltaRange = 12.0 + rng.nextDouble() * 14.0;
    _phaseShift = rng.nextDouble() * 6.28; // 0-2π
    _sineFreqAlpha = 0.15 + rng.nextDouble() * 0.35; // 0.15-0.5
    _sineFreqBeta = 0.25 + rng.nextDouble() * 0.45; // 0.25-0.7
    _sineFreqDelta = 0.1 + rng.nextDouble() * 0.25; // 0.1-0.35

    // ── Weak-signal pause scheduling ──
    _signalWeak = false;
    _ticksSinceLastPause = 0;
    _nextPauseTick = 14 + rng.nextInt(16); // first pause after 7-15s

    setState(() {
      _phase = _MeasurePhase.measuring;
    });

    // Generate live data every 500ms → 2 points/sec, 35s = ~70 ticks
    _chartTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // ── Weak-signal pause check ──
      if (_signalWeak) return; // paused, skip data generation

      _ticksSinceLastPause++;
      if (_ticksSinceLastPause >= _nextPauseTick &&
          _elapsedSeconds < _measureDurationSec - 4) {
        // Trigger weak signal pause
        _ticksSinceLastPause = 0;
        _nextPauseTick = 20 + rng.nextInt(20); // next pause after 10-20s
        setState(() {
          _signalWeak = true;
        });
        // Resume after 1.5s
        _signalResumeTimer?.cancel();
        _signalResumeTimer = Timer(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _signalWeak = false;
            });
          }
        });
        return;
      }

      // ── Generate data with session-unique profile ──
      final t = _alphaPoints.length.toDouble();
      final alpha =
          _alphaBase +
          rng.nextDouble() * _alphaRange +
          sin(t * _sineFreqAlpha + _phaseShift) * (6 + rng.nextDouble() * 6);
      final beta =
          _betaBase +
          rng.nextDouble() * _betaRange +
          sin(t * _sineFreqBeta + _phaseShift * 1.3) *
              (4 + rng.nextDouble() * 5);
      final delta =
          _deltaBase +
          rng.nextDouble() * _deltaRange +
          sin(t * _sineFreqDelta + _phaseShift * 0.7) *
              (3 + rng.nextDouble() * 4);

      setState(() {
        _alphaPoints.add(alpha.clamp(0, 100));
        _betaPoints.add(beta.clamp(0, 100));
        _deltaPoints.add(delta.clamp(0, 100));
      });

      // Increment seconds every 2 ticks (500ms * 2)
      if (timer.tick % 2 == 0) {
        _elapsedSeconds++;
        if (mounted) setState(() {});
      }

      if (_elapsedSeconds >= _measureDurationSec) {
        timer.cancel();
        _finishMeasurement();
      }
    });
  }

  void _finishMeasurement() {
    // Compute averages from accumulated points
    _alphaAvg = _alphaPoints.isEmpty
        ? 0
        : _alphaPoints.reduce((a, b) => a + b) / _alphaPoints.length;
    _betaAvg = _betaPoints.isEmpty
        ? 0
        : _betaPoints.reduce((a, b) => a + b) / _betaPoints.length;
    _deltaAvg = _deltaPoints.isEmpty
        ? 0
        : _deltaPoints.reduce((a, b) => a + b) / _deltaPoints.length;

    // ── EEG score: high alpha + low beta = relaxed → higher score ──
    final alphaRatio = ((_alphaAvg - 25) / 55).clamp(0.0, 1.0);
    final betaRatio = (1 - ((_betaAvg - 10) / 50)).clamp(0.0, 1.0);
    final rawEeg = (alphaRatio * 0.55 + betaRatio * 0.35 + 0.1) * 10;
    _eegScore = rawEeg.clamp(1.0, 10.0);

    // ── Questionnaire score (0-based answers, 0=stressed, 4=relaxed) ──
    final answers = AppStateService.quickPsychAnswers;
    if (answers.isNotEmpty) {
      final double avg = answers.fold<int>(0, (a, b) => a + b) / answers.length;
      // avg 0→1.0, avg 4→10.0
      _questionnaireScore = (1.0 + (avg / 4.0) * 9.0).clamp(1.0, 10.0);
    } else {
      _questionnaireScore = 5.5; // neutral fallback
    }

    // ── Blend: 60% EEG + 40% questionnaire ──
    final rng = Random();
    final blended = _eegScore * 0.6 + _questionnaireScore * 0.4;
    // Small noise so repeated sessions differ
    _overallScore = (blended + (rng.nextDouble() - 0.5) * 0.8).clamp(1.5, 9.5);
    _overallScore = double.parse(_overallScore.toStringAsFixed(1));

    // ── Questionnaire-based insights (per-dimension) ──
    _deriveInsights(answers);

    // ── Evaluation text ──
    if (_overallScore >= 7.5) {
      _evaluation = 'Trạng thái thư giãn';
      _evaluationDetail =
          'Sóng Alpha chiếm ưu thế rõ rệt, cho thấy bạn đang ở trạng thái '
          'thư giãn, tập trung nhẹ nhàng. Kết quả khảo sát ban đầu cũng '
          'cho thấy bạn có nền tảng tinh thần ổn định.';
      _evalColor = const Color(0xFF149A33);
    } else if (_overallScore >= 6.0) {
      _evaluation = 'Căng thẳng nhẹ';
      _evaluationDetail =
          'Sóng Beta tăng nhẹ so với mức nền, kết hợp với câu trả lời khảo sát '
          'cho thấy bạn đang có căng thẳng nhẹ. '
          'Khuyến nghị thực hiện bài tập thở hoặc thiền ngắn để cân bằng.';
      _evalColor = const Color(0xFFF8AC14);
    } else if (_overallScore >= 4.0) {
      _evaluation = 'Căng thẳng trung bình';
      _evaluationDetail =
          'Chỉ số Beta cao liên tục, Alpha bị ức chế. Dữ liệu khảo sát cho '
          'thấy bạn có một số yếu tố gia tăng căng thẳng. Bạn nên dành thời '
          'gian nghỉ ngơi, thực hành thiền định hoặc bài tập hít thở sâu.';
      _evalColor = const Color(0xFFE8575A);
    } else {
      _evaluation = 'Căng thẳng cao';
      _evaluationDetail =
          'Cả sóng não và câu trả lời khảo sát đều cho thấy mức căng thẳng '
          'đáng chú ý. Đề nghị bạn dành ít nhất 15 phút mỗi ngày cho bài tập '
          'thiền hoặc hít thở sâu, đồng thời cân nhắc tham khảo chuyên gia.';
      _evalColor = const Color(0xFFD32F2F);
    }

    setState(() {
      _phase = _MeasurePhase.result;
    });
  }

  /// Derive per-dimension insights from 10 onboarding answers.
  /// Questions: 0-mood, 1-sleep, 2-coping, 3-fatigue, 4-focus,
  ///            5-anxiety, 6-personal time, 7-tension, 8-emotion control, 9-meditation exp
  void _deriveInsights(List<int> answers) {
    // Sleep insight (question 1)
    if (answers.length > 1) {
      final s = answers[1];
      if (s <= 1) {
        _sleepInsight =
            'Chất lượng giấc ngủ kém — ảnh hưởng trực tiếp đến '
            'sóng Delta và khả năng phục hồi của não bộ.';
      } else if (s == 2) {
        _sleepInsight =
            'Giấc ngủ ở mức trung bình — cải thiện chất lượng giấc ngủ '
            'sẽ giúp tăng sóng Alpha khi tỉnh táo.';
      } else {
        _sleepInsight =
            'Giấc ngủ tốt — đây là yếu tố tích cực giúp duy trì '
            'sóng Alpha ổn định.';
      }
    }

    // Focus insight (question 4)
    if (answers.length > 4) {
      final f = answers[4];
      if (f <= 1) {
        _focusInsight =
            'Khó tập trung — sóng Beta cao có thể liên quan đến '
            'mức phân tâm bạn báo cáo.';
      } else if (f == 2) {
        _focusInsight =
            'Tập trung ở mức bình thường — phù hợp với biên độ '
            'sóng não đo được.';
      } else {
        _focusInsight =
            'Tập trung tốt — sóng Alpha mạnh hỗ trợ trạng thái '
            'tập trung hiệu quả.';
      }
    }

    // Body tension insight (question 7)
    if (answers.length > 7) {
      final t = answers[7];
      if (t <= 1) {
        _tensionInsight =
            'Căng cứng cơ thể thường xuyên — stress thể chất '
            'đang phản ánh qua hoạt động Beta cao.';
      } else if (t == 2) {
        _tensionInsight =
            'Căng cứng nhẹ — bài tập thư giãn cơ sẽ '
            'hỗ trợ giảm sóng Beta.';
      } else {
        _tensionInsight =
            'Cơ thể khá thư giãn — đây là dấu hiệu tốt '
            'tương thích với mức Alpha đo được.';
      }
    }

    // Coping method insight (question 2)
    if (answers.length > 2) {
      final c = answers[2];
      if (c == 0) {
        _copingInsight =
            'Chưa có phương pháp giải toả — việc bắt đầu thiền '
            'định hoặc bài tập hít thở có thể giúp cải thiện đáng kể.';
      } else if (c <= 2) {
        _copingInsight =
            'Có phương pháp giải toả cơ bản — kết hợp thêm '
            'thiền định sẽ tăng hiệu quả thư giãn.';
      } else {
        _copingInsight =
            'Phương pháp giải toả tốt — thực hành thiền định '
            'giúp duy trì sóng Alpha ổn định như đo được.';
      }
    }
  }

  void _reset() {
    _phaseTimer?.cancel();
    _chartTimer?.cancel();
    _signalResumeTimer?.cancel();
    setState(() {
      _phase = _MeasurePhase.idle;
      _alphaPoints.clear();
      _betaPoints.clear();
      _deltaPoints.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String deviceName =
        AppStateService.connectedDeviceName ?? 'ESP32S3_TOUCH';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // ── Header ──
              const Center(
                child: Text(
                  'Sóng não',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutral900,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // ── Device card ──
              _buildDeviceCard(deviceName),
              const SizedBox(height: 20),
              // ── Phase content ──
              if (_phase == _MeasurePhase.idle) _buildIdle(),
              if (_phase == _MeasurePhase.preparing) _buildPreparing(),
              if (_phase == _MeasurePhase.measuring) _buildMeasuring(),
              if (_phase == _MeasurePhase.result) _buildResult(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Device card ──────────────────────────────────────────────────────────

  Widget _buildDeviceCard(String deviceName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE0F7F7),
            ),
            child: const Icon(
              Icons.bluetooth_connected,
              color: Color(0xFF129EAF),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviceName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral800,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4F9A67),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Đã kết nối',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4F9A67),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _phase == _MeasurePhase.measuring
                ? null
                : () async {
                    _reset();
                    await BleService.instance.disconnect();
                  },
            child: Text(
              'Ngắt kết nối',
              style: TextStyle(
                fontSize: 12,
                color: _phase == _MeasurePhase.measuring
                    ? AppColors.neutral400
                    : AppColors.red600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Phase: Idle ──────────────────────────────────────────────────────────

  Widget _buildIdle() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE0F7F7), Color(0xFFB2EBF2)],
              ),
              border: Border.all(color: const Color(0xFF80DEEA), width: 3),
            ),
            child: const Icon(
              Icons.waves_rounded,
              size: 60,
              color: Color(0xFF129EAF),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Sẵn sàng đo sóng não',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral800,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Thiết bị đã được kết nối thành công.\nBấm nút bên dưới để bắt đầu quá trình đo.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.neutral600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),
        _buildPrimaryButton(
          label: 'Đo sóng não',
          icon: Icons.waves,
          onPressed: _startFlow,
        ),
      ],
    );
  }

  // ── Phase: Preparing ─────────────────────────────────────────────────────

  Widget _buildPreparing() {
    return Column(
      children: [
        const SizedBox(height: 24),
        // Illustration
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFF8E1),
              border: Border.all(color: const Color(0xFFFFE082), width: 3),
            ),
            child: const Icon(
              Icons.headset_rounded,
              size: 52,
              color: Color(0xFFF8AC14),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Chuẩn bị đo',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral800,
          ),
        ),
        const SizedBox(height: 16),
        // Instructions card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PrepStep(
                index: 1,
                text: 'Đeo băng đô lên trán, đảm bảo các điện cực tiếp xúc da.',
              ),
              SizedBox(height: 10),
              _PrepStep(
                index: 2,
                text: 'Ngồi thoải mái, giữ yên cơ thể và thả lỏng cơ mặt.',
              ),
              SizedBox(height: 10),
              _PrepStep(
                index: 3,
                text:
                    'Nhắm mắt nhẹ nhàng, hít thở đều khi quá trình đo bắt đầu.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        // Countdown
        Text(
          'Bắt đầu sau $_prepCountdown giây...',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF8AC14),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 1 - (_prepCountdown / 5),
              minHeight: 6,
              backgroundColor: const Color(0xFFE8E8E8),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFF8AC14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Phase: Measuring ─────────────────────────────────────────────────────

  Widget _buildMeasuring() {
    final progress = _elapsedSeconds / _measureDurationSec;
    final remaining = _measureDurationSec - _elapsedSeconds;

    return Column(
      children: [
        const SizedBox(height: 8),
        // Timer + progress
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Đang đo sóng não',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral800,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${remaining}s còn lại',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF129EAF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: const Color(0xFFE0E0E0),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF129EAF)),
          ),
        ),
        const SizedBox(height: 16),
        // Live chart (scrollable)
        _InteractiveWaveChart(
          alpha: _alphaPoints,
          beta: _betaPoints,
          delta: _deltaPoints,
          height: 220,
          pointsPerScreen: 40,
          autoScrollToEnd: true,
        ),
        const SizedBox(height: 12),
        // Weak signal warning
        if (_signalWeak)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFCC80)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.signal_cellular_connected_no_internet_0_bar,
                  size: 18,
                  color: Color(0xFFEF6C00),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tín hiệu yếu — vui lòng ngồi yên...',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE65100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        // Legend
        _buildLegend(),
        const SizedBox(height: 20),
        Text(
          _signalWeak
              ? 'Đang khôi phục kết nối...'
              : 'Vui lòng giữ yên và nhắm mắt...',
          style: TextStyle(fontSize: 14, color: AppColors.neutral600),
        ),
      ],
    );
  }

  // ── Phase: Result ────────────────────────────────────────────────────────

  Widget _buildResult() {
    return Column(
      children: [
        const SizedBox(height: 4),
        // Score badge
        Center(
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _evalColor.withValues(alpha: 0.1),
              border: Border.all(
                color: _evalColor.withValues(alpha: 0.4),
                width: 4,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _overallScore.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: _evalColor,
                  ),
                ),
                Text(
                  '/ 10',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _evalColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _evaluation,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _evalColor,
          ),
        ),
        const SizedBox(height: 14),
        _buildPrimaryButton(
          label: 'Đo lại',
          icon: Icons.refresh,
          onPressed: _reset,
        ),
        const SizedBox(height: 16),
        // Chart snapshot (scrollable)
        _InteractiveWaveChart(
          alpha: _alphaPoints,
          beta: _betaPoints,
          delta: _deltaPoints,
          height: 200,
          pointsPerScreen: 40,
          autoScrollToEnd: false,
        ),
        const SizedBox(height: 10),
        _buildLegend(),
        const SizedBox(height: 16),
        // ── Stress scale ──
        _buildStressScale(),
        const SizedBox(height: 16),
        // Wave averages
        _buildWaveAvgCard('Alpha', '8 – 13 Hz', _alphaAvg, alphaColor),
        const SizedBox(height: 8),
        _buildWaveAvgCard('Beta', '13 – 30 Hz', _betaAvg, betaColor),
        const SizedBox(height: 8),
        _buildWaveAvgCard('Delta', '0.5 – 4 Hz', _deltaAvg, deltaColor),
        const SizedBox(height: 16),
        // Evaluation report
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.assessment_outlined, color: _evalColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Báo cáo phân tích',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _evaluationDetail,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.neutral700,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              // Quick stats row
              Row(
                children: [
                  _buildMiniStat('Thời gian đo', '${_measureDurationSec}s'),
                  const SizedBox(width: 12),
                  _buildMiniStat('Mẫu thu thập', '${_alphaPoints.length}'),
                  const SizedBox(width: 12),
                  _buildMiniStat('Điểm số', _overallScore.toStringAsFixed(1)),
                ],
              ),
              const SizedBox(height: 12),
              // Score breakdown
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cơ sở tính điểm',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _scoreBreakdownRow(
                      'Sóng não (EEG)',
                      _eegScore,
                      '60%',
                      const Color(0xFF129EAF),
                    ),
                    const SizedBox(height: 4),
                    _scoreBreakdownRow(
                      'Khảo sát 10 câu hỏi',
                      _questionnaireScore,
                      '40%',
                      const Color(0xFF7C4DFF),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // ── Questionnaire-based insights ──
        if (_sleepInsight.isNotEmpty ||
            _focusInsight.isNotEmpty ||
            _tensionInsight.isNotEmpty ||
            _copingInsight.isNotEmpty)
          _buildInsightsCard(),
        const SizedBox(height: 16),
        // ── Recommended exercises ──
        _buildRecommendedExercises(),
        const SizedBox(height: 16),
        // ── Theory basis button ──
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showTheorySheet,
            icon: const Icon(Icons.menu_book_outlined, size: 18),
            label: const Text('Chi tiết cơ sở lý thuyết đánh giá'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF546E7A),
              side: const BorderSide(color: Color(0xFFCFD8DC)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── Shared widgets ───────────────────────────────────────────────────────

  void _showTheorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (ctx, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D0D0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      color: Color(0xFF37474F),
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Cơ sở lý thuyết đánh giá',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF263238),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  children: const [
                    _TheorySection(
                      icon: Icons.waves,
                      title: 'Sóng não là gì?',
                      color: Color(0xFF129EAF),
                      body:
                          'Sóng não (brainwaves) là các tín hiệu điện sinh học '
                          'được tạo ra bởi hoạt động đồng bộ của hàng tỷ tế bào '
                          'thần kinh trong não. Chúng được đo bằng phương pháp '
                          'điện não đồ (EEG — Electroencephalography) thông qua '
                          'các điện cực đặt trên da đầu.',
                    ),
                    SizedBox(height: 16),
                    _TheorySection(
                      icon: Icons.show_chart,
                      title: 'Sóng Alpha (8–13 Hz)',
                      color: Color(0xFF149A33),
                      body:
                          'Sóng Alpha xuất hiện khi bạn thư giãn, nhắm mắt, '
                          'hoặc trong trạng thái tĩnh tâm nhẹ. Biên độ Alpha cao '
                          'cho thấy não bộ đang ở trạng thái nghỉ ngơi tỉnh táo, '
                          'là nền tảng tốt cho thiền định và sáng tạo.\n\n'
                          '• Biên độ bình thường: 30–80 µV\n'
                          '• Alpha cao → thư giãn, bình tĩnh\n'
                          '• Alpha thấp → có thể căng thẳng hoặc đang tập trung mạnh',
                    ),
                    SizedBox(height: 16),
                    _TheorySection(
                      icon: Icons.trending_up,
                      title: 'Sóng Beta (13–30 Hz)',
                      color: Color(0xFF009CC4),
                      body:
                          'Sóng Beta liên quan đến trạng thái tỉnh táo, tập trung '
                          'và xử lý thông tin. Tuy nhiên, Beta quá cao có thể '
                          'chỉ ra căng thẳng, lo lắng hoặc suy nghĩ quá mức.\n\n'
                          '• Biên độ bình thường: 15–40 µV\n'
                          '• Beta vừa phải → tập trung hiệu quả\n'
                          '• Beta cao liên tục → căng thẳng, lo âu\n'
                          '• Tỷ lệ Beta/Alpha cao → stress indicator',
                    ),
                    SizedBox(height: 16),
                    _TheorySection(
                      icon: Icons.nightlight_round,
                      title: 'Sóng Delta (0.5–4 Hz)',
                      color: Color(0xFFE8575A),
                      body:
                          'Sóng Delta chủ yếu xuất hiện trong giấc ngủ sâu '
                          '(NREM stage 3-4). Khi tỉnh, Delta thấp là bình '
                          'thường. Delta cao khi tỉnh có thể chỉ ra mệt mỏi '
                          'hoặc thiếu ngủ.\n\n'
                          '• Biên độ bình thường khi tỉnh: 5–20 µV\n'
                          '• Delta thấp khi tỉnh → tỉnh táo tốt\n'
                          '• Delta cao khi tỉnh → mệt mỏi, thiếu ngủ',
                    ),
                    SizedBox(height: 16),
                    _TheorySection(
                      icon: Icons.calculate_outlined,
                      title: 'Cách tính điểm (1–10)',
                      color: Color(0xFF7C4DFF),
                      body:
                          'Điểm tổng hợp được tính từ hai nguồn:\n\n'
                          '① Sóng não EEG (trọng số 60%)\n'
                          '   • Tỷ lệ Alpha cao → điểm cao (thư giãn)\n'
                          '   • Tỷ lệ Beta cao → điểm thấp (căng thẳng)\n'
                          '   • Công thức: αRatio × 0.55 + βRatio × 0.35 + 0.1\n\n'
                          '② Khảo sát tâm lý 10 câu (trọng số 40%)\n'
                          '   • 10 câu hỏi đánh giá: giấc ngủ, mức độ căng '
                          'thẳng, khả năng tập trung, phương pháp giải toả, '
                          'mệt mỏi, lo lắng, thời gian cá nhân, căng cứng cơ '
                          'thể, kiểm soát cảm xúc, kinh nghiệm thiền\n'
                          '   • Mỗi câu 5 mức (0-4): 0 = căng thẳng nhất, '
                          '4 = thư giãn nhất\n\n'
                          'Điểm cuối = EEG × 0.6 + Khảo sát × 0.4',
                    ),
                    SizedBox(height: 16),
                    _TheorySection(
                      icon: Icons.assessment_outlined,
                      title: 'Thang đánh giá',
                      color: Color(0xFFF8AC14),
                      body:
                          '• 7.5–10.0  →  Thư giãn: Sóng Alpha chiếm ưu thế, '
                          'tâm trí bình tĩnh, phù hợp thiền định sâu.\n\n'
                          '• 6.0–7.4  →  Căng thẳng nhẹ: Beta tăng nhẹ, vẫn '
                          'trong ngưỡng bình thường. Nên tập thở hoặc thiền '
                          'ngắn.\n\n'
                          '• 4.0–5.9  →  Căng thẳng trung bình: Beta cao liên '
                          'tục, Alpha bị ức chế. Cần nghỉ ngơi và thực hành '
                          'thiền định.\n\n'
                          '• 1.0–3.9  →  Căng thẳng cao: Beta rất cao, Alpha '
                          'gần như bị triệt tiêu. Khuyến nghị dành thời gian '
                          'thư giãn và có thể tham khảo chuyên gia.',
                    ),
                    SizedBox(height: 16),
                    _TheorySection(
                      icon: Icons.science_outlined,
                      title: 'Tài liệu tham khảo',
                      color: Color(0xFF78909C),
                      body:
                          '1. Niedermeyer E., da Silva F.L. – '
                          '"Electroencephalography: Basic Principles, '
                          'Clinical Applications, and Related Fields" (2004)\n\n'
                          '2. Barry R.J. et al. – "EEG differences between '
                          'eyes-closed and eyes-open resting conditions" '
                          '(Clinical Neurophysiology, 2007)\n\n'
                          '3. Lomas T. et al. – "A systematic review of the '
                          'neurophysiology of mindfulness on EEG oscillations" '
                          '(Neuroscience & Biobehavioral Reviews, 2015)\n\n'
                          '4. Tiến sĩ Andrew Weil – Kỹ thuật thở 4-7-8 '
                          '(University of Arizona Center for Integrative '
                          'Medicine)',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreBreakdownRow(
    String label,
    double score,
    String weight,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
        ),
        const Spacer(),
        Text(
          '${score.toStringAsFixed(1)}/10',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            weight,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsCard() {
    final insights = <_InsightItem>[
      if (_sleepInsight.isNotEmpty)
        _InsightItem(Icons.bedtime_outlined, 'Giấc ngủ', _sleepInsight),
      if (_focusInsight.isNotEmpty)
        _InsightItem(Icons.center_focus_strong, 'Tập trung', _focusInsight),
      if (_tensionInsight.isNotEmpty)
        _InsightItem(
          Icons.accessibility_new,
          'Căng cứng cơ thể',
          _tensionInsight,
        ),
      if (_copingInsight.isNotEmpty)
        _InsightItem(
          Icons.spa_outlined,
          'Phương pháp giải toả',
          _copingInsight,
        ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.quiz_outlined, color: Color(0xFF7C4DFF), size: 20),
              SizedBox(width: 8),
              Text(
                'Phân tích từ khảo sát',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Kết hợp dữ liệu 10 câu hỏi trắc nghiệm ban đầu',
            style: TextStyle(fontSize: 12, color: AppColors.neutral600),
          ),
          const SizedBox(height: 12),
          ...insights.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.icon, size: 18, color: const Color(0xFF7C4DFF)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.text,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.neutral700,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recommended exercises based on score ─────────────────────────────────

  Widget _buildRecommendedExercises() {
    final recs = _getRecommendations();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Breathing section ──
        _buildRecSectionHeader(
          icon: Icons.air,
          title: 'Bài tập thở khuyến nghị',
          color: const Color(0xFF129EAF),
        ),
        const SizedBox(height: 10),
        ...recs.breathing.map((r) => _buildBreathingRecCard(r)),
        const SizedBox(height: 20),
        // ── Meditation section ──
        _buildRecSectionHeader(
          icon: Icons.self_improvement,
          title: 'Bài tập thiền khuyến nghị',
          color: const Color(0xFF7C4DFF),
        ),
        const SizedBox(height: 10),
        ...recs.meditation.map((r) => _buildMeditationRecCard(r)),
      ],
    );
  }

  Widget _buildRecSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBreathingRecCard(_BreathingRec rec) {
    final exercise = sampleBreathingExercises.firstWhere(
      (e) => e.id == rec.exerciseId,
      orElse: () => sampleBreathingExercises.first,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => DraggableScrollableSheet(
                initialChildSize: 0.85,
                maxChildSize: 0.95,
                minChildSize: 0.5,
                builder: (_, controller) => ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: BreathingDetailScreen(exercise: exercise),
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0F0F0)),
            ),
            child: Row(
              children: [
                // Icon badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: exercise.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.air,
                    color: exercise.primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        exercise.shortPattern,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: exercise.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rec.reason,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.neutral600,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeditationRecCard(_MeditationRec rec) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DetailLessonMeditationPage(
                  lessonNumber: 1,
                  lessonTitle: rec.title,
                  isResume: false,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8E0FF)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    rec.icon,
                    color: const Color(0xFF7C4DFF),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rec.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${rec.lessons} bài · ${rec.duration}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7C4DFF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rec.reason,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.neutral600,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _Recommendations _getRecommendations() {
    if (_overallScore >= 7.5) {
      // Relaxed — maintain and deepen
      return _Recommendations(
        breathing: [
          _BreathingRec(
            exerciseId: 'breathing_555',
            reason:
                'Bạn đang ở trạng thái thư giãn tốt. Thở 5-5-5 giúp duy trì '
                'sự cân bằng Alpha hiện tại và đào sâu trạng thái thiền định.',
          ),
          _BreathingRec(
            exerciseId: 'breathing_relaxation',
            reason:
                'Bài thở thư giãn 4-5-6 phù hợp để kéo dài trạng thái bình '
                'tĩnh, tăng cường sóng Alpha trước giờ ngủ.',
          ),
        ],
        meditation: [
          _MeditationRec(
            title: 'Thiền Hít Thở Sâu & Thư Giãn',
            icon: Icons.spa,
            lessons: 10,
            duration: '~5-10 phút/bài',
            reason:
                'Sóng Alpha ổn định cho thấy bạn sẵn sàng đào sâu thiền định. '
                'Khóa này giúp bạn tận dụng trạng thái thư giãn để đạt '
                'mức thiền sâu hơn.',
          ),
          _MeditationRec(
            title: 'Thiền Buổi Sáng',
            icon: Icons.wb_sunny_outlined,
            lessons: 10,
            duration: '~5-10 phút/bài',
            reason:
                'Duy trì sóng Alpha từ sáng sớm giúp bạn giữ trạng thái '
                'bình tĩnh và sáng tạo suốt cả ngày.',
          ),
        ],
      );
    } else if (_overallScore >= 6.0) {
      // Mild stress — calming focus
      return _Recommendations(
        breathing: [
          _BreathingRec(
            exerciseId: 'breathing_box',
            reason:
                'Sóng Beta tăng nhẹ cho thấy căng thẳng nhẹ. Thở hộp (Box Breathing) '
                'kích hoạt hệ thần kinh đối giao cảm, giúp hạ Beta và tăng Alpha '
                'hiệu quả trong 4-5 phút.',
          ),
          _BreathingRec(
            exerciseId: 'breathing_focus',
            reason:
                'Bài thở tập trung 3-5-3 giúp ổn định sóng não khi bạn cần '
                'duy trì tập trung mà không gia tăng căng thẳng.',
          ),
        ],
        meditation: [
          _MeditationRec(
            title: 'Thiền Cân Bằng Cảm Xúc',
            icon: Icons.balance,
            lessons: 10,
            duration: '~5-10 phút/bài',
            reason:
                'Mức Beta nhẹ thường đi kèm cảm xúc dao động. Khóa thiền này '
                'giúp nhận diện và cân bằng cảm xúc, giảm hoạt động Beta thừa.',
          ),
          _MeditationRec(
            title: 'Ổn Định Tâm Trí (Tập trung)',
            icon: Icons.center_focus_strong,
            lessons: 10,
            duration: '~5-10 phút/bài',
            reason:
                'Tăng cường khả năng tập trung có chủ đích giúp chuyển từ '
                'Beta căng thẳng sang Beta tập trung lành mạnh.',
          ),
        ],
      );
    } else if (_overallScore >= 4.0) {
      // Moderate stress — active de-stress
      return _Recommendations(
        breathing: [
          _BreathingRec(
            exerciseId: 'breathing_478',
            reason:
                'Chỉ số Beta cao liên tục. Kỹ thuật 4-7-8 của Dr. Weil '
                'kích hoạt phản xạ thư giãn mạnh, giảm nhanh hoạt động Beta '
                'và ức chế phản ứng stress.',
          ),
          _BreathingRec(
            exerciseId: 'breathing_box',
            reason:
                'Box Breathing được quân đội Mỹ sử dụng trong áp lực cao. '
                'Phù hợp để hạ nhanh mức căng thẳng trung bình của bạn.',
          ),
        ],
        meditation: [
          _MeditationRec(
            title: 'Thiền Giảm Căng Thẳng',
            icon: Icons.healing,
            lessons: 10,
            duration: '~5-10 phút/bài',
            reason:
                'Với mức Beta cao, bạn cần thiền chuyên biệt giảm stress. '
                'Khóa này dùng kỹ thuật quét cơ thể và thả lỏng để '
                'giảm hoạt động Beta và phục hồi Alpha.',
          ),
          _MeditationRec(
            title: 'Thiền Quét Toàn Thân (Body Scan)',
            icon: Icons.accessibility_new,
            lessons: 10,
            duration: '~5-10 phút/bài',
            reason:
                'Body Scan giúp nhận diện các điểm căng cứng cơ thể — '
                'mối liên hệ trực tiếp với sóng Beta cao. '
                'Thả lỏng từng nhóm cơ giúp não chuyển sang Alpha.',
          ),
        ],
      );
    } else {
      // High stress — urgent relaxation
      return _Recommendations(
        breathing: [
          _BreathingRec(
            exerciseId: 'breathing_478',
            reason:
                'Mức căng thẳng cao — kỹ thuật 4-7-8 là ưu tiên hàng đầu. '
                'Thời gian giữ hơi dài (7s) và thở ra chậm (8s) kích hoạt '
                'mạnh hệ phó giao cảm, giúp hạ Beta nhanh chóng.',
          ),
          _BreathingRec(
            exerciseId: 'breathing_relaxation',
            reason:
                'Sau bài 4-7-8, thở thư giãn 4-5-6 giúp duy trì trạng thái '
                'bình tĩnh và ngăn Beta tăng trở lại.',
          ),
        ],
        meditation: [
          _MeditationRec(
            title: 'Thiền Giảm Căng Thẳng',
            icon: Icons.healing,
            lessons: 10,
            duration: '~5-10 phút/bài',
            reason:
                'Với mức Beta rất cao, bạn cần thiền chuyên sâu giảm stress. '
                'Khóa này sử dụng kỹ thuật mindfulness kết hợp hít thở có '
                'chủ đích để phục hồi sóng Alpha bị ức chế.',
          ),
          _MeditationRec(
            title: 'Thiền Đi Bộ Nhẹ Nhàng',
            icon: Icons.directions_walk,
            lessons: 10,
            duration: '~5-10 phút/bài',
            reason:
                'Khi căng thẳng cao, ngồi yên có thể khó khăn. Thiền đi bộ '
                'là phương pháp nhẹ nhàng hơn, giúp giải phóng năng lượng '
                'Beta thừa trong khi vẫn rèn luyện chánh niệm.',
          ),
          _MeditationRec(
            title: 'Thiền Quét Toàn Thân (Body Scan)',
            icon: Icons.accessibility_new,
            lessons: 10,
            duration: '~5-10 phút/bài',
            reason:
                'Căng thẳng cao thường tích tụ ở cơ thể. Body Scan giúp '
                'nhận diện và thả lỏng từng điểm căng cứng, '
                'trực tiếp hạ hoạt động Beta.',
          ),
        ],
      );
    }
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _LegendDot(color: alphaColor, label: 'Alpha (8-13Hz)'),
        SizedBox(width: 16),
        _LegendDot(color: betaColor, label: 'Beta (13-30Hz)'),
        SizedBox(width: 16),
        _LegendDot(color: deltaColor, label: 'Delta (0.5-4Hz)'),
      ],
    );
  }

  // ── Stress scale (same style as HomePage) ───────────────────────────────

  Widget _buildStressScale() {
    // Convert _overallScore (1-10 relaxation) to stress (inverted)
    final int stressInt = (11 - _overallScore).round().clamp(1, 10);

    const List<_StressZone> zones = [
      _StressZone(
        label: 'Bình tĩnh',
        range: '1–2',
        from: 1,
        to: 2,
        color: Color(0xFF22C55E),
      ),
      _StressZone(
        label: 'Bình thường',
        range: '3–4',
        from: 3,
        to: 4,
        color: Color(0xFF86EFAC),
      ),
      _StressZone(
        label: 'Nhẹ',
        range: '5–6',
        from: 5,
        to: 6,
        color: Color(0xFFFACC15),
      ),
      _StressZone(
        label: 'Vừa',
        range: '7–8',
        from: 7,
        to: 8,
        color: Color(0xFFF97316),
      ),
      _StressZone(
        label: 'Cao',
        range: '9–10',
        from: 9,
        to: 10,
        color: Color(0xFFEF4444),
      ),
    ];

    Color stressColor(int s) {
      if (s <= 2) return const Color(0xFF22C55E);
      if (s <= 4) return const Color(0xFF65A30D);
      if (s <= 6) return const Color(0xFFCA8A04);
      if (s <= 8) return const Color(0xFFF97316);
      return const Color(0xFFEF4444);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Mức độ căng thẳng',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: stressColor(stressInt).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: stressColor(stressInt).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '$stressInt / 10',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: stressColor(stressInt),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Gradient bar with pointer
          LayoutBuilder(
            builder: (context, constraints) {
              final double barWidth = constraints.maxWidth;
              final double thumbX = ((stressInt - 1) / 9) * barWidth;

              return Column(
                children: [
                  // Pointer label
                  Padding(
                    padding: EdgeInsets.only(
                      left: (thumbX - 18).clamp(0, barWidth - 36),
                    ),
                    child: Container(
                      width: 36,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: stressColor(stressInt),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$stressInt',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Gradient bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 18,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF22C55E),
                            Color(0xFF86EFAC),
                            Color(0xFFFACC15),
                            Color(0xFFF97316),
                            Color(0xFFEF4444),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Ticks 1-10
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List<Widget>.generate(10, (i) {
                        final int val = i + 1;
                        final bool active = stressInt == val;
                        return Text(
                          '$val',
                          style: TextStyle(
                            fontSize: active ? 13 : 11,
                            fontWeight: active
                                ? FontWeight.w800
                                : FontWeight.w400,
                            color: active
                                ? stressColor(stressInt)
                                : AppColors.neutral500,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          // Zone chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: zones.map((zone) {
              final bool active =
                  stressInt >= zone.from && stressInt <= zone.to;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? zone.color.withValues(alpha: 0.18)
                      : AppColors.neutral100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active ? zone.color : AppColors.neutral200,
                    width: active ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? zone.color : AppColors.neutral300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${zone.label} (${zone.range})',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                        color: active ? zone.color : AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveAvgCard(String name, String freq, double avg, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  freq,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${avg.toStringAsFixed(1)} µV',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.neutral500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF129EAF),
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

// ── Preparation step widget ───────────────────────────────────────────────

class _PrepStep extends StatelessWidget {
  const _PrepStep({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE0F7F7),
          ),
          child: Center(
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF129EAF),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.neutral700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Legend dot ─────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.neutral600),
        ),
      ],
    );
  }
}

// ── Scrollable interactive wave chart ──────────────────────────────────────

class _InteractiveWaveChart extends StatefulWidget {
  const _InteractiveWaveChart({
    required this.alpha,
    required this.beta,
    required this.delta,
    required this.height,
    this.pointsPerScreen = 40,
    this.autoScrollToEnd = false,
  });

  final List<double> alpha;
  final List<double> beta;
  final List<double> delta;
  final double height;
  final int pointsPerScreen;
  final bool autoScrollToEnd;

  @override
  State<_InteractiveWaveChart> createState() => _InteractiveWaveChartState();
}

class _InteractiveWaveChartState extends State<_InteractiveWaveChart> {
  final ScrollController _scrollController = ScrollController();
  int? _tooltipIndex;
  double _tooltipDx = 0;
  double _tooltipDy = 0;

  static const double _pointSpacing = 22.0;
  static const double _yLabelWidth = 30.0;

  double get _chartWidth {
    final int maxLen = [
      widget.alpha.length,
      widget.beta.length,
      widget.delta.length,
    ].reduce((a, b) => a > b ? a : b);
    return (maxLen * _pointSpacing).clamp(300, double.infinity);
  }

  @override
  void didUpdateWidget(covariant _InteractiveWaveChart old) {
    super.didUpdateWidget(old);
    if (widget.autoScrollToEnd) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTapUp(TapUpDetails details) {
    final dx = details.localPosition.dx + _scrollController.offset;
    final maxLen = widget.alpha.length;
    if (maxLen == 0) return;

    final int idx = (dx / _pointSpacing).round().clamp(0, maxLen - 1);
    setState(() {
      _tooltipIndex = _tooltipIndex == idx ? null : idx;
      _tooltipDx = details.localPosition.dx + _yLabelWidth;
      _tooltipDy = details.localPosition.dy;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cw = _chartWidth;
    final double chartH = widget.height - 28;

    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Row(
            children: [
              // ── Sticky Y-axis labels ──
              Container(
                width: _yLabelWidth,
                padding: const EdgeInsets.only(top: 16, bottom: 12),
                color: AppColors.white,
                child: CustomPaint(
                  size: Size(_yLabelWidth, chartH),
                  painter: _YAxisLabelPainter(),
                ),
              ),
              // ── Scrollable chart area ──
              Expanded(
                child: GestureDetector(
                  onTapUp: _handleTapUp,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(4, 16, 14, 12),
                    child: SizedBox(
                      width: cw,
                      height: chartH,
                      child: CustomPaint(
                        size: Size(cw, chartH),
                        painter: _WaveChartPainter(
                          alpha: widget.alpha,
                          beta: widget.beta,
                          delta: widget.delta,
                          pointSpacing: _pointSpacing,
                          tooltipIndex: _tooltipIndex,
                          drawYLabels: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Sticky Y-axis overlay to cover scroll bleed
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: _yLabelWidth,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(
                  right: BorderSide(color: const Color(0xFFEEEEEE), width: 0.5),
                ),
              ),
              padding: const EdgeInsets.only(top: 16, bottom: 12),
              child: CustomPaint(
                size: Size(_yLabelWidth, chartH),
                painter: _YAxisLabelPainter(),
              ),
            ),
          ),
          // Tooltip overlay (tap)
          if (_tooltipIndex != null && _tooltipIndex! < widget.alpha.length)
            _buildTooltipOverlay(),
          // Live latest-data tooltip (top-right, during measurement)
          if (widget.autoScrollToEnd && widget.alpha.isNotEmpty)
            _buildLiveTooltip(),
        ],
      ),
    );
  }

  Widget _buildLiveTooltip() {
    final int i = widget.alpha.length - 1;
    final a = widget.alpha[i];
    final b = i < widget.beta.length ? widget.beta[i] : 0.0;
    final d = i < widget.delta.length ? widget.delta[i] : 0.0;

    return Positioned(
      right: 6,
      top: 6,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xF0FFFFFF),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 6,
                offset: Offset(0, 1),
              ),
            ],
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(i / 2).toStringAsFixed(1)}s',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 2),
              _liveRow('A', a, const Color(0xFF149A33)),
              _liveRow('B', b, const Color(0xFF009CC4)),
              _liveRow('D', d, const Color(0xFFE8575A)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _liveRow(String tag, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 4),
          Text(
            '$tag ${value.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltipOverlay() {
    final int i = _tooltipIndex!;
    final a = i < widget.alpha.length ? widget.alpha[i] : 0.0;
    final b = i < widget.beta.length ? widget.beta[i] : 0.0;
    final d = i < widget.delta.length ? widget.delta[i] : 0.0;

    final double left = _tooltipDx.clamp(8, 200);
    final double top = _tooltipDy;

    return Positioned(
      left: left,
      top: top < widget.height / 2 ? top + 10 : top - 90,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xF0FFFFFF),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x20000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mẫu #${i + 1} · ${(i / 2).toStringAsFixed(1)}s',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 4),
              _tooltipRow('Alpha', a, const Color(0xFF149A33)),
              _tooltipRow('Beta', b, const Color(0xFF009CC4)),
              _tooltipRow('Delta', d, const Color(0xFFE8575A)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tooltipRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 5),
          Text(
            '$label: ${value.toStringAsFixed(1)} µV',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Insight item data ─────────────────────────────────────────────────────

class _InsightItem {
  const _InsightItem(this.icon, this.title, this.text);
  final IconData icon;
  final String title;
  final String text;
}

// ── Recommendation data models ────────────────────────────────────────────

class _BreathingRec {
  const _BreathingRec({required this.exerciseId, required this.reason});
  final String exerciseId;
  final String reason;
}

class _MeditationRec {
  const _MeditationRec({
    required this.title,
    required this.icon,
    required this.lessons,
    required this.duration,
    required this.reason,
  });
  final String title;
  final IconData icon;
  final int lessons;
  final String duration;
  final String reason;
}

class _Recommendations {
  const _Recommendations({required this.breathing, required this.meditation});
  final List<_BreathingRec> breathing;
  final List<_MeditationRec> meditation;
}

// ── Stress zone data ──────────────────────────────────────────────────────

class _StressZone {
  const _StressZone({
    required this.label,
    required this.range,
    required this.from,
    required this.to,
    required this.color,
  });

  final String label;
  final String range;
  final int from;
  final int to;
  final Color color;
}

// ── Wave chart painter (scrollable, with tooltip support) ─────────────────

class _YAxisLabelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const labels = ['100', '75', '50', '25', '0'];
    for (int i = 0; i < labels.length; i++) {
      final y = size.height * i / 4;
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(fontSize: 9, color: Color(0xFFB0B0B0)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width - tp.width - 4, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _WaveChartPainter extends CustomPainter {
  _WaveChartPainter({
    required this.alpha,
    required this.beta,
    required this.delta,
    required this.pointSpacing,
    this.tooltipIndex,
    this.drawYLabels = true,
  });

  final List<double> alpha;
  final List<double> beta;
  final List<double> delta;
  final double pointSpacing;
  final int? tooltipIndex;
  final bool drawYLabels;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Y-axis labels (only if not using sticky labels)
    if (drawYLabels) {
      const labels = ['100', '75', '50', '25', '0'];
      for (int i = 0; i < labels.length; i++) {
        final y = size.height * i / 4;
        final tp = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: const TextStyle(fontSize: 9, color: Color(0xFFB0B0B0)),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(0, y - tp.height / 2));
      }
    }

    // X-axis time ticks every 10 data points (~5s)
    final int maxLen = [
      alpha.length,
      beta.length,
      delta.length,
    ].reduce((a, b) => a > b ? a : b);
    for (int i = 0; i < maxLen; i += 10) {
      final x = i * pointSpacing;
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x, size.height - 4),
        gridPaint..strokeWidth = 1,
      );
      final sec = (i / 2).toStringAsFixed(0);
      final tp = TextPainter(
        text: TextSpan(
          text: '${sec}s',
          style: const TextStyle(fontSize: 8, color: Color(0xFFB0B0B0)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - tp.height));
    }

    // Draw waves
    _drawLine(canvas, size, alpha, const Color(0xFF149A33));
    _drawLine(canvas, size, beta, const Color(0xFF009CC4));
    _drawLine(canvas, size, delta, const Color(0xFFE8575A));

    // Tooltip vertical line + dots
    if (tooltipIndex != null && tooltipIndex! < maxLen) {
      final tx = tooltipIndex! * pointSpacing;
      final linePaint = Paint()
        ..color = const Color(0x40000000)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(tx, 0), Offset(tx, size.height), linePaint);

      void drawDot(List<double> data, Color c) {
        if (tooltipIndex! < data.length) {
          final dy = size.height - (data[tooltipIndex!] / 100 * size.height);
          canvas.drawCircle(
            Offset(tx, dy),
            4,
            Paint()
              ..color = c
              ..style = PaintingStyle.fill,
          );
          canvas.drawCircle(
            Offset(tx, dy),
            4,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
        }
      }

      drawDot(alpha, const Color(0xFF149A33));
      drawDot(beta, const Color(0xFF009CC4));
      drawDot(delta, const Color(0xFFE8575A));
    }
  }

  void _drawLine(Canvas canvas, Size size, List<double> data, Color color) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final x = i * pointSpacing;
      final y = size.height - (data[i] / 100 * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * pointSpacing;
        final prevY = size.height - (data[i - 1] / 100 * size.height);
        final cpx = (prevX + x) / 2;
        path.cubicTo(cpx, prevY, cpx, y, x, y);
      }
    }

    canvas.drawPath(path, paint);

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    final fillPath = Path.from(path)
      ..lineTo((data.length - 1) * pointSpacing, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _WaveChartPainter old) => true;
}

// ── Theory Bottom-Sheet helper ──────────────────────────────────────────────

class _TheorySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final String body;

  const _TheorySection({
    required this.icon,
    required this.title,
    required this.color,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: Color(0xFF37474F),
            ),
          ),
        ],
      ),
    );
  }
}
