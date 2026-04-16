import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:yc_product_plugin/yc_product_plugin.dart';

import '../../core/theme/app_colors.dart';
import '../../services/smart_ring/smart_ring_connection_service.dart';
import '../../services/smart_ring/smart_ring_measure_service.dart';

enum _HealthCheckMetric { heartRate, spo2, bloodPressure }

class _MetricVisual {
  const _MetricVisual({
    required this.title,
    required this.subtitle,
    required this.unit,
    required this.color,
    required this.darkColor,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String unit;
  final Color color;
  final Color darkColor;
  final IconData icon;
}

class SmartRingPage extends StatefulWidget {
  const SmartRingPage({super.key});

  @override
  State<SmartRingPage> createState() => _SmartRingPageState();
}

class _SmartRingPageState extends State<SmartRingPage> {
  static const Color _primary = Color(0xFF18ADC3);
  static const Color _primaryDark = Color(0xFF0D8A9C);
  static const Color _surface = Color(0xFFF6FBFC);
  static const Color _surfaceAlt = Color(0xFFE8F7FA);
  static const Color _surfaceBorder = Color(0xFFB7E3EA);

  static const Map<_HealthCheckMetric, _MetricVisual> _metricVisuals =
      <_HealthCheckMetric, _MetricVisual>{
        _HealthCheckMetric.heartRate: _MetricVisual(
          title: 'Nhịp tim',
          subtitle: 'Theo dõi nhịp tim tức thời trong trạng thái nghỉ.',
          unit: 'BPM',
          color: Color(0xFFEC4899),
          darkColor: Color(0xFFBE185D),
          icon: Icons.favorite_rounded,
        ),
        _HealthCheckMetric.spo2: _MetricVisual(
          title: 'SpO2',
          subtitle: 'Theo dõi độ bão hòa oxy ngoại vi tại thời điểm đo.',
          unit: '%',
          color: Color(0xFF3B82F6),
          darkColor: Color(0xFF1D4ED8),
          icon: Icons.water_drop_rounded,
        ),
        _HealthCheckMetric.bloodPressure: _MetricVisual(
          title: 'Huyết áp',
          subtitle: 'Ước tính huyết áp khi cơ thể đang ở trạng thái ổn định.',
          unit: 'mmHg',
          color: Color(0xFFEF4444),
          darkColor: Color(0xFFDC2626),
          icon: Icons.monitor_heart_rounded,
        ),
      };

  final SmartRingConnectionService _connectionService =
      SmartRingConnectionService.instance;
  final SmartRingMeasureService _measureService =
      SmartRingMeasureService.instance;

  bool _isInitializing = true;
  bool _isScanning = false;
  bool _isConnecting = false;
  int _bluetoothState = BluetoothState.disconnected;
  List<BluetoothDevice> _scanResults = <BluetoothDevice>[];
  BluetoothDevice? _connectedDevice;

  bool _isSequenceRunning = false;
  bool _isSequenceCompleted = false;
  bool _isStoppingSequence = false;
  SmartRingMeasureState _measureState = SmartRingMeasureState.idle;
  _HealthCheckMetric? _activeMetric;
  _HealthCheckMetric? _failedMetric;
  String? _errorMessage;

  int? _heartRateValue;
  int? _spo2Value;
  int? _bloodPressureSystolic;
  int? _bloodPressureDiastolic;

  final List<int> _heartRateSamples = <int>[];
  final List<int> _spo2Samples = <int>[];
  final List<BloodPressureData> _bloodPressureSamples = <BloodPressureData>[];

  @override
  void initState() {
    super.initState();
    _attachConnectionListeners();
    _configureMeasureService();
    _initializePage();
  }

  @override
  void dispose() {
    _connectionService.isScanningNotifier.removeListener(_syncConnectionState);
    _connectionService.isConnectingNotifier.removeListener(
      _syncConnectionState,
    );
    _connectionService.bluetoothStateNotifier.removeListener(
      _syncConnectionState,
    );
    _connectionService.scanResultsNotifier.removeListener(_syncConnectionState);
    _connectionService.connectedDeviceNotifier.removeListener(
      _syncConnectionState,
    );

    _measureService.setCallbacks(
      onHeartRateData: null,
      onSpO2Data: null,
      onBloodPressureData: null,
      onStateChanged: null,
      onError: null,
      onMeasureCompleted: null,
      onBloodPressureMeasureCompleted: null,
    );
    super.dispose();
  }

  void _attachConnectionListeners() {
    _connectionService.isScanningNotifier.addListener(_syncConnectionState);
    _connectionService.isConnectingNotifier.addListener(_syncConnectionState);
    _connectionService.bluetoothStateNotifier.addListener(_syncConnectionState);
    _connectionService.scanResultsNotifier.addListener(_syncConnectionState);
    _connectionService.connectedDeviceNotifier.addListener(
      _syncConnectionState,
    );
  }

  void _syncConnectionState() {
    if (!mounted) {
      return;
    }

    setState(() {
      _isScanning = _connectionService.isScanningNotifier.value;
      _isConnecting = _connectionService.isConnectingNotifier.value;
      _bluetoothState = _connectionService.bluetoothStateNotifier.value;
      _scanResults = List<BluetoothDevice>.from(
        _connectionService.scanResultsNotifier.value,
      );
      _connectedDevice = _connectionService.connectedDeviceNotifier.value;
    });
  }

  Future<void> _initializePage() async {
    try {
      await _connectionService.initialize();
      await _measureService.startListening();
      _syncConnectionState();
    } catch (error) {
      _showSnackBar('Không thể khởi tạo Smart Ring: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  void _configureMeasureService() {
    _measureService.setCallbacks(
      onHeartRateData: (data) {
        if (!mounted || _activeMetric != _HealthCheckMetric.heartRate) {
          return;
        }

        setState(() {
          _heartRateValue = data.value;
          _heartRateSamples.add(data.value);
          if (_heartRateSamples.length > 10) {
            _heartRateSamples.removeAt(0);
          }
        });
      },
      onSpO2Data: (data) {
        if (!mounted || _activeMetric != _HealthCheckMetric.spo2) {
          return;
        }

        setState(() {
          _spo2Value = data.value;
          _spo2Samples.add(data.value);
          if (_spo2Samples.length > 10) {
            _spo2Samples.removeAt(0);
          }
        });
      },
      onBloodPressureData: (data) {
        if (!mounted || _activeMetric != _HealthCheckMetric.bloodPressure) {
          return;
        }

        setState(() {
          _bloodPressureSystolic = data.systolic;
          _bloodPressureDiastolic = data.diastolic;
          _bloodPressureSamples.add(data);
          if (_bloodPressureSamples.length > 10) {
            _bloodPressureSamples.removeAt(0);
          }
        });
      },
      onStateChanged: _handleStateChanged,
      onError: _handleMeasureError,
      onMeasureCompleted: _handleMeasureCompleted,
      onBloodPressureMeasureCompleted: _handleBloodPressureCompleted,
    );
  }

  void _handleStateChanged(SmartRingMeasureState state) {
    if (!mounted) {
      return;
    }

    setState(() {
      _measureState = state;
      if (state == SmartRingMeasureState.deviceDisconnected) {
        _isSequenceRunning = false;
        _errorMessage =
            'Smart Ring đã ngắt kết nối. Vui lòng kết nối lại trước khi đo.';
      } else if (state == SmartRingMeasureState.error) {
        _isSequenceRunning = false;
        _failedMetric = _activeMetric;
      }
    });
  }

  void _handleMeasureError(String error) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isSequenceRunning = false;
      _failedMetric = _activeMetric;
      _errorMessage = error;
      if (error.contains('chưa kết nối') || error.contains('ngắt kết nối')) {
        _bluetoothState = BluetoothState.disconnected;
      }
    });
    _showSnackBar(error, isError: true);
  }

  void _handleMeasureCompleted(HeartRateMeasureData data) {
    if (!mounted || _isStoppingSequence) {
      return;
    }

    if (data.type == SmartRingMeasureType.heartRate) {
      setState(() {
        _heartRateValue = data.value;
      });
      _queueNextMetric(after: _HealthCheckMetric.heartRate);
      return;
    }

    if (data.type == SmartRingMeasureType.bloodOxygen) {
      setState(() {
        _spo2Value = data.value;
      });
      _queueNextMetric(after: _HealthCheckMetric.spo2);
    }
  }

  void _handleBloodPressureCompleted(BloodPressureData data) {
    if (!mounted || _isStoppingSequence) {
      return;
    }

    setState(() {
      _bloodPressureSystolic = data.systolic;
      _bloodPressureDiastolic = data.diastolic;
    });
    _queueNextMetric(after: _HealthCheckMetric.bloodPressure);
  }

  Future<void> _startScan() async {
    try {
      await _connectionService.startScan();
      if (_scanResults.isEmpty && mounted) {
        _showSnackBar(
          'Chưa tìm thấy Smart Ring gần bạn. Hãy kiểm tra xem nhẫn đã bật chưa.',
        );
      }
    } catch (error) {
      _showSnackBar('$error', isError: true);
    }
  }

  Future<void> _connectDevice(BluetoothDevice device) async {
    try {
      await _connectionService.connectDevice(device);
      if (!mounted) {
        return;
      }
      _showSnackBar('Đã kết nối ${device.name}.');
    } catch (error) {
      _showSnackBar('$error', isError: true);
    }
  }

  Future<void> _disconnectDevice() async {
    try {
      if (_isBusy) {
        await _stopCurrentMeasurement();
      }
      await _connectionService.disconnectDevice();
      if (!mounted) {
        return;
      }
      _showSnackBar('Đã ngắt kết nối Smart Ring.');
    } catch (error) {
      _showSnackBar('Không thể ngắt kết nối: $error', isError: true);
    }
  }

  Future<void> _startHealthCheck() async {
    if (_isInitializing || _isBusy) {
      return;
    }

    if (_connectedDevice == null || !_isDeviceConnected) {
      _showSnackBar(
        'Hãy kết nối Smart Ring trước khi bắt đầu đo.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSequenceRunning = true;
      _isSequenceCompleted = false;
      _isStoppingSequence = false;
      _failedMetric = null;
      _errorMessage = null;
      _measureState = SmartRingMeasureState.idle;
      _activeMetric = _HealthCheckMetric.heartRate;
      _heartRateValue = null;
      _spo2Value = null;
      _bloodPressureSystolic = null;
      _bloodPressureDiastolic = null;
      _heartRateSamples.clear();
      _spo2Samples.clear();
      _bloodPressureSamples.clear();
    });

    await _startMetric(_HealthCheckMetric.heartRate);
  }

  Future<void> _startMetric(_HealthCheckMetric metric) async {
    if (_connectedDevice == null || !_isDeviceConnected) {
      _handleMeasureError(
        'Smart Ring đã ngắt kết nối. Vui lòng kết nối lại rồi thử đo lại.',
      );
      return;
    }

    setState(() {
      _activeMetric = metric;
      _failedMetric = null;
      _errorMessage = null;
    });

    bool success = false;
    switch (metric) {
      case _HealthCheckMetric.heartRate:
        success = await _measureService.startHeartRateMeasure();
        break;
      case _HealthCheckMetric.spo2:
        success = await _measureService.startSpO2Measure();
        break;
      case _HealthCheckMetric.bloodPressure:
        success = await _measureService.startBloodPressureMeasure();
        break;
    }

    if (!success && mounted) {
      setState(() {
        _isSequenceRunning = false;
        _failedMetric = metric;
        _errorMessage =
            'Không thể bắt đầu đo ${_metricVisuals[metric]!.title.toLowerCase()}.';
      });
    }
  }

  void _queueNextMetric({required _HealthCheckMetric after}) {
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted || _isStoppingSequence) {
        return;
      }

      final _HealthCheckMetric? next = _nextMetric(after);
      if (next == null) {
        _finishSequence();
        return;
      }
      _startMetric(next);
    });
  }

  _HealthCheckMetric? _nextMetric(_HealthCheckMetric metric) {
    switch (metric) {
      case _HealthCheckMetric.heartRate:
        return _HealthCheckMetric.spo2;
      case _HealthCheckMetric.spo2:
        return _HealthCheckMetric.bloodPressure;
      case _HealthCheckMetric.bloodPressure:
        return null;
    }
  }

  void _finishSequence() {
    if (!mounted) {
      return;
    }

    setState(() {
      _isSequenceRunning = false;
      _isSequenceCompleted = true;
      _measureState = SmartRingMeasureState.success;
      _activeMetric = null;
    });

    _showSnackBar('Phiên đo đã hoàn tất.');
  }

  Future<void> _stopCurrentMeasurement() async {
    if (_activeMetric == null) {
      return;
    }

    _isStoppingSequence = true;
    switch (_activeMetric!) {
      case _HealthCheckMetric.heartRate:
        await _measureService.stopHeartRateMeasure();
        break;
      case _HealthCheckMetric.spo2:
        await _measureService.stopSpO2Measure();
        break;
      case _HealthCheckMetric.bloodPressure:
        await _measureService.stopBloodPressureMeasure();
        break;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSequenceRunning = false;
      _activeMetric = null;
      _measureState = SmartRingMeasureState.idle;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.red800 : AppColors.teal800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool get _isDeviceConnected => _bluetoothState == BluetoothState.connected;

  bool get _isBusy =>
      _measureState == SmartRingMeasureState.starting ||
      _measureState == SmartRingMeasureState.measuring ||
      _measureState == SmartRingMeasureState.stopping;

  int get _completedStepsCount {
    int completed = 0;
    if (_heartRateValue != null) {
      completed++;
    }
    if (_spo2Value != null) {
      completed++;
    }
    if (_bloodPressureSystolic != null && _bloodPressureDiastolic != null) {
      completed++;
    }
    return completed;
  }

  double get _overallProgress {
    if (_isSequenceCompleted) {
      return 1;
    }

    final double completed = _completedStepsCount / 3;
    if (_activeMetric != null && _isBusy) {
      return (completed + 0.18).clamp(0.0, 0.95);
    }
    return completed;
  }

  String get _headlineText {
    if (!_isDeviceConnected) {
      return 'Kết nối Smart Ring để bắt đầu';
    }
    if (_isSequenceCompleted) {
      return 'Đã hoàn tất phiên đo 3 chỉ số';
    }
    if (_errorMessage != null) {
      return 'Phiên đo cần thực hiện lại';
    }
    if (_activeMetric != null) {
      return 'Đang đo ${_metricVisuals[_activeMetric]!.title.toLowerCase()}';
    }
    return 'Sẵn sàng đo nhịp tim, SpO2 và huyết áp';
  }

  String get _supportingText {
    if (!_isDeviceConnected) {
      return 'Tab này chỉ tập trung cho Smart Ring với dữ liệu đo thực, không sync cloud và không ảnh hưởng phần sóng não.';
    }
    if (_errorMessage != null) {
      return _errorMessage!;
    }
    if (_activeMetric != null) {
      return _metricVisuals[_activeMetric]!.subtitle;
    }
    return 'Một lần chạm sẽ lần lượt đo nhịp tim, SpO2 và huyết áp ngay trong Zenwave.';
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _surface,
      child: RefreshIndicator(
        color: _primary,
        onRefresh: _connectionService.refreshConnectionState,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeader(),
              const SizedBox(height: 16),
              _buildConnectionCard(),
              const SizedBox(height: 16),
              _buildHealthCheckCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              Text(
                'Smart Ring',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Đo nhịp tim, SpO2 và huyết áp trực tiếp từ nhẫn thông minh bằng SDK YCBT.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF5B6B7A),
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildBluetoothBadge(),
      ],
    );
  }

  Widget _buildBluetoothBadge() {
    final bool connected = _isDeviceConnected;
    final Color background = connected ? _surfaceAlt : const Color(0xFFFFF7ED);
    final Color border = connected ? _surfaceBorder : const Color(0xFFFED7AA);
    final Color textColor = connected ? _primaryDark : const Color(0xFFB45309);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            connected
                ? Icons.bluetooth_connected_rounded
                : Icons.bluetooth_disabled_rounded,
            color: textColor,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            connected ? 'Đã kết nối' : 'Chưa kết nối',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionCard() {
    final bool bluetoothOff = _bluetoothState == BluetoothState.off;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2EEF1)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 14),
            spreadRadius: -18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.radar_rounded, color: _primaryDark),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Thiết bị Smart Ring',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Quét nhẫn gần bạn, kết nối một lần và đo trực tiếp trong Zenwave.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_connectedDevice != null) _buildConnectedDeviceCard(),
          if (_connectedDevice == null && bluetoothOff)
            _buildBluetoothOffHint(),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isInitializing || _isScanning || _isConnecting
                      ? null
                      : _startScan,
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isScanning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.search_rounded),
                  label: Text(_isScanning ? 'Đang quét...' : 'Quét thiết bị'),
                ),
              ),
              if (_connectedDevice != null) ...<Widget>[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isConnecting || _isScanning
                        ? null
                        : _disconnectDevice,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    icon: const Icon(Icons.link_off_rounded),
                    label: const Text('Ngắt kết nối'),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          if (_scanResults.isNotEmpty) _buildScanResultsList(),
          if (_scanResults.isEmpty && !_isScanning && _connectedDevice == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'Nhấn "Quét thiết bị" để tìm Smart Ring ở gần. Nếu nhẫn chưa xuất hiện, hãy kiểm tra pin và đảm bảo thiết bị đang ở trạng thái sẵn sàng kết nối.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConnectedDeviceCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[_surfaceAlt, Colors.white],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _surfaceBorder),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: _primaryDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _connectedDevice?.name ?? 'Smart Ring',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _connectedDevice?.deviceBunId.isNotEmpty == true
                      ? 'Model: ${_connectedDevice!.deviceBunId}'
                      : 'Thiết bị đã sẵn sàng cho phiên đo.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4B5563),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.green100,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Online',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF166534),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothOffHint() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: const Text(
        'Bluetooth của thiết bị đang tắt. Hãy bật Bluetooth rồi quét lại Smart Ring.',
        style: TextStyle(
          fontSize: 12.5,
          color: Color(0xFF9A3412),
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildScanResultsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Thiết bị tìm thấy',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 10),
        ..._scanResults.map((BluetoothDevice device) {
          final bool isCurrentDevice =
              _connectedDevice?.deviceIdentifier == device.deviceIdentifier;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrentDevice
                    ? _surfaceBorder
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        device.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'RSSI ${device.rssiValue} • ${device.deviceBunId.isEmpty ? 'Smart Ring' : device.deviceBunId}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _isConnecting || isCurrentDevice
                      ? null
                      : () => _connectDevice(device),
                  style: FilledButton.styleFrom(
                    backgroundColor: isCurrentDevice
                        ? AppColors.green700
                        : _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(isCurrentDevice ? 'Đã nối' : 'Kết nối'),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHealthCheckCard() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: _connectedDevice != null ? 1 : 0.72,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFFFCFEFF),
              Color(0xFFF2FBFD),
              Color(0xFFFFFFFF),
            ],
          ),
          border: Border.all(color: _surfaceBorder),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: _primary.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 18),
              spreadRadius: -18,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: -40,
                right: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primary.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -56,
                left: -20,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _surfaceAlt.withValues(alpha: 0.7),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildHeroSection(),
                    const SizedBox(height: 18),
                    _buildGuidanceCard(),
                    if (_errorMessage != null) ...<Widget>[
                      const SizedBox(height: 14),
                      _buildErrorCard(),
                    ],
                    const SizedBox(height: 16),
                    _buildMetricCard(_HealthCheckMetric.heartRate),
                    const SizedBox(height: 12),
                    _buildMetricCard(_HealthCheckMetric.spo2),
                    const SizedBox(height: 12),
                    _buildMetricCard(_HealthCheckMetric.bloodPressure),
                    const SizedBox(height: 16),
                    _buildPrimaryAction(),
                  ],
                ),
              ),
              if (_connectedDevice == null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: Container(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
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

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _surfaceAlt,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _surfaceBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Icon(
                          Icons.health_and_safety_rounded,
                          size: 16,
                          color: _primaryDark,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Phiên đo 3 chỉ số',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: _primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _headlineText,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.6,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _supportingText,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _buildProgressDial(),
          ],
        ),
        const SizedBox(height: 18),
        _buildProgressSection(),
      ],
    );
  }

  Widget _buildGuidanceCard() {
    const List<String> guidanceItems = <String>[
      'Đeo nhẫn vừa khít và giữ tay thư giãn trong suốt quá trình đo.',
      'Hạn chế nói chuyện hoặc cử động mạnh để tín hiệu ổn định hơn.',
      'Kết quả chỉ phục vụ theo dõi sức khỏe hằng ngày, không thay thế chẩn đoán y khoa.',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _surfaceBorder.withValues(alpha: 0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Hướng dẫn trước khi đo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Phiên đo này dùng dữ liệu real-time từ Smart Ring và không gửi lên cloud.',
            style: TextStyle(
              fontSize: 11.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          ...guidanceItems.map((String item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: _surfaceAlt,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: _primaryDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFBCDD3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.error_outline_rounded, color: Color(0xFFBE123C)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage ?? '',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9F1239),
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDial() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFEAF8FB), Color(0xFFF6FCFD)],
        ),
        border: Border.all(color: _surfaceBorder),
      ),
      child: Center(
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: _primary.withValues(alpha: 0.15),
                blurRadius: 18,
                offset: const Offset(0, 8),
                spreadRadius: -10,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '${_completedStepsCount.clamp(0, 3)}/3',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _primaryDark,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _isSequenceCompleted ? 'Xong' : 'Bước',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final int progressPercent = (_overallProgress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Tiến độ phiên đo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Text(
                    '$progressPercent%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: _overallProgress.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE2EDF0),
                  valueColor: const AlwaysStoppedAnimation<Color>(_primary),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildStagePill(
                      label: 'Nhịp tim',
                      metric: _HealthCheckMetric.heartRate,
                      stepNumber: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildStagePill(
                      label: 'SpO2',
                      metric: _HealthCheckMetric.spo2,
                      stepNumber: 2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildStagePill(
                      label: 'Huyết áp',
                      metric: _HealthCheckMetric.bloodPressure,
                      stepNumber: 3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStagePill({
    required String label,
    required _HealthCheckMetric metric,
    required int stepNumber,
  }) {
    final _MetricVisual visual = _metricVisuals[metric]!;
    final bool isCompleted = _isMetricCompleted(metric);
    final bool isActive = _activeMetric == metric && _isBusy;
    final bool isFailed = _failedMetric == metric && _errorMessage != null;

    Color background = const Color(0xFFF8FBFC);
    Color foreground = const Color(0xFF64748B);
    Color borderColor = const Color(0xFFDCEBEE);
    Color indicatorBackground = const Color(0xFFE7F0F3);
    Color indicatorForeground = const Color(0xFF5F7D86);

    if (isCompleted) {
      background = visual.color.withValues(alpha: 0.12);
      foreground = visual.darkColor;
      borderColor = visual.color.withValues(alpha: 0.18);
      indicatorBackground = visual.color;
      indicatorForeground = Colors.white;
    } else if (isActive) {
      background = visual.color.withValues(alpha: 0.14);
      foreground = visual.darkColor;
      borderColor = visual.color.withValues(alpha: 0.24);
      indicatorBackground = visual.color;
      indicatorForeground = Colors.white;
    } else if (isFailed) {
      background = const Color(0xFFFFF1F2);
      foreground = const Color(0xFFE11D48);
      borderColor = const Color(0xFFF7C8D2);
      indicatorBackground = const Color(0xFFE11D48);
      indicatorForeground = Colors.white;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: indicatorBackground,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: isCompleted
                ? Icon(
                    Icons.check_rounded,
                    size: 11,
                    color: indicatorForeground,
                  )
                : isFailed
                ? Icon(
                    Icons.close_rounded,
                    size: 11,
                    color: indicatorForeground,
                  )
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: indicatorForeground,
                    ),
                  ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(_HealthCheckMetric metric) {
    final _MetricVisual visual = _metricVisuals[metric]!;
    final bool isActive =
        _activeMetric == metric && (_isBusy || _isSequenceRunning);
    final bool isFailed = _failedMetric == metric && _errorMessage != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isActive
              ? visual.color.withValues(alpha: 0.24)
              : isFailed
              ? const Color(0xFFE11D48).withValues(alpha: 0.18)
              : visual.color.withValues(alpha: 0.14),
          width: isActive ? 1.4 : 1,
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      visual.color.withValues(alpha: 0.18),
                      visual.color.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(visual.icon, color: visual.darkColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      visual.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _metricSecondaryText(metric),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(metric),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  visual.color.withValues(alpha: 0.12),
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _metricDisplayValue(metric),
                  style: TextStyle(
                    fontSize: metric == _HealthCheckMetric.bloodPressure
                        ? 26
                        : 30,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  metric == _HealthCheckMetric.bloodPressure
                      ? 'Đơn vị ${visual.unit}'
                      : 'Đơn vị ${visual.unit}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: visual.darkColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _sampleChips(metric, visual),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(_HealthCheckMetric metric) {
    final bool isCompleted = _isMetricCompleted(metric);
    final bool isActive = _activeMetric == metric && _isBusy;
    final bool isFailed = _failedMetric == metric && _errorMessage != null;

    Color background = const Color(0xFFF1F5F9);
    Color textColor = const Color(0xFF64748B);
    String label = 'Chờ đo';

    if (isCompleted) {
      background = AppColors.green100;
      textColor = const Color(0xFF166534);
      label = 'Đã có kết quả';
    } else if (isActive) {
      background = _metricVisuals[metric]!.color.withValues(alpha: 0.14);
      textColor = _metricVisuals[metric]!.darkColor;
      label = 'Đang đo';
    } else if (isFailed) {
      background = const Color(0xFFFFE4E6);
      textColor = const Color(0xFFBE123C);
      label = 'Lỗi';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildPrimaryAction() {
    if (_connectedDevice == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          'Sau khi kết nối Smart Ring, bạn có thể bấm một lần để đo đồng thời nhịp tim, SpO2 và huyết áp.',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            height: 1.45,
          ),
        ),
      );
    }

    if (_isBusy) {
      return Row(
        children: <Widget>[
          Expanded(
            child: FilledButton.icon(
              onPressed: null,
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              label: Text(
                'Đang đo ${_metricVisuals[_activeMetric]!.title.toLowerCase()}',
              ),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: _stopCurrentMeasurement,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text('Dừng'),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isInitializing || _isConnecting ? null : _startHealthCheck,
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: Icon(
          _isSequenceCompleted
              ? Icons.refresh_rounded
              : Icons.play_arrow_rounded,
        ),
        label: Text(
          _isSequenceCompleted ? 'Đo lại 3 chỉ số' : 'Bắt đầu đo 3 chỉ số',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  List<Widget> _sampleChips(_HealthCheckMetric metric, _MetricVisual visual) {
    switch (metric) {
      case _HealthCheckMetric.heartRate:
        if (_heartRateSamples.isEmpty) {
          return <Widget>[_emptyChip('Chưa có dữ liệu real-time')];
        }
        return _heartRateSamples.reversed
            .take(5)
            .map(
              (int value) => _sampleChip(
                '$value ${visual.unit}',
                visual.color.withValues(alpha: 0.12),
                visual.darkColor,
              ),
            )
            .toList();
      case _HealthCheckMetric.spo2:
        if (_spo2Samples.isEmpty) {
          return <Widget>[_emptyChip('Chưa có dữ liệu real-time')];
        }
        return _spo2Samples.reversed
            .take(5)
            .map(
              (int value) => _sampleChip(
                '$value${visual.unit}',
                visual.color.withValues(alpha: 0.12),
                visual.darkColor,
              ),
            )
            .toList();
      case _HealthCheckMetric.bloodPressure:
        if (_bloodPressureSamples.isEmpty) {
          return <Widget>[_emptyChip('Chưa có dữ liệu real-time')];
        }
        return _bloodPressureSamples.reversed
            .take(5)
            .map(
              (BloodPressureData value) => _sampleChip(
                '${value.systolic}/${value.diastolic}',
                visual.color.withValues(alpha: 0.12),
                visual.darkColor,
              ),
            )
            .toList();
    }
  }

  Widget _sampleChip(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }

  Widget _emptyChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  bool _isMetricCompleted(_HealthCheckMetric metric) {
    switch (metric) {
      case _HealthCheckMetric.heartRate:
        return _heartRateValue != null;
      case _HealthCheckMetric.spo2:
        return _spo2Value != null;
      case _HealthCheckMetric.bloodPressure:
        return _bloodPressureSystolic != null &&
            _bloodPressureDiastolic != null;
    }
  }

  String _metricDisplayValue(_HealthCheckMetric metric) {
    switch (metric) {
      case _HealthCheckMetric.heartRate:
        return _heartRateValue != null ? '${_heartRateValue!}' : '--';
      case _HealthCheckMetric.spo2:
        return _spo2Value != null ? '${_spo2Value!}' : '--';
      case _HealthCheckMetric.bloodPressure:
        if (_bloodPressureSystolic == null || _bloodPressureDiastolic == null) {
          return '--/--';
        }
        return '${_bloodPressureSystolic!}/${_bloodPressureDiastolic!}';
    }
  }

  String _metricSecondaryText(_HealthCheckMetric metric) {
    switch (metric) {
      case _HealthCheckMetric.heartRate:
        return _heartRateStatusLabel();
      case _HealthCheckMetric.spo2:
        return _spo2StatusLabel();
      case _HealthCheckMetric.bloodPressure:
        return _bloodPressureStatusLabel();
    }
  }

  String _heartRateStatusLabel() {
    final int? value = _heartRateValue;
    if (value == null) {
      return 'Mốc tham chiếu 60 - 100 BPM';
    }
    if (value < 60) {
      return 'Nhịp tim thấp hơn mức nghỉ thông thường';
    }
    if (value <= 100) {
      return 'Nhịp tim đang trong vùng tham chiếu';
    }
    return 'Nhịp tim cao, nên nghỉ ngơi và đo lại';
  }

  String _spo2StatusLabel() {
    final int? value = _spo2Value;
    if (value == null) {
      return 'Mốc tham chiếu từ 95% trở lên';
    }
    if (value >= 95) {
      return 'SpO2 đang trong vùng ổn định';
    }
    if (value >= 90) {
      return 'SpO2 hơi thấp, nên theo dõi thêm';
    }
    return 'SpO2 thấp, cần chú ý và đo lại';
  }

  String _bloodPressureStatusLabel() {
    final int? systolic = _bloodPressureSystolic;
    final int? diastolic = _bloodPressureDiastolic;
    if (systolic == null || diastolic == null) {
      return 'Mốc tham chiếu dưới 120/80 mmHg';
    }
    if (systolic <= 120 && diastolic <= 80) {
      return 'Huyết áp đang ở vùng tham chiếu';
    }
    if (systolic <= 129 && diastolic <= 84) {
      return 'Huyết áp hơi cao, nên đo lại khi nghỉ ngơi';
    }
    return 'Huyết áp cao, nên theo dõi kỹ hơn';
  }
}
