import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:yc_product_plugin/yc_product_plugin.dart';

import '../../core/theme/app_colors.dart';
import '../../models/breathing_exercise.dart';
import '../../screens/Breathing/BreathingDetailScreen.dart';
import '../../sections/meditation/DetailLessonMeditation.dart';
import '../../services/app_state_service.dart';
import '../../services/ble_service.dart';
import '../../services/brain_waves_mock_sleep_service.dart';
import '../../services/smart_ring/smart_ring_connection_service.dart';
import '../../services/smart_ring/smart_ring_measure_service.dart';

class BrainWavesPage extends StatefulWidget {
  const BrainWavesPage({super.key});

  @override
  State<BrainWavesPage> createState() => _BrainWavesPageState();
}

class _BrainWavesPageState extends State<BrainWavesPage> {
  final SmartRingConnectionService _smartRingConnectionService =
      SmartRingConnectionService.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        AppStateService.deviceConnectedNotifier,
        _smartRingConnectionService.bluetoothStateNotifier,
        _smartRingConnectionService.connectedDeviceNotifier,
      ]),
      builder: (_, __) {
        final bool espReady = AppStateService.deviceConnectedNotifier.value;
        final bool ringReady =
            _smartRingConnectionService.connectedDeviceNotifier.value != null &&
            _smartRingConnectionService.bluetoothStateNotifier.value ==
                BluetoothState.connected;

        if (espReady && ringReady) {
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
  final SmartRingConnectionService _smartRingConnectionService =
      SmartRingConnectionService.instance;
  bool _isConnectingEsp = false;
  String? _espError;
  String? _ringError;

  @override
  void initState() {
    super.initState();
    unawaited(_smartRingConnectionService.initialize());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[
            AppStateService.deviceConnectedNotifier,
            AppStateService.connectedDeviceNameNotifier,
            _ble.isScanningNotifier,
            _ble.scanResultsNotifier,
            _smartRingConnectionService.isScanningNotifier,
            _smartRingConnectionService.isConnectingNotifier,
            _smartRingConnectionService.bluetoothStateNotifier,
            _smartRingConnectionService.scanResultsNotifier,
            _smartRingConnectionService.connectedDeviceNotifier,
          ]),
          builder: (_, __) {
            final bool espReady = AppStateService.deviceConnectedNotifier.value;
            final bool ringReady = _isSmartRingReady;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                children: [
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
                    'Chuẩn bị đủ 2 thiết bị BLE trước khi bắt đầu phiên đo kết hợp.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.neutral600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildEspSection(espReady)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildSmartRingSection(ringReady)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: espReady && ringReady
                          ? const Color(0xFFE8F5E9)
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: espReady && ringReady
                            ? const Color(0xFFA5D6A7)
                            : const Color(0xFFEAEAEA),
                      ),
                    ),
                    child: Text(
                      espReady && ringReady
                          ? 'ESP32 và Smart Ring đã sẵn sàng. Màn hình đo sẽ mở tự động.'
                          : 'Cần cả ESP32 và Smart Ring ở trạng thái sẵn sàng trước khi bắt đầu đo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: espReady && ringReady
                            ? const Color(0xFF2E7D32)
                            : AppColors.neutral700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEspSection(bool ready) {
    final List<BleDeviceInfo> devices = _ble.scanResultsNotifier.value;
    final bool scanning = _ble.isScanningNotifier.value;
    final String deviceName =
        AppStateService.connectedDeviceNameNotifier.value ?? 'ESP32S3_TOUCH';

    return _ConnectionSectionCard(
      title: 'ESP32',
      subtitle: 'Thiết bị đo sóng não',
      accent: const Color(0xFF129EAF),
      icon: Icons.memory_rounded,
      ready: ready,
      statusLabel: ready
          ? 'Sẵn sàng'
          : (scanning || _isConnectingEsp ? 'Đang kết nối' : 'Chưa kết nối'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConnectionStatusLine(
            label: ready ? deviceName : 'Chưa có thiết bị ESP32',
            value: ready ? 'Đã kết nối' : 'Cần scan để kết nối',
            ok: ready,
          ),
          const SizedBox(height: 8),
          SizedBox(height: 18, child: _SectionMessageSlot(message: _espError)),
          const SizedBox(height: 12),
          if (ready)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _disconnectEsp,
                icon: const Icon(Icons.link_off_rounded),
                label: const Text('Ngắt kết nối'),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: scanning || _isConnectingEsp ? null : _startScan,
                icon: scanning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.bluetooth_searching),
                label: Text(scanning ? 'Đang quét...' : 'Quét ESP32'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF129EAF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(46),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 96),
            child: _SectionDeviceListSlot(
              children: !ready && devices.isNotEmpty
                  ? devices
                        .take(2)
                        .map(
                          (BleDeviceInfo device) => _CompactBleDeviceTile(
                            title: device.name,
                            subtitle: device.rssi != null
                                ? '${device.rssi} dBm'
                                : 'ESP32 BLE',
                            actionLabel: 'Kết nối',
                            onTap: () => _connectEspDevice(device),
                          ),
                        )
                        .toList()
                  : <Widget>[
                      _SectionHintCard(
                        text: ready
                            ? 'ESP32 đã sẵn sàng cho phiên đo sóng não.'
                            : 'Bấm quét để tìm headband ESP32 gần bạn.',
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartRingSection(bool ready) {
    final List<BluetoothDevice> devices =
        _smartRingConnectionService.scanResultsNotifier.value;
    final bool scanning = _smartRingConnectionService.isScanningNotifier.value;
    final bool connecting =
        _smartRingConnectionService.isConnectingNotifier.value;
    final BluetoothDevice? connectedDevice =
        _smartRingConnectionService.connectedDeviceNotifier.value;

    return _ConnectionSectionCard(
      title: 'Smart Ring',
      subtitle: 'Thiết bị đo 3 chỉ số',
      accent: const Color(0xFF18ADC3),
      icon: Icons.health_and_safety_rounded,
      ready: ready,
      statusLabel: ready
          ? 'Sẵn sàng'
          : (scanning || connecting ? 'Đang kết nối' : 'Chưa kết nối'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConnectionStatusLine(
            label: ready
                ? (connectedDevice?.name ?? 'Smart Ring')
                : 'Chưa có thiết bị Smart Ring',
            value: ready ? 'Đã kết nối' : 'Cần scan để kết nối',
            ok: ready,
          ),
          const SizedBox(height: 8),
          SizedBox(height: 18, child: _SectionMessageSlot(message: _ringError)),
          const SizedBox(height: 12),
          if (ready)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _disconnectSmartRing,
                icon: const Icon(Icons.link_off_rounded),
                label: const Text('Ngắt kết nối'),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: scanning || connecting ? null : _startSmartRingScan,
                icon: scanning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.health_and_safety_outlined),
                label: Text(scanning ? 'Đang quét...' : 'Quét Smart Ring'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF18ADC3),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(46),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 96),
            child: _SectionDeviceListSlot(
              children: !ready && devices.isNotEmpty
                  ? devices
                        .take(2)
                        .map(
                          (BluetoothDevice device) => _CompactBleDeviceTile(
                            title: device.name,
                            subtitle: device.deviceBunId.isEmpty
                                ? 'Smart Ring'
                                : device.deviceBunId,
                            actionLabel: 'Kết nối',
                            onTap: () => _connectRingDevice(device),
                          ),
                        )
                        .toList()
                  : <Widget>[
                      _SectionHintCard(
                        text: ready
                            ? 'Smart Ring đã sẵn sàng cho phép đo 3 chỉ số.'
                            : 'Bấm quét để tìm Smart Ring gần bạn.',
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _disconnectEsp() async {
    await _ble.disconnect();
  }

  Future<void> _disconnectSmartRing() async {
    await _smartRingConnectionService.disconnectDevice();
  }

  bool get _isSmartRingReady =>
      _smartRingConnectionService.connectedDeviceNotifier.value != null &&
      _smartRingConnectionService.bluetoothStateNotifier.value ==
          BluetoothState.connected;

  Future<void> _startSmartRingScan() async {
    setState(() {
      _ringError = null;
    });
    try {
      await _smartRingConnectionService.startScan();
    } catch (e) {
      if (mounted) {
        setState(() {
          _ringError = 'Không thể quét: $e';
        });
      }
    }
  }

  Future<void> _connectRingDevice(BluetoothDevice device) async {
    setState(() {
      _ringError = null;
    });
    try {
      await _smartRingConnectionService.connectDevice(device);
    } catch (e) {
      if (mounted) {
        setState(() {
          _ringError = 'Kết nối thất bại: $e';
        });
      }
    }
  }

  Future<void> _startScan() async {
    setState(() {
      _espError = null;
    });
    try {
      await _ble.startScan();
    } catch (e) {
      if (mounted) {
        setState(() {
          _espError = 'Không thể quét: $e';
        });
      }
    }
  }

  Future<void> _connectEspDevice(BleDeviceInfo device) async {
    setState(() {
      _isConnectingEsp = true;
      _espError = null;
    });
    try {
      await _ble.connect(device);
    } catch (e) {
      if (mounted) {
        setState(() {
          _espError = 'Kết nối thất bại: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnectingEsp = false;
        });
      }
    }
  }
}

class _ConnectionSectionCard extends StatelessWidget {
  const _ConnectionSectionCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.ready,
    required this.statusLabel,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final bool ready;
  final String statusLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ready
              ? accent.withValues(alpha: 0.35)
              : const Color(0xFFEAEAEA),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: ready ? const Color(0xFFE8F5E9) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: ready ? const Color(0xFF2E7D32) : AppColors.neutral700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SectionMessageSlot extends StatelessWidget {
  const _SectionMessageSlot({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        message!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, color: AppColors.red600),
      ),
    );
  }
}

class _SectionDeviceListSlot extends StatelessWidget {
  const _SectionDeviceListSlot({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(children: children);
  }
}

class _SectionHintCard extends StatelessWidget {
  const _SectionHintCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral600,
          height: 1.35,
        ),
      ),
    );
  }
}

class _ConnectionStatusLine extends StatelessWidget {
  const _ConnectionStatusLine({
    required this.label,
    required this.value,
    required this.ok,
  });

  final String label;
  final String value;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ok ? const Color(0xFF2E7D32) : AppColors.neutral600,
          ),
        ),
      ],
    );
  }
}

class _CompactBleDeviceTile extends StatelessWidget {
  const _CompactBleDeviceTile({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, color: AppColors.neutral600),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(36),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
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
  final SmartRingConnectionService _smartRingConnectionService =
      SmartRingConnectionService.instance;
  final SmartRingMeasureService _smartRingMeasureService =
      SmartRingMeasureService.instance;

  _MeasurePhase _phase = _MeasurePhase.idle;
  Timer? _phaseTimer;
  Timer? _chartTimer;
  Timer? _signalResumeTimer;
  bool _isStartingCombined = false;

  // ── Wearing detection ──
  bool _headbandRemovedHandled = false;

  bool get _isWearing {
    if (!AppStateService.isWearingDetectionEnabled) return true;
    return AppStateService.isTouchDetected == true;
  }

  bool get _isEspReady => AppStateService.deviceConnectedNotifier.value;

  bool get _isRingReady =>
      _smartRingConnectionService.connectedDeviceNotifier.value != null &&
      _smartRingConnectionService.bluetoothStateNotifier.value ==
          BluetoothState.connected;

  bool get _canStartMeasurement =>
      _phase == _MeasurePhase.idle &&
      !_isStartingCombined &&
      _isWearing &&
      _isEspReady &&
      _isRingReady;

  SmartRingMeasureType? get _activeRingMeasureType =>
      _smartRingMeasureService.currentMeasureType;

  // Prepare countdown
  int _prepCountdown = 5;

  // Measuring progress
  int _elapsedSeconds = 0;
  final GlobalKey _phaseSectionKey = GlobalKey();

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
  bool _brainCaptureCompleted = false;
  bool _smartRingSequenceCompleted = false;
  bool _ringAbortHandled = false;

  // Final mock results
  double _alphaAvg = 0;
  double _betaAvg = 0;
  double _deltaAvg = 0;
  double _overallScore = 0;
  double _eegScore = 0;
  double _questionnaireScore = 0;
  double _smartRingScore = 0;
  double _sleepScore = 0;
  String _evaluation = '';
  String _evaluationDetail = '';
  Color _evalColor = const Color(0xFF4F9A67);

  // Questionnaire-based insights for report
  String _sleepInsight = '';
  String _focusInsight = '';
  String _tensionInsight = '';
  String _copingInsight = '';
  String _smartRingSummary = '';
  String _sleepSummary = '';
  String _sleepRecoveryInsight = '';
  String _heartRateInsight = '';
  String _spo2Insight = '';
  String _bloodPressureInsight = '';
  String _vitalAlignmentInsight = '';

  // Smart Ring live vitals
  int? _heartRateValue;
  int? _spo2Value;
  int? _bloodPressureSystolic;
  int? _bloodPressureDiastolic;
  SmartRingMeasureState _ringMeasureState = SmartRingMeasureState.idle;

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  String? _playingTrack;
  Map<String, dynamic> _mockSleepSummary = Map<String, dynamic>.from(
    BrainWavesMockSleepService.defaultSummary,
  );

  // Wave definitions
  static const Color alphaColor = Color(0xFF149A33);
  static const Color betaColor = Color(0xFF009CC4);
  static const Color deltaColor = Color(0xFFE8575A);

  @override
  void initState() {
    super.initState();
    _configureMeasureService();
    unawaited(_loadMockSleepSummary());
    AppStateService.touchDetectedNotifier.addListener(_onTouchChanged);
    AppStateService.wearingDetectionEnabledNotifier.addListener(
      _onWearingToggleChanged,
    );
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _chartTimer?.cancel();
    _signalResumeTimer?.cancel();
    _audioPlayer.dispose();
    _musicPlayer.dispose();
    _smartRingMeasureService.setCallbacks(
      onHeartRateData: null,
      onSpO2Data: null,
      onBloodPressureData: null,
      onStateChanged: null,
      onError: null,
      onMeasureCompleted: null,
      onBloodPressureMeasureCompleted: null,
    );
    AppStateService.touchDetectedNotifier.removeListener(_onTouchChanged);
    AppStateService.wearingDetectionEnabledNotifier.removeListener(
      _onWearingToggleChanged,
    );
    super.dispose();
  }

  void _configureMeasureService() {
    _smartRingMeasureService.setCallbacks(
      onHeartRateData: (data) {
        if (!mounted) {
          return;
        }
        setState(() {
          _heartRateValue = data.value;
        });
      },
      onSpO2Data: (data) {
        if (!mounted) {
          return;
        }
        setState(() {
          _spo2Value = data.value;
        });
      },
      onBloodPressureData: (data) {
        if (!mounted) {
          return;
        }
        setState(() {
          _bloodPressureSystolic = data.systolic;
          _bloodPressureDiastolic = data.diastolic;
        });
      },
      onStateChanged: (state) {
        if (!mounted) {
          return;
        }
        setState(() {
          _ringMeasureState = state;
        });
      },
      onError: (errorMessage) {
        if (!mounted) {
          return;
        }
        _abortCombinedMeasurementFromRing(errorMessage);
        setState(() {
          _ringMeasureState = SmartRingMeasureState.error;
        });
      },
      onMeasureCompleted: (data) {
        if (!mounted) {
          return;
        }
        setState(() {
          if (data.type == SmartRingMeasureType.heartRate) {
            _heartRateValue = data.value;
          } else if (data.type == SmartRingMeasureType.bloodOxygen) {
            _spo2Value = data.value;
          }
        });
      },
      onBloodPressureMeasureCompleted: (data) {
        if (!mounted) {
          return;
        }
        setState(() {
          _bloodPressureSystolic = data.systolic;
          _bloodPressureDiastolic = data.diastolic;
        });
      },
    );
  }

  Future<void> _loadMockSleepSummary() async {
    final Map<String, dynamic> sleepSummary =
        await BrainWavesMockSleepService.loadSummary();

    if (!mounted) {
      return;
    }
    setState(() {
      _mockSleepSummary = <String, dynamic>{
        ...BrainWavesMockSleepService.defaultSummary,
        ...sleepSummary,
      };
    });
  }

  Future<void> _playBeep() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sound/beep.mp3'));
    } catch (_) {}
  }

  Future<void> _playFinishBeeps() async {
    for (int i = 0; i < 3; i++) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource('sound/beep.mp3'));
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (_) {}
    }
  }

  void _onWearingToggleChanged() {
    if (mounted) setState(() {});
  }

  void _onTouchChanged() {
    debugPrint(
      '[BrainWaves] _onTouchChanged: touch=${AppStateService.isTouchDetected}, '
      'phase=$_phase, detectionEnabled=${AppStateService.isWearingDetectionEnabled}, '
      'handled=$_headbandRemovedHandled',
    );
    if (!AppStateService.isWearingDetectionEnabled) return;
    if (mounted) setState(() {});
    final touching = AppStateService.isTouchDetected;
    if (touching == false &&
        _phase == _MeasurePhase.measuring &&
        !_headbandRemovedHandled) {
      _pauseForHeadbandRemoved();
    }
  }

  void _pauseForHeadbandRemoved() {
    _headbandRemovedHandled = true;
    unawaited(_smartRingMeasureService.cancelCombinedMeasurementSequence());
    _phaseTimer?.cancel();
    _chartTimer?.cancel();
    _signalResumeTimer?.cancel();
    setState(() {
      _phase = _MeasurePhase.idle;
      _alphaPoints.clear();
      _betaPoints.clear();
      _deltaPoints.clear();
      _heartRateValue = null;
      _spo2Value = null;
      _bloodPressureSystolic = null;
      _bloodPressureDiastolic = null;
      _ringMeasureState = SmartRingMeasureState.idle;
      _brainCaptureCompleted = false;
      _smartRingSequenceCompleted = false;
      _ringAbortHandled = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Băng đô đã được tháo ra. Vui lòng đeo lại và bắt đầu đo mới.',
            ),
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _abortCombinedMeasurementFromRing(String message) {
    final bool shouldAbort =
        _phase == _MeasurePhase.preparing || _phase == _MeasurePhase.measuring;
    if (!mounted || !shouldAbort || _ringAbortHandled) {
      return;
    }

    _ringAbortHandled = true;
    _phaseTimer?.cancel();
    _chartTimer?.cancel();
    _signalResumeTimer?.cancel();
    unawaited(
      _smartRingMeasureService.cancelCombinedMeasurementSequence(
        reason: message,
      ),
    );

    setState(() {
      _phase = _MeasurePhase.idle;
      _alphaPoints.clear();
      _betaPoints.clear();
      _deltaPoints.clear();
      _heartRateValue = null;
      _spo2Value = null;
      _bloodPressureSystolic = null;
      _bloodPressureDiastolic = null;
      _brainCaptureCompleted = false;
      _smartRingSequenceCompleted = false;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _startCombinedFlow() async {
    if (_isStartingCombined || _phase != _MeasurePhase.idle) {
      return;
    }

    if (!_isEspReady || !_isRingReady) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Cần kết nối đầy đủ ESP32 và Smart Ring trước khi bắt đầu đo.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
      return;
    }

    setState(() {
      _isStartingCombined = true;
      _heartRateValue = null;
      _spo2Value = null;
      _bloodPressureSystolic = null;
      _bloodPressureDiastolic = null;
      _ringMeasureState = SmartRingMeasureState.idle;
      _brainCaptureCompleted = false;
      _smartRingSequenceCompleted = false;
      _ringAbortHandled = false;
    });

    try {
      _startFlow();
    } finally {
      if (mounted) {
        setState(() {
          _isStartingCombined = false;
        });
      }
    }
  }

  Future<void> _runSmartRingMeasurement() async {
    try {
      final SmartRingCombinedMeasurementResult result =
          await _smartRingMeasureService.runCombinedMeasurementSequence();
      if (!mounted) {
        return;
      }

      setState(() {
        _heartRateValue = result.heartRate.value;
        _spo2Value = result.spo2.value;
        _bloodPressureSystolic = result.bloodPressure.systolic;
        _bloodPressureDiastolic = result.bloodPressure.diastolic;
        _ringMeasureState = SmartRingMeasureState.success;
        _smartRingSequenceCompleted = true;
      });
      _completeBrainCapture();
    } catch (error) {
      if (!mounted) {
        return;
      }

      final String message = error.toString();
      if (_ringAbortHandled || message.contains('Đã hủy phiên đo Smart Ring')) {
        return;
      }

      _reset();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Smart Ring đo thất bại: $message'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
    }
  }

  void _startFlow() {
    _headbandRemovedHandled = false;
    setState(() {
      _phase = _MeasurePhase.preparing;
      _prepCountdown = 5;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToPhaseSection();
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
    _brainCaptureCompleted = false;
    _ringAbortHandled = false;

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
      _ringMeasureState = SmartRingMeasureState.starting;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToPhaseSection();
    });

    _playBeep(); // beep at measurement start
    unawaited(_runSmartRingMeasurement());

    // Generate live EEG data every 500ms until Smart Ring finishes the sequence
    _chartTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // ── Weak-signal pause check ──
      if (_signalWeak) return; // paused, skip data generation

      _ticksSinceLastPause++;
      if (_ticksSinceLastPause >= _nextPauseTick) {
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
        // beep every 5 seconds during measurement
        if (_elapsedSeconds > 0 && _elapsedSeconds % 5 == 0) {
          _playBeep();
        }
      }
    });
  }

  void _completeBrainCapture() {
    _chartTimer?.cancel();
    _signalResumeTimer?.cancel();
    _signalWeak = false;
    _brainCaptureCompleted = true;
    if (mounted) {
      setState(() {});
    }
    _tryFinishMeasurement();
  }

  void _tryFinishMeasurement() {
    if (_phase == _MeasurePhase.result) {
      return;
    }

    if (!_brainCaptureCompleted || !_smartRingSequenceCompleted) {
      return;
    }

    _finishMeasurement();
  }

  void _finishMeasurement() {
    _playFinishBeeps(); // 3 quick beeps on completion
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

    // ── Smart Ring + sleep scores ─────────────────────────────────────────
    _smartRingScore = _deriveSmartRingInsights();
    _sleepScore = _deriveSleepRecoveryInsights();

    // ── Blend: EEG 45% + questionnaire 20% + sleep 15% + Smart Ring 20% ──
    double weightedTotal = _eegScore * 0.45 + _questionnaireScore * 0.2;
    double totalWeight = 0.65;
    if (_hasSleepSummary) {
      weightedTotal += _sleepScore * 0.15;
      totalWeight += 0.15;
    }
    if (_hasSmartRingVitals) {
      weightedTotal += _smartRingScore * 0.2;
      totalWeight += 0.2;
    }
    _overallScore = (weightedTotal / totalWeight).clamp(1.5, 9.5);
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

    _evaluationDetail = [
      _evaluationDetail,
      if (_sleepSummary.isNotEmpty) _sleepSummary,
      if (_sleepRecoveryInsight.isNotEmpty) _sleepRecoveryInsight,
      if (_smartRingSummary.isNotEmpty) _smartRingSummary,
      if (_vitalAlignmentInsight.isNotEmpty) _vitalAlignmentInsight,
    ].join(' ');

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

  double _deriveSmartRingInsights() {
    _smartRingSummary = '';
    _heartRateInsight = '';
    _spo2Insight = '';
    _bloodPressureInsight = '';
    _vitalAlignmentInsight = '';

    final List<double> scores = <double>[];
    final List<String> summaryParts = <String>[];

    final int? heartRate = _heartRateValue;
    if (heartRate != null) {
      double heartRateScore;
      if (heartRate >= 55 && heartRate <= 85) {
        heartRateScore = 9.0;
        _heartRateInsight =
            'Nhịp tim $heartRate bpm nằm trong vùng ổn định, cho thấy cơ thể đang đáp ứng khá êm trong suốt phiên đo.';
      } else if (heartRate >= 86 && heartRate <= 95) {
        heartRateScore = 7.3;
        _heartRateInsight =
            'Nhịp tim $heartRate bpm hơi cao hơn mức nghỉ lý tưởng, gợi ý cơ thể vẫn còn duy trì một mức kích hoạt nhẹ.';
      } else if (heartRate > 95) {
        heartRateScore = 5.0;
        _heartRateInsight =
            'Nhịp tim $heartRate bpm tăng rõ trong lúc đo, thường đi cùng trạng thái căng thẳng, bồn chồn hoặc chưa hồi phục hoàn toàn.';
      } else {
        heartRateScore = 6.5;
        _heartRateInsight =
            'Nhịp tim $heartRate bpm khá thấp, cần đọc cùng bối cảnh nghỉ ngơi và cảm giác cơ thể thực tế để diễn giải chính xác hơn.';
      }
      scores.add(heartRateScore);
      summaryParts.add('nhịp tim $heartRate bpm');
    }

    final int? spo2 = _spo2Value;
    if (spo2 != null) {
      double spo2Score;
      if (spo2 >= 97) {
        spo2Score = 9.4;
        _spo2Insight =
            'SpO2 $spo2% rất tốt, cho thấy tưới máu ngoại vi và tín hiệu cảm biến trong phiên đo tương đối ổn định.';
      } else if (spo2 >= 95) {
        spo2Score = 8.4;
        _spo2Insight =
            'SpO2 $spo2% vẫn nằm trong ngưỡng an toàn, nhưng chưa phải mức tối ưu nhất của trạng thái thư giãn sâu.';
      } else if (spo2 >= 93) {
        spo2Score = 6.0;
        _spo2Insight =
            'SpO2 $spo2% hơi thấp, có thể liên quan đến tín hiệu cảm biến chưa đẹp hoặc cơ thể chưa thật sự ổn định khi đo.';
      } else {
        spo2Score = 3.8;
        _spo2Insight =
            'SpO2 $spo2% thấp hơn kỳ vọng, nên ưu tiên kiểm tra lại vị trí đeo nhẫn và đọc kết quả cùng tình trạng thực tế của người đo.';
      }
      scores.add(spo2Score);
      summaryParts.add('SpO2 $spo2%');
    }

    final int? systolic = _bloodPressureSystolic;
    final int? diastolic = _bloodPressureDiastolic;
    if (systolic != null && diastolic != null) {
      double bloodPressureScore;
      if (systolic < 120 && diastolic < 80) {
        bloodPressureScore = 9.0;
        _bloodPressureInsight =
            'Huyết áp $systolic/$diastolic mmHg nằm trong vùng đẹp, phù hợp với một phiên đo có mức hoạt hóa cơ thể thấp.';
      } else if (systolic < 130 && diastolic < 80) {
        bloodPressureScore = 7.4;
        _bloodPressureInsight =
            'Huyết áp $systolic/$diastolic mmHg hơi nhích lên nhưng vẫn còn tương đối ổn, thường gặp khi cơ thể chưa thả lỏng hoàn toàn.';
      } else if (systolic < 140 && diastolic < 90) {
        bloodPressureScore = 5.6;
        _bloodPressureInsight =
            'Huyết áp $systolic/$diastolic mmHg cho thấy hệ thần kinh giao cảm vẫn đang hoạt động ở mức vừa, nên kết quả thư giãn cần đọc thận trọng hơn.';
      } else {
        bloodPressureScore = 3.9;
        _bloodPressureInsight =
            'Huyết áp $systolic/$diastolic mmHg còn khá cao trong phiên đo, gợi ý cơ thể vẫn chịu tải stress sinh lý đáng kể.';
      }
      scores.add(bloodPressureScore);
      summaryParts.add('huyết áp $systolic/$diastolic mmHg');
    }

    if (summaryParts.isNotEmpty) {
      _smartRingSummary =
          'Trong phiên đo này, Smart Ring ghi nhận ${summaryParts.join(', ')} để đối chiếu thêm với tín hiệu EEG.';
    }

    final bool eegLooksRelaxed = _eegScore >= 7.0;
    final bool eegLooksStressed = _eegScore < 6.0;
    final bool vitalsElevated =
        (heartRate != null && heartRate > 95) ||
        (spo2 != null && spo2 < 95) ||
        (systolic != null && systolic >= 130) ||
        (diastolic != null && diastolic >= 85);
    final bool vitalsStable =
        (heartRate == null || (heartRate >= 55 && heartRate <= 85)) &&
        (spo2 == null || spo2 >= 95) &&
        ((systolic == null || diastolic == null) ||
            (systolic < 130 && diastolic < 85));

    if (eegLooksRelaxed && vitalsElevated) {
      _vitalAlignmentInsight =
          'Điểm cần lưu ý là EEG nghiêng về thư giãn, nhưng Smart Ring vẫn ghi nhận cơ thể chưa hạ tải hoàn toàn. Điều này thường xảy ra khi tâm trí đã dịu hơn nhưng phản ứng sinh lý cần thêm thời gian để ổn định.';
    } else if (eegLooksStressed && vitalsStable) {
      _vitalAlignmentInsight =
          'EEG cho thấy xu hướng căng thẳng nhận thức, trong khi Smart Ring vẫn khá ổn định. Điều này gợi ý tải stress đang thiên về mặt tinh thần hơn là phản ứng sinh lý toàn thân.';
    } else if (eegLooksRelaxed && vitalsStable) {
      _vitalAlignmentInsight =
          'EEG và Smart Ring đồng thuận khá tốt: cả hoạt động sóng não lẫn các chỉ số sinh tồn đều ủng hộ trạng thái cân bằng và thư giãn.';
    } else if (vitalsElevated) {
      _vitalAlignmentInsight =
          'Cả sóng não và tín hiệu Smart Ring đều cho thấy cơ thể còn hoạt hóa đáng kể, vì vậy phần kết luận được nghiêng nhiều hơn về phía cần phục hồi thêm.';
    }

    if (scores.isEmpty) {
      return 5.5;
    }
    final double score = scores.reduce((a, b) => a + b) / scores.length;
    return score.clamp(1.0, 10.0);
  }

  double _deriveSleepRecoveryInsights() {
    _sleepSummary = '';
    _sleepRecoveryInsight = '';

    if (!_hasSleepSummary) {
      return 5.5;
    }

    final int totalMinutes = (_mockSleepSummary['totalTime'] as num? ?? 0)
        .round();
    final int score100 = (_mockSleepSummary['score'] as num? ?? 0).round();
    final int deepSleep = (_mockSleepSummary['deepSleep'] as num? ?? 0).round();
    final int remSleep = (_mockSleepSummary['remSleep'] as num? ?? 0).round();
    final int awakeCount = (_mockSleepSummary['awakeCount'] as num? ?? 0)
        .round();
    final String quality =
        _mockSleepSummary['quality'] as String? ?? 'Chưa đủ dữ liệu';

    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;

    _sleepSummary =
        'Giấc ngủ đêm qua đạt $hours giờ ${minutes.toString().padLeft(2, '0')} phút, '
        'chất lượng $quality với $deepSleep phút ngủ sâu và $remSleep phút REM.';

    if (totalMinutes >= 420 &&
        totalMinutes <= 540 &&
        deepSleep >= 100 &&
        remSleep >= 70) {
      _sleepRecoveryInsight =
          'Nền phục hồi qua đêm khá tốt, nên não bộ và cơ thể có điểm tựa ổn hơn khi bước vào phiên đo sáng nay.';
    } else if (totalMinutes >= 390 && deepSleep >= 85) {
      _sleepRecoveryInsight =
          'Giấc ngủ ở mức chấp nhận được, nhưng độ sâu phục hồi vẫn chưa thật sự tối ưu nên kết luận thư giãn cần đọc ở mức vừa phải.';
    } else {
      _sleepRecoveryInsight =
          'Giấc ngủ chưa thật sự đầy đặn hoặc còn phân mảnh, nên kết quả sóng não và sinh hiệu hôm nay có thể chịu ảnh hưởng bởi thiếu phục hồi qua đêm.';
    }

    if (awakeCount >= 2) {
      _sleepRecoveryInsight =
          'Giấc ngủ có dấu hiệu bị ngắt quãng $awakeCount lần, vì vậy mức hồi phục thần kinh tự chủ có thể chưa trọn vẹn.';
    }

    return (score100 / 10).clamp(1.0, 10.0);
  }

  void _reset() {
    unawaited(_smartRingMeasureService.cancelCombinedMeasurementSequence());
    _phaseTimer?.cancel();
    _chartTimer?.cancel();
    _signalResumeTimer?.cancel();
    _musicPlayer.stop();
    setState(() {
      _phase = _MeasurePhase.idle;
      _playingTrack = null;
      _alphaPoints.clear();
      _betaPoints.clear();
      _deltaPoints.clear();
      _heartRateValue = null;
      _spo2Value = null;
      _bloodPressureSystolic = null;
      _bloodPressureDiastolic = null;
      _ringMeasureState = SmartRingMeasureState.idle;
      _brainCaptureCompleted = false;
      _smartRingSequenceCompleted = false;
      _ringAbortHandled = false;
      _smartRingScore = 0;
      _sleepScore = 0;
      _evaluation = '';
      _evaluationDetail = '';
      _sleepInsight = '';
      _focusInsight = '';
      _tensionInsight = '';
      _copingInsight = '';
      _smartRingSummary = '';
      _sleepSummary = '';
      _sleepRecoveryInsight = '';
      _heartRateInsight = '';
      _spo2Insight = '';
      _bloodPressureInsight = '';
      _vitalAlignmentInsight = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final String deviceName =
        AppStateService.connectedDeviceName ?? 'ESP32S3_TOUCH';
    final String ringName =
        _smartRingConnectionService.connectedDeviceNotifier.value?.name ??
        'Smart Ring';

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
              // ── Connected devices ──
              _buildDeviceCards(deviceName: deviceName, ringName: ringName),
              const SizedBox(height: 12),
              // ── Wearing status ──
              if (AppStateService.isWearingDetectionEnabled)
                _buildWearingStatus(),
              const SizedBox(height: 20),
              Container(
                key: _phaseSectionKey,
                child: Column(
                  children: [
                    if (_phase == _MeasurePhase.idle) _buildIdle(),
                    if (_phase == _MeasurePhase.preparing) _buildPreparing(),
                    if (_phase == _MeasurePhase.measuring) _buildMeasuring(),
                    if (_phase == _MeasurePhase.result) _buildResult(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Wearing status ────────────────────────────────────────────────────────

  Widget _buildWearingStatus() {
    final wearing = AppStateService.isTouchDetected == true;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: wearing ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: wearing ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
        ),
      ),
      child: Row(
        children: [
          Icon(
            wearing ? Icons.check_circle : Icons.warning_amber_rounded,
            color: wearing ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            wearing ? 'Đang đeo băng đô' : 'Chưa đeo băng đô',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: wearing
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFE65100),
            ),
          ),
        ],
      ),
    );
  }

  // ── Device card ──────────────────────────────────────────────────────────

  Widget _buildDeviceCards({
    required String deviceName,
    required String ringName,
  }) {
    final bool disableDisconnect = _phase == _MeasurePhase.measuring;
    final bool bothReady = _isEspReady && _isRingReady;
    final int readyCount = (_isEspReady ? 1 : 0) + (_isRingReady ? 1 : 0);

    if (bothReady) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFDDECEF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF18ADC3), Color(0xFF0F8FA4)],
                    ),
                  ),
                  child: const Icon(
                    Icons.sensors_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Thiết bị cho phiên đo',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF8F1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$readyCount/2 sẵn sàng',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildConnectedDevicePill(
                    title: 'ESP32',
                    name: deviceName,
                    detail: 'EEG headband',
                    accent: const Color(0xFF129EAF),
                    icon: Icons.memory_rounded,
                    onDisconnect: disableDisconnect
                        ? null
                        : () async {
                            _reset();
                            await BleService.instance.disconnect();
                          },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildConnectedDevicePill(
                    title: 'Smart Ring',
                    name: ringName,
                    detail: 'HR • SpO2 • BP',
                    accent: const Color(0xFF18ADC3),
                    icon: Icons.favorite_rounded,
                    onDisconnect: disableDisconnect
                        ? null
                        : () async {
                            _reset();
                            await _smartRingConnectionService
                                .disconnectDevice();
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF129EAF).withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.devices_rounded,
                  color: Color(0xFF129EAF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thiết bị cho phiên đo',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'ESP32 cho EEG, Smart Ring cho nhịp tim, SpO2 và huyết áp.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: readyCount == 2
                      ? const Color(0xFFEFF8F1)
                      : const Color(0xFFF4F7F8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$readyCount/2 sẵn sàng',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: readyCount == 2
                        ? const Color(0xFF2E7D32)
                        : AppColors.neutral600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildCompactConnectedDeviceRow(
            title: 'ESP32',
            name: deviceName,
            detail: 'Headband EEG',
            accent: const Color(0xFF129EAF),
            icon: Icons.memory_rounded,
            onDisconnect: disableDisconnect
                ? null
                : () async {
                    _reset();
                    await BleService.instance.disconnect();
                  },
          ),
          const SizedBox(height: 10),
          _buildCompactConnectedDeviceRow(
            title: 'Smart Ring',
            name: ringName,
            detail: 'HR • SpO2 • BP',
            accent: const Color(0xFF18ADC3),
            icon: Icons.health_and_safety_rounded,
            onDisconnect: disableDisconnect
                ? null
                : () async {
                    _reset();
                    await _smartRingConnectionService.disconnectDevice();
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedDevicePill({
    required String title,
    required String name,
    required String detail,
    required Color accent,
    required IconData icon,
    required Future<void> Function()? onDisconnect,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.08), Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: accent.withValues(alpha: 0.13),
            ),
            child: Icon(icon, color: accent, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 26,
            height: 26,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: onDisconnect == null
                  ? null
                  : () async {
                      await onDisconnect();
                    },
              tooltip: 'Ngắt kết nối $title',
              style: IconButton.styleFrom(
                backgroundColor: onDisconnect == null
                    ? const Color(0xFFF3F4F6)
                    : const Color(0xFFFFF1F2),
                foregroundColor: onDisconnect == null
                    ? AppColors.neutral400
                    : AppColors.red600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.link_off_rounded, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactConnectedDeviceRow({
    required String title,
    required String name,
    required String detail,
    required Color accent,
    required IconData icon,
    required Future<void> Function()? onDisconnect,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: accent.withValues(alpha: 0.12),
            ),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, color: accent, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34A853),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              onPressed: onDisconnect == null
                  ? null
                  : () async {
                      await onDisconnect();
                    },
              tooltip: 'Ngắt kết nối $title',
              style: IconButton.styleFrom(
                backgroundColor: onDisconnect == null
                    ? const Color(0xFFF3F4F6)
                    : const Color(0xFFFFF1F2),
                foregroundColor: onDisconnect == null
                    ? AppColors.neutral400
                    : AppColors.red600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.link_off_rounded, size: 20),
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
          'ESP32 và Smart Ring đã sẵn sàng.\nPhiên đo sẽ tự chốt khi Smart Ring hoàn tất chuỗi nhịp tim, SpO2 và huyết áp.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.neutral600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        _buildMockSleepSection(),
        const SizedBox(height: 28),
        _buildPrimaryButton(
          label: 'Bắt đầu đo',
          icon: Icons.waves,
          onPressed: _canStartMeasurement ? _startCombinedFlow : null,
        ),
        if (!_isWearing && AppStateService.isWearingDetectionEnabled)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Vui lòng đeo băng đô trước khi đo.',
              style: TextStyle(fontSize: 13, color: Color(0xFFE65100)),
            ),
          ),
      ],
    );
  }

  Widget _buildMockSleepSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFAFBFF)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.10),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 12,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: _buildMockSleepSummaryCard(_mockSleepSummary),
    );
  }

  Widget _buildSleepResultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F5FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE3E0FF)),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bedtime_rounded,
                  size: 17,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giấc ngủ trong phần kết luận',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Được dùng như nền phục hồi để đối chiếu với EEG và Smart Ring.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.neutral600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_sleepScore.toStringAsFixed(1)}/10',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildMockSleepSection(),
      ],
    );
  }

  Widget _buildMockSleepSummaryCard(Map<String, dynamic> sleepData) {
    final int totalTime = (sleepData['totalTime'] as num? ?? 0).round();
    final int totalHours = totalTime ~/ 60;
    final int totalMinutes = totalTime % 60;
    final int score = (sleepData['score'] as num? ?? 0).round();
    final String quality = sleepData['quality'] as String? ?? 'Chưa đủ dữ liệu';
    final List<Color> qualityColors = _mockSleepQualityColors(quality);

    return Column(
      children: [
        _buildMockSleepHeader(
          hasRealtimeData: sleepData['hasRealData'] == true,
        ),
        const SizedBox(height: 16),
        _buildMockSleepTimeInfo(
          totalHours: totalHours,
          totalMinutes: totalMinutes,
          score: score,
          quality: quality,
          qualityColors: qualityColors,
        ),
        const SizedBox(height: 12),
        _buildMockSleepTimingInfo(sleepData),
        const SizedBox(height: 16),
        _buildMockSleepStagesInfo(sleepData),
      ],
    );
  }

  Widget _buildMockSleepHeader({bool hasRealtimeData = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(Icons.bedtime, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giấc ngủ đêm qua',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasRealtimeData)
                      Text(
                        'Dữ liệu thời gian thực',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF10B981).withValues(alpha: 0.8),
                          letterSpacing: 0.1,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                const Color(0xFF6366F1).withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
              width: 0.8,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chi tiết',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B5CF6),
                  letterSpacing: 0.1,
                ),
              ),
              SizedBox(width: 3),
              Icon(Icons.chevron_right, color: Color(0xFF8B5CF6), size: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMockSleepTimeInfo({
    required int totalHours,
    required int totalMinutes,
    required int score,
    required String quality,
    required List<Color> qualityColors,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$totalHours giờ ${totalMinutes.toString().padLeft(2, '0')} phút',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Điểm: $score/100',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B).withValues(alpha: 0.8),
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: qualityColors,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: qualityColors.first.withValues(alpha: 0.25),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 12, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                quality,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMockSleepTimingInfo(Map<String, dynamic> sleepData) {
    final int sessionsCount = (sleepData['sessionsCount'] as num? ?? 1).round();
    final int awakeCount = (sleepData['awakeCount'] as num? ?? 0).round();

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                        ),
                      ),
                      child: const Icon(
                        Icons.bedtime,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Giờ đi ngủ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sleepData['startTime'] as String? ?? '--:--',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFE2E8F0).withValues(alpha: 0.3),
                      const Color(0xFFE2E8F0),
                      const Color(0xFFE2E8F0).withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFB7185), Color(0xFFEC4899)],
                        ),
                      ),
                      child: const Icon(
                        Icons.wb_sunny,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Giờ thức dậy',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sleepData['endTime'] as String? ?? '--:--',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (sessionsCount > 1 || awakeCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFEF3C7), Color(0xFFFEF9E7)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      size: 12,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sessionsCount > 1
                          ? 'Có $sessionsCount đợt ngủ, đã thức dậy $awakeCount lần'
                          : 'Đã thức dậy $awakeCount lần trong đêm',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF59E0B),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMockSleepStagesInfo(Map<String, dynamic> sleepData) {
    final int lightSleep = (sleepData['lightSleep'] as num? ?? 1).round().clamp(
      1,
      10000,
    );
    final int deepSleep = (sleepData['deepSleep'] as num? ?? 1).round().clamp(
      1,
      10000,
    );
    final int remSleep = (sleepData['remSleep'] as num? ?? 1).round().clamp(
      1,
      10000,
    );
    final int awakeFlex = ((sleepData['awakeCount'] as num? ?? 1).round() * 5)
        .clamp(1, 10000);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Các giai đoạn giấc ngủ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                offset: const Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: lightSleep,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF34D399), Color(0xFF10B981)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(5),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: deepSleep,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: remSleep,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: awakeFlex,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFAFBFF), Color(0xFFF8FAFC)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
          ),
          padding: const EdgeInsets.all(10),
          child: const Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _SleepLegendItem(
                gradient: LinearGradient(
                  colors: [Color(0xFF34D399), Color(0xFF10B981)],
                ),
                label: 'Ngủ nhẹ',
              ),
              _SleepLegendItem(
                gradient: LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                ),
                label: 'Ngủ sâu',
              ),
              _SleepLegendItem(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                ),
                label: 'REM',
              ),
              _SleepLegendItem(
                gradient: LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                ),
                label: 'Thức',
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Color> _mockSleepQualityColors(String quality) {
    switch (quality) {
      case 'Giấc ngủ tốt':
        return const [Color(0xFF10B981), Color(0xFF059669)];
      case 'Giấc ngủ trung bình':
        return const [Color(0xFF3B82F6), Color(0xFF1D4ED8)];
      case 'Giấc ngủ kém':
        return const [Color(0xFFF59E0B), Color(0xFFEF4444)];
      default:
        return const [Color(0xFF6B7280), Color(0xFF4B5563)];
    }
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

  Future<void> _scrollToPhaseSection() async {
    final BuildContext? context = _phaseSectionKey.currentContext;
    if (context == null) {
      return;
    }
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      alignment: 0.04,
    );
  }

  String get _elapsedDurationLabel {
    final int minutes = _elapsedSeconds ~/ 60;
    final int seconds = _elapsedSeconds % 60;
    final String mm = minutes.toString().padLeft(2, '0');
    final String ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  double get _measurementFlowProgress {
    final SmartRingMeasureType? activeType = _activeRingMeasureType;
    switch (_ringMeasureState) {
      case SmartRingMeasureState.starting:
        return 0.08;
      case SmartRingMeasureState.measuring:
        if (activeType == SmartRingMeasureType.heartRate) {
          return _heartRateValue == null ? 0.18 : 0.32;
        }
        if (activeType == SmartRingMeasureType.bloodOxygen) {
          return _spo2Value == null ? 0.44 : 0.62;
        }
        if (activeType == SmartRingMeasureType.bloodPressure) {
          return (_bloodPressureSystolic == null ||
                  _bloodPressureDiastolic == null)
              ? 0.76
              : 0.98;
        }
        return 0.2;
      case SmartRingMeasureState.stopping:
        return 0.9;
      case SmartRingMeasureState.success:
        return 1.0;
      case SmartRingMeasureState.error:
      case SmartRingMeasureState.deviceDisconnected:
      case SmartRingMeasureState.idle:
        return _smartRingSequenceCompleted ? 1.0 : 0.04;
    }
  }

  // ── Phase: Measuring ─────────────────────────────────────────────────────

  Widget _buildMeasuring() {
    final double progress = _measurementFlowProgress;

    return Column(
      children: [
        const SizedBox(height: 8),
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
                '$_elapsedDurationLabel đã đo',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF129EAF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildMeasurementSurface(progress: progress),
        const SizedBox(height: 20),
        Text(
          _signalWeak
              ? 'Đang khôi phục kết nối...'
              : 'Vui lòng giữ yên. EEG sẽ tiếp tục ghi nhận cho đến khi Smart Ring hoàn tất bước huyết áp.',
          style: TextStyle(fontSize: 14, color: AppColors.neutral600),
          textAlign: TextAlign.center,
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
        _buildVitalsPanel(isLive: false),
        const SizedBox(height: 16),
        if (_hasSleepSummary) _buildSleepResultSection(),
        if (_hasSleepSummary) const SizedBox(height: 16),
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
              const Text(
                'Tổng hợp từ EEG, Smart Ring, giấc ngủ đêm qua và khảo sát nền ban đầu.',
                style: TextStyle(fontSize: 12, color: AppColors.neutral600),
              ),
              const SizedBox(height: 8),
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
                  _buildMiniStat('Thời gian đo', _elapsedDurationLabel),
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
                      '45%',
                      const Color(0xFF129EAF),
                    ),
                    const SizedBox(height: 4),
                    _scoreBreakdownRow(
                      'Khảo sát 10 câu hỏi',
                      _questionnaireScore,
                      '20%',
                      const Color(0xFF7C4DFF),
                    ),
                    const SizedBox(height: 4),
                    _scoreBreakdownRow(
                      'Giấc ngủ đêm qua',
                      _sleepScore,
                      '15%',
                      const Color(0xFF6366F1),
                    ),
                    const SizedBox(height: 4),
                    _scoreBreakdownRow(
                      'Smart Ring',
                      _smartRingScore,
                      '20%',
                      const Color(0xFF18ADC3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_hasSmartRingInsights) _buildSmartRingInsightsCard(),
        if (_hasSmartRingInsights) const SizedBox(height: 16),
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
        // ── Re-measure CTA ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF129EAF), Color(0xFF0E7B8A)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x30129EAF),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Đã thực hành bài tập?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Đo lại để xem tình trạng có cải thiện không',
                style: TextStyle(fontSize: 13, color: Color(0xCCFFFFFF)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.replay, size: 20),
                  label: const Text(
                    'Đo lại sóng não',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF129EAF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // ── Shared widgets ───────────────────────────────────────────────────────

  Widget _buildMeasurementSurface({required double progress}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF9FEFF), Color(0xFFF2FBFD)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD7EEF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14089BB0),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF18ADC3), Color(0xFF0F8FA4)],
                  ),
                ),
                child: const Icon(
                  Icons.multiline_chart_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bề mặt đo đồng bộ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'EEG và Smart Ring hiển thị trong cùng một nhịp theo dõi.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildSurfaceStatusBadge(),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFFD9E8EC),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF129EAF),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE3F1F4)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F8FB),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'EEG live',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F8FA4),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _elapsedDurationLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _InteractiveWaveChart(
                  alpha: _alphaPoints,
                  beta: _betaPoints,
                  delta: _deltaPoints,
                  height: 220,
                  pointsPerScreen: 40,
                  autoScrollToEnd: true,
                ),
                if (_signalWeak) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFCC80)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.signal_cellular_connected_no_internet_0_bar,
                          size: 18,
                          color: Color(0xFFEF6C00),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tín hiệu yếu — vui lòng ngồi yên...',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _buildLegend(),
                const SizedBox(height: 14),
                _buildLiveSmartRingStrip(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurfaceStatusBadge() {
    final bool active =
        _ringMeasureState == SmartRingMeasureState.starting ||
        _ringMeasureState == SmartRingMeasureState.measuring ||
        _ringMeasureState == SmartRingMeasureState.stopping;

    final Color bg = active ? const Color(0xFFE8F8FB) : const Color(0xFFEFF8F1);
    final Color fg = active ? const Color(0xFF0F8FA4) : const Color(0xFF2E7D32);

    final String label = active ? 'Smart Ring đang đo' : 'Đồng bộ ổn định';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  Widget _buildLiveSmartRingStrip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.favorite_rounded,
                size: 18,
                color: Color(0xFF18ADC3),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Smart Ring đồng bộ theo từng bước đo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutral900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _ringStatusText(isLive: true),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.neutral600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildLiveMetricCard(
                  type: SmartRingMeasureType.heartRate,
                  title: 'Nhịp tim',
                  value: _heartRateValue == null ? '--' : '${_heartRateValue!}',
                  unit: 'bpm',
                  accent: const Color(0xFFE8575A),
                  icon: Icons.favorite_outline_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildLiveMetricCard(
                  type: SmartRingMeasureType.bloodOxygen,
                  title: 'SpO2',
                  value: _spo2Value == null ? '--' : '${_spo2Value!}',
                  unit: '%',
                  accent: const Color(0xFF129EAF),
                  icon: Icons.air_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLiveMetricCard(
                  type: SmartRingMeasureType.bloodPressure,
                  title: 'Huyết áp',
                  value: _bloodPressureLabel,
                  unit: 'mmHg',
                  accent: const Color(0xFF8E59FF),
                  icon: Icons.monitor_heart_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMetricCard({
    required SmartRingMeasureType type,
    required String title,
    required String value,
    required String unit,
    required Color accent,
    required IconData icon,
  }) {
    final bool active = _isRingMetricActive(type);
    final bool ready = _isRingMetricReady(type);
    final String status = _ringMetricStatusLabel(type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: active
            ? accent.withValues(alpha: 0.10)
            : ready
            ? Colors.white
            : const Color(0xFFFCFDFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active
              ? accent.withValues(alpha: 0.55)
              : ready
              ? accent.withValues(alpha: 0.22)
              : const Color(0xFFE1E9EC),
          width: active ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: active ? 0.14 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: accent),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: AppColors.neutral900,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            decoration: BoxDecoration(
              color: active
                  ? accent.withValues(alpha: 0.12)
                  : ready
                  ? accent.withValues(alpha: 0.08)
                  : const Color(0xFFF3F6F7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: active || ready ? accent : AppColors.neutral600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isRingMetricActive(SmartRingMeasureType type) {
    final bool isBusy =
        _ringMeasureState == SmartRingMeasureState.starting ||
        _ringMeasureState == SmartRingMeasureState.measuring ||
        _ringMeasureState == SmartRingMeasureState.stopping;
    return isBusy && _activeRingMeasureType == type;
  }

  bool _isRingMetricReady(SmartRingMeasureType type) {
    switch (type) {
      case SmartRingMeasureType.heartRate:
        return _heartRateValue != null;
      case SmartRingMeasureType.bloodPressure:
        return _bloodPressureSystolic != null &&
            _bloodPressureDiastolic != null;
      case SmartRingMeasureType.bloodOxygen:
        return _spo2Value != null;
    }
  }

  int _ringMetricOrder(SmartRingMeasureType type) {
    switch (type) {
      case SmartRingMeasureType.heartRate:
        return 0;
      case SmartRingMeasureType.bloodOxygen:
        return 1;
      case SmartRingMeasureType.bloodPressure:
        return 2;
    }
  }

  String _ringMetricStatusLabel(SmartRingMeasureType type) {
    if (_isRingMetricActive(type)) {
      switch (_ringMeasureState) {
        case SmartRingMeasureState.starting:
          return 'Chuẩn bị';
        case SmartRingMeasureState.stopping:
          return 'Đang chốt';
        case SmartRingMeasureState.measuring:
          return 'Đang đo';
        default:
          break;
      }
    }

    if (_ringMeasureState == SmartRingMeasureState.success &&
        _isRingMetricReady(type)) {
      return 'Hoàn tất';
    }

    if (_isRingMetricReady(type)) {
      return 'Đã lấy';
    }

    final SmartRingMeasureType? activeType = _activeRingMeasureType;
    if (activeType != null &&
        _ringMetricOrder(type) > _ringMetricOrder(activeType)) {
      return 'Chờ lượt';
    }

    return 'Đang chờ';
  }

  String _ringMetricDisplayName(SmartRingMeasureType type) {
    switch (type) {
      case SmartRingMeasureType.heartRate:
        return 'nhịp tim';
      case SmartRingMeasureType.bloodPressure:
        return 'huyết áp';
      case SmartRingMeasureType.bloodOxygen:
        return 'SpO2';
    }
  }

  Widget _buildVitalsPanel({required bool isLive}) {
    if (!isLive) {
      return _buildResultVitalsPanel();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLive
              ? const [Color(0xFFFFFFFF), Color(0xFFF9FCFD)]
              : const [Color(0xFFF9FDFF), Color(0xFFF2FBFD)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLive ? const Color(0xFFEAEAEA) : const Color(0xFFDCECF0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF18ADC3).withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 18,
                  color: Color(0xFF18ADC3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLive
                          ? 'Chỉ số Smart Ring khi đo'
                          : 'Kết quả Smart Ring',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _ringStatusText(isLive: isLive),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: isLive
                      ? const Color(0xFFE8F8FB)
                      : const Color(0xFFEFF8F1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isLive ? 'Live sync' : 'Đã chốt',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isLive
                        ? const Color(0xFF0F8FA4)
                        : const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildVitalStatCard(
                  title: 'Nhịp tim',
                  value: _heartRateValue == null ? '--' : '${_heartRateValue!}',
                  unit: 'bpm',
                  accent: const Color(0xFFE8575A),
                  icon: Icons.favorite_outline_rounded,
                  ready: _heartRateValue != null,
                  emphasize: !isLive,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildVitalStatCard(
                  title: 'SpO2',
                  value: _spo2Value == null ? '--' : '${_spo2Value!}',
                  unit: '%',
                  accent: const Color(0xFF129EAF),
                  icon: Icons.air_rounded,
                  ready: _spo2Value != null,
                  emphasize: !isLive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildVitalStatCard(
            title: 'Huyết áp',
            value: _bloodPressureLabel,
            unit: 'mmHg',
            accent: const Color(0xFF8E59FF),
            icon: Icons.monitor_heart_outlined,
            ready:
                _bloodPressureSystolic != null &&
                _bloodPressureDiastolic != null,
            fullWidth: true,
            emphasize: !isLive,
          ),
        ],
      ),
    );
  }

  Widget _buildResultVitalsPanel() {
    final Color accent = _smartRingResultAccent;
    final Color badgeColor = _smartRingResultBadgeColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFEFE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE8EC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120E2A32),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.favorite_rounded, size: 20, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tóm tắt Smart Ring',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Đọc phản ứng cơ thể từ nhịp tim, SpO2 và huyết áp trong cùng phiên EEG.',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.neutral600,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _smartRingResultBadgeLabel,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nhận xét chung',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accent,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _smartRingResultHeadline,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutral900,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _smartRingResultComment,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.neutral700,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildResultVitalTile(
                  title: 'Nhịp tim',
                  value: _heartRateValue == null ? '--' : '${_heartRateValue!}',
                  unit: 'bpm',
                  accent: const Color(0xFFE8575A),
                  icon: Icons.favorite_outline_rounded,
                  ready: _heartRateValue != null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildResultVitalTile(
                  title: 'SpO2',
                  value: _spo2Value == null ? '--' : '${_spo2Value!}',
                  unit: '%',
                  accent: const Color(0xFF129EAF),
                  icon: Icons.air_rounded,
                  ready: _spo2Value != null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildResultVitalTile(
                  title: 'Huyết áp',
                  value: _bloodPressureLabel,
                  unit: 'mmHg',
                  accent: const Color(0xFF5D7CF6),
                  icon: Icons.monitor_heart_outlined,
                  ready:
                      _bloodPressureSystolic != null &&
                      _bloodPressureDiastolic != null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalStatCard({
    required String title,
    required String value,
    required String unit,
    required Color accent,
    required IconData icon,
    required bool ready,
    bool fullWidth = false,
    bool emphasize = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.all(emphasize ? 14 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: emphasize ? 0.12 : 0.08),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(emphasize ? 16 : 14),
        border: Border.all(
          color: accent.withValues(alpha: emphasize ? 0.2 : 0.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: emphasize ? 40 : 36,
            height: emphasize ? 40 : 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: emphasize ? 20 : 18, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral700,
                  ),
                ),
                const SizedBox(height: 3),
                RichText(
                  text: TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: emphasize ? 20 : 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutral900,
                    ),
                    children: [
                      TextSpan(
                        text: ' $unit',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: ready ? Colors.white : accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              ready ? 'Đã có' : 'Đang chờ',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: ready ? accent : AppColors.neutral600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultVitalTile({
    required String title,
    required String value,
    required String unit,
    required Color accent,
    required IconData icon,
    required bool ready,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 11, 11, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2EAEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 15, color: accent),
              ),
              const Spacer(),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: ready ? accent : const Color(0xFFC9D4D8),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral700,
            ),
          ),
          const SizedBox(height: 5),
          RichText(
            text: TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ready ? 'Đã ghi nhận' : 'Chưa có dữ liệu',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: ready ? accent : AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  String get _bloodPressureLabel {
    if (_bloodPressureSystolic == null || _bloodPressureDiastolic == null) {
      return '--/--';
    }
    return '${_bloodPressureSystolic!}/${_bloodPressureDiastolic!}';
  }

  String get _smartRingResultHeadline {
    if (!_hasSmartRingVitals) {
      return 'Chưa đủ dữ liệu Smart Ring để đưa ra nhận xét.';
    }
    if (_smartRingScore >= 8.4) {
      return 'Sinh hiệu ổn định, khá phù hợp với một trạng thái thư giãn tốt.';
    }
    if (_smartRingScore >= 6.8) {
      return 'Sinh hiệu tương đối cân bằng, nhưng cơ thể vẫn còn hoạt hóa nhẹ.';
    }
    if (_smartRingScore >= 5.2) {
      return 'Cơ thể chưa hạ tải hoàn toàn, nên đọc kết quả thư giãn ở mức thận trọng.';
    }
    return 'Cơ thể còn căng sinh lý khá rõ, nên ưu tiên phục hồi thêm sau phiên đo.';
  }

  String get _smartRingResultComment {
    final List<String> parts = <String>[];
    if (_smartRingSummary.isNotEmpty) {
      parts.add(_smartRingSummary);
    }
    if (_vitalAlignmentInsight.isNotEmpty) {
      parts.add(_vitalAlignmentInsight);
    }
    if (parts.isEmpty) {
      return 'Smart Ring giúp bổ sung góc nhìn sinh lý để kết quả cuối không chỉ dựa vào sóng não, mà còn phản ánh cách cơ thể phản ứng trong suốt phiên đo.';
    }
    return parts.join(' ');
  }

  String get _smartRingResultBadgeLabel {
    if (!_hasSmartRingVitals) {
      return 'Thiếu dữ liệu';
    }
    if (_smartRingScore >= 8.4) {
      return 'Ổn định';
    }
    if (_smartRingScore >= 6.8) {
      return 'Khá cân bằng';
    }
    if (_smartRingScore >= 5.2) {
      return 'Cần lưu ý';
    }
    return 'Hoạt hóa cao';
  }

  Color get _smartRingResultBadgeColor {
    if (!_hasSmartRingVitals) {
      return const Color(0xFF78909C);
    }
    if (_smartRingScore >= 8.4) {
      return const Color(0xFF2E7D32);
    }
    if (_smartRingScore >= 6.8) {
      return const Color(0xFF00838F);
    }
    if (_smartRingScore >= 5.2) {
      return const Color(0xFFF57C00);
    }
    return const Color(0xFFC62828);
  }

  Color get _smartRingResultAccent {
    if (!_hasSmartRingVitals) {
      return const Color(0xFF78909C);
    }
    if (_smartRingScore >= 8.4) {
      return const Color(0xFF1F8A70);
    }
    if (_smartRingScore >= 6.8) {
      return const Color(0xFF129EAF);
    }
    if (_smartRingScore >= 5.2) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFFE8575A);
  }

  bool get _hasSmartRingVitals =>
      _heartRateValue != null ||
      _spo2Value != null ||
      (_bloodPressureSystolic != null && _bloodPressureDiastolic != null);

  bool get _hasSleepSummary => _mockSleepSummary.isNotEmpty;

  bool get _hasSmartRingInsights =>
      _heartRateInsight.isNotEmpty ||
      _spo2Insight.isNotEmpty ||
      _bloodPressureInsight.isNotEmpty ||
      _vitalAlignmentInsight.isNotEmpty;

  String _ringStatusText({required bool isLive}) {
    final SmartRingMeasureType? activeType = _activeRingMeasureType;
    switch (_ringMeasureState) {
      case SmartRingMeasureState.starting:
        return activeType == null
            ? 'Đang khởi tạo chuỗi đo nhịp tim, SpO2 và huyết áp.'
            : 'Đang chuẩn bị đo ${_ringMetricDisplayName(activeType)} bằng Smart Ring.';
      case SmartRingMeasureState.measuring:
        return isLive
            ? activeType == null
                  ? 'Smart Ring đang cập nhật chỉ số sinh tồn theo thời gian thực.'
                  : 'Smart Ring đang đo ${_ringMetricDisplayName(activeType)} và đồng bộ trực tiếp với biểu đồ EEG.'
            : 'Smart Ring vẫn đang tiếp tục cập nhật chỉ số của phiên đo này.';
      case SmartRingMeasureState.stopping:
        return activeType == null
            ? 'Đang hoàn tất bước đo hiện tại từ Smart Ring.'
            : 'Đang chốt mẫu ${_ringMetricDisplayName(activeType)} để chuyển sang bước tiếp theo.';
      case SmartRingMeasureState.success:
        return 'Đã thu đủ nhịp tim, SpO2 và huyết áp từ Smart Ring.';
      case SmartRingMeasureState.error:
        return 'Smart Ring gặp lỗi trong quá trình đo.';
      case SmartRingMeasureState.deviceDisconnected:
        return 'Smart Ring đã ngắt kết nối khỏi phiên đo.';
      case SmartRingMeasureState.idle:
        return isLive
            ? 'Các chỉ số sẽ xuất hiện ngay khi Smart Ring bắt đầu trả dữ liệu.'
            : 'Hiển thị chỉ số cuối cùng nhận được từ Smart Ring.';
    }
  }

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
                          'Điểm tổng hợp được tính từ bốn nguồn:\n\n'
                          '① Sóng não EEG (trọng số 45%)\n'
                          '   • Tỷ lệ Alpha cao → điểm cao (thư giãn)\n'
                          '   • Tỷ lệ Beta cao → điểm thấp (căng thẳng)\n'
                          '   • Công thức: αRatio × 0.55 + βRatio × 0.35 + 0.1\n\n'
                          '② Khảo sát tâm lý 10 câu (trọng số 20%)\n'
                          '   • 10 câu hỏi đánh giá: giấc ngủ, mức độ căng '
                          'thẳng, khả năng tập trung, phương pháp giải toả, '
                          'mệt mỏi, lo lắng, thời gian cá nhân, căng cứng cơ '
                          'thể, kiểm soát cảm xúc, kinh nghiệm thiền\n'
                          '   • Mỗi câu 5 mức (0-4): 0 = căng thẳng nhất, '
                          '4 = thư giãn nhất\n\n'
                          '③ Giấc ngủ đêm qua (trọng số 15%)\n'
                          '   • Thời lượng ngủ, ngủ sâu, REM và số lần tỉnh '
                          'giấc được dùng để đọc mức phục hồi qua đêm\n'
                          '   • Giấc ngủ tốt giúp tăng độ tin cậy cho kết luận '
                          'thư giãn và khả năng hồi phục thần kinh\n\n'
                          '④ Smart Ring (trọng số 20%)\n'
                          '   • Nhịp tim ổn định → điểm cao hơn\n'
                          '   • SpO2 tốt và huyết áp cân bằng → tăng độ tin cậy '
                          'cho kết luận thư giãn\n'
                          '   • Nếu EEG và Smart Ring lệch pha, phần diễn giải sẽ '
                          'ưu tiên mô tả rõ khác biệt giữa tâm trí và phản ứng sinh lý\n\n'
                          'Điểm cuối = EEG × 0.45 + Khảo sát × 0.2 + Giấc ngủ × 0.15 + Smart Ring × 0.2',
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

    return _buildInsightSectionCard(
      icon: Icons.quiz_outlined,
      accent: const Color(0xFF7C4DFF),
      title: 'Phân tích từ khảo sát',
      subtitle: 'Kết hợp dữ liệu 10 câu hỏi trắc nghiệm ban đầu',
      items: insights,
    );
  }

  Widget _buildSmartRingInsightsCard() {
    final insights = <_InsightItem>[
      if (_heartRateInsight.isNotEmpty)
        _InsightItem(
          Icons.favorite_outline_rounded,
          'Nhịp tim',
          _heartRateInsight,
        ),
      if (_spo2Insight.isNotEmpty)
        _InsightItem(Icons.air_rounded, 'SpO2', _spo2Insight),
      if (_bloodPressureInsight.isNotEmpty)
        _InsightItem(
          Icons.monitor_heart_outlined,
          'Huyết áp',
          _bloodPressureInsight,
        ),
      if (_vitalAlignmentInsight.isNotEmpty)
        _InsightItem(
          Icons.sync_alt_rounded,
          'Đối chiếu EEG và Smart Ring',
          _vitalAlignmentInsight,
        ),
    ];

    return _buildInsightSectionCard(
      icon: Icons.favorite_rounded,
      accent: const Color(0xFF18ADC3),
      title: 'Nhận xét chi tiết Smart Ring',
      subtitle:
          'Diễn giải từng chỉ số sinh tồn và mức đồng thuận của cơ thể với EEG',
      items: insights,
    );
  }

  Widget _buildInsightSectionCard({
    required IconData icon,
    required Color accent,
    required String title,
    required String subtitle,
    required List<_InsightItem> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.icon, size: 18, color: accent),
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
        // ── Sound section ──
        _buildRecSectionHeader(
          icon: Icons.headphones,
          title: 'Âm thanh thiền định khuyến nghị',
          color: const Color(0xFFE67E22),
        ),
        const SizedBox(height: 10),
        ...recs.sounds.map((r) => _buildSoundRecCard(r)),
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

  Future<void> _toggleTrack(_SoundRec rec) async {
    if (_playingTrack == rec.assetPath) {
      await _musicPlayer.pause();
      if (mounted) setState(() => _playingTrack = null);
    } else {
      if (mounted) setState(() => _playingTrack = rec.assetPath);
      await _musicPlayer.stop();
      await _musicPlayer.play(AssetSource(rec.assetPath));
      _musicPlayer.onPlayerComplete.listen((_) {
        if (mounted && _playingTrack == rec.assetPath) {
          setState(() => _playingTrack = null);
        }
      });
    }
  }

  Widget _buildSoundRecCard(_SoundRec rec) {
    final isPlaying = _playingTrack == rec.assetPath;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _toggleTrack(rec),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isPlaying
                    ? rec.color.withValues(alpha: 0.5)
                    : rec.color.withValues(alpha: 0.2),
                width: isPlaying ? 1.5 : 1.0,
              ),
              color: isPlaying
                  ? rec.color.withValues(alpha: 0.04)
                  : AppColors.white,
            ),
            child: Row(
              children: [
                // Icon badge
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: rec.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: isPlaying
                      ? _PulsingIcon(color: rec.color, icon: rec.icon)
                      : Icon(rec.icon, color: rec.color, size: 26),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            rec.category,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: rec.color,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '• ${rec.duration}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rec.reason,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral600,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isPlaying
                        ? rec.color
                        : rec.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: isPlaying ? Colors.white : rec.color,
                    size: 22,
                  ),
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
        sounds: [
          _SoundRec(
            title: 'Nhạc thiền tĩnh tâm',
            icon: Icons.self_improvement,
            duration: '~7 phút',
            category: 'Thư giãn sâu',
            reason:
                'Sóng Alpha ổn định — âm nhạc thiền dịu nhẹ giúp đào sâu trạng thái '
                'bình an và duy trì sóng Alpha.',
            assetPath: 'sound/09 Nhac thien.mp3',
            color: const Color(0xFF2E86AB),
          ),
          _SoundRec(
            title: 'Giai điệu an nhiên',
            icon: Icons.spa,
            duration: '~7 phút',
            category: 'Cân bằng năng lượng',
            reason:
                'Nhạc thiền nhẹ nhàng giúp kéo dài trạng thái lạc quan, '
                'tăng cường sóng Alpha trước giờ ngủ.',
            assetPath: 'sound/10 Nhac thien.mp3',
            color: const Color(0xFF4F9A67),
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
        sounds: [
          _SoundRec(
            title: 'Nhạc thiền giảm stress',
            icon: Icons.music_note,
            duration: '~10 phút',
            category: 'Giảm stress',
            reason:
                'Sóng Beta tăng nhẹ — giai điệu thiền nhẹ giúp hạ nhịp tim '
                'và chuyển não từ Beta sang Alpha một cách tự nhiên.',
            assetPath: 'sound/07 Nhac thien.mp3',
            color: const Color(0xFFE67E22),
          ),
          _SoundRec(
            title: 'Tiếng nhạc cân bằng tâm trí',
            icon: Icons.waves,
            duration: '~10 phút',
            category: 'Cân bằng',
            reason:
                'Âm nhạc thiền nhị nhàng kích thích hệ phó giao cảm, '
                'giảm cortisol và giúp sóng Alpha phục hồi.',
            assetPath: 'sound/08 Nhac thien.mp3',
            color: const Color(0xFF9B59B6),
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
        sounds: [
          _SoundRec(
            title: 'Nhạc thiền giải toả căng thẳng',
            icon: Icons.healing,
            duration: '~8 phút',
            category: 'Phục hồi',
            reason:
                'Tần số thấp của nhạc thiền giúp giảm lo âu và '
                'hạ hoạt động Beta. Phù hợp với mức căng thẳng hiện tại.',
            assetPath: 'sound/04 Nhac thien.mp3',
            color: const Color(0xFFE74C3C),
          ),
          _SoundRec(
            title: 'Giai điệu bình an nội tâm',
            icon: Icons.self_improvement,
            duration: '~10 phút',
            category: 'Thiền định',
            reason:
                'Âm nhạc thiền định tạo rào cản đối với suy nghĩ tiêu cực, '
                'giúp não chuyển sang Alpha-Theta.',
            assetPath: 'sound/09 Nhac thien.mp3',
            color: const Color(0xFF8E44AD),
          ),
          _SoundRec(
            title: 'Âm thanh phục hồi năng lượng',
            icon: Icons.spa,
            duration: '~11 phút',
            category: 'Cân bằng',
            reason:
                'Nhạc dịu bước đầu giúp não ngưng súy nghĩ quá mức '
                'và hạ Beta nhanh chóng.',
            assetPath: 'sound/10 Nhac thien.mp3',
            color: const Color(0xFF16A085),
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
        sounds: [
          _SoundRec(
            title: 'Nhạc thiền chữa lành tâm trí',
            icon: Icons.healing,
            duration: '~8 phút',
            category: 'Trị liệu',
            reason:
                'Mức căng thẳng cao — nhạc thiền dịu giúp giảm cortisol '
                'và phục hồi sóng Alpha bị ức chế.',
            assetPath: 'sound/04 Nhac thien.mp3',
            color: const Color(0xFFE74C3C),
          ),
          _SoundRec(
            title: 'Giai điệu thư thái sâu',
            icon: Icons.nightlight_round,
            duration: '~7 phút',
            category: 'Giấc ngủ sâu',
            reason:
                'Khi Beta quá cao, giấc ngủ sâu là ưu tiên phục hồi. '
                'Nhạc thiền dịu giúp não chuyển sang trạng thái nghỉ ngơi.',
            assetPath: 'sound/07 Nhac thien.mp3',
            color: const Color(0xFF2C3E50),
          ),
          _SoundRec(
            title: 'Âm thanh phục hồi toàn thân',
            icon: Icons.spa,
            duration: '~11 phút',
            category: 'Phục hồi',
            reason:
                'Âm nhạc thiền giúp giải phóng năng lượng '
                'Beta dư thừa và phục hồi sự cân bằng Alpha.',
            assetPath: 'sound/10 Nhac thien.mp3',
            color: const Color(0xFF16A085),
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
    required VoidCallback? onPressed,
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

class _SoundRec {
  const _SoundRec({
    required this.title,
    required this.icon,
    required this.duration,
    required this.category,
    required this.reason,
    required this.assetPath,
    required this.color,
  });
  final String title;
  final IconData icon;
  final String duration;
  final String category;
  final String reason;
  final String assetPath;
  final Color color;
}

class _Recommendations {
  const _Recommendations({
    required this.breathing,
    required this.meditation,
    required this.sounds,
  });
  final List<_BreathingRec> breathing;
  final List<_MeditationRec> meditation;
  final List<_SoundRec> sounds;
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

class _SleepLegendItem extends StatelessWidget {
  const _SleepLegendItem({required this.gradient, required this.label});

  final LinearGradient gradient;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.3),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

// ── Pulsing icon for currently-playing sound card ─────────────────────────

class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon({required this.color, required this.icon});
  final Color color;
  final IconData icon;

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Icon(widget.icon, color: widget.color, size: 26),
      ),
    );
  }
}
