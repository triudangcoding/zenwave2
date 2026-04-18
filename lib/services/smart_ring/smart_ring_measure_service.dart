import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:yc_product_plugin/yc_product_plugin.dart';

import 'smart_ring_connection_service.dart';
import 'smart_ring_event_bus.dart';

enum SmartRingMeasureState {
  idle,
  starting,
  measuring,
  stopping,
  success,
  error,
  deviceDisconnected,
}

enum SmartRingMeasureType { heartRate, bloodPressure, bloodOxygen }

class HeartRateMeasureData {
  const HeartRateMeasureData({
    required this.value,
    required this.timestamp,
    required this.type,
  });

  final int value;
  final DateTime timestamp;
  final SmartRingMeasureType type;
}

class SpO2MeasureData {
  const SpO2MeasureData({
    required this.value,
    required this.timestamp,
    required this.type,
  });

  final int value;
  final DateTime timestamp;
  final SmartRingMeasureType type;
}

class BloodPressureData {
  const BloodPressureData({
    required this.systolic,
    required this.diastolic,
    required this.timestamp,
  });

  final int systolic;
  final int diastolic;
  final DateTime timestamp;
}

class SmartRingCombinedMeasurementResult {
  const SmartRingCombinedMeasurementResult({
    required this.heartRate,
    required this.spo2,
    required this.bloodPressure,
  });

  final HeartRateMeasureData heartRate;
  final SpO2MeasureData spo2;
  final BloodPressureData bloodPressure;
}

typedef HeartRateCallback = void Function(HeartRateMeasureData data);
typedef SpO2Callback = void Function(SpO2MeasureData data);
typedef BloodPressureCallback = void Function(BloodPressureData data);
typedef MeasureStateCallback = void Function(SmartRingMeasureState state);
typedef MeasureErrorCallback = void Function(String error);
typedef MeasureCompletedCallback = void Function(HeartRateMeasureData data);
typedef BloodPressureMeasureCompletedCallback =
    void Function(BloodPressureData data);

class SmartRingMeasureService {
  SmartRingMeasureService._();

  static final SmartRingMeasureService instance = SmartRingMeasureService._();

  StreamSubscription<Map<dynamic, dynamic>>? _subscription;

  SmartRingMeasureState _currentState = SmartRingMeasureState.idle;
  bool _isListening = false;
  bool _isCombinedMeasurementRunning = false;
  bool _isCheckingLowSpO2 = false;
  final List<int> _lowSpO2Values = <int>[];
  final List<BloodPressureData> _currentBloodPressureMeasurements =
      <BloodPressureData>[];

  HeartRateMeasureData? _lastHeartRateData;
  SpO2MeasureData? _lastSpO2Data;
  BloodPressureData? _lastBloodPressureData;

  HeartRateCallback? _onHeartRateData;
  SpO2Callback? _onSpO2Data;
  BloodPressureCallback? _onBloodPressureData;
  MeasureStateCallback? _onStateChanged;
  MeasureErrorCallback? _onError;
  MeasureCompletedCallback? _onMeasureCompleted;
  BloodPressureMeasureCompletedCallback? _onBloodPressureMeasureCompleted;

  Completer<Object>? _pendingMeasureCompleter;
  SmartRingMeasureType? _pendingMeasureType;
  bool _pendingMeasureStopsOnFirstSample = false;
  SmartRingMeasureType? _lockedFirstSampleType;
  bool _isCancellationRequested = false;

  SmartRingMeasureState get currentState => _currentState;
  SmartRingMeasureType? get currentMeasureType =>
      _pendingMeasureType ?? _lockedFirstSampleType;

  void setCallbacks({
    HeartRateCallback? onHeartRateData,
    SpO2Callback? onSpO2Data,
    BloodPressureCallback? onBloodPressureData,
    MeasureStateCallback? onStateChanged,
    MeasureErrorCallback? onError,
    MeasureCompletedCallback? onMeasureCompleted,
    BloodPressureMeasureCompletedCallback? onBloodPressureMeasureCompleted,
  }) {
    _onHeartRateData = onHeartRateData;
    _onSpO2Data = onSpO2Data;
    _onBloodPressureData = onBloodPressureData;
    _onStateChanged = onStateChanged;
    _onError = onError;
    _onMeasureCompleted = onMeasureCompleted;
    _onBloodPressureMeasureCompleted = onBloodPressureMeasureCompleted;
  }

  Future<void> startListening() async {
    if (_isListening) {
      return;
    }

    await SmartRingConnectionService.instance.initialize();
    SmartRingEventBus.instance.ensureListening();
    _subscription = SmartRingEventBus.instance.events.listen(
      _handleNativeEvent,
    );
    _isListening = true;
  }

  Future<bool> checkDeviceConnection({bool waitForReconnect = false}) async {
    final int state =
        await YcProductPlugin().getBluetoothState() ??
        BluetoothState.disconnected;
    bool isConnected = await SmartRingConnectionService.instance
        .isDeviceConnected(rawState: state);

    if (!isConnected &&
        waitForReconnect &&
        Platform.isIOS &&
        state == BluetoothState.on) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      isConnected = await SmartRingConnectionService.instance
          .isDeviceConnected();
    }

    return isConnected;
  }

  Future<bool> startHeartRateMeasure() async {
    return _startMeasure(
      type: SmartRingMeasureType.heartRate,
      starter: () => YcProductPlugin().appControlMeasureHealthData(
        true,
        DeviceAppControlMeasureHealthDataType.heartRate,
      ),
      errorMessage: 'Không thể bắt đầu đo nhịp tim.',
    );
  }

  Future<bool> stopHeartRateMeasure() async {
    return _stopMeasure(
      stopper: () => YcProductPlugin().appControlMeasureHealthData(
        false,
        DeviceAppControlMeasureHealthDataType.heartRate,
      ),
      errorMessage: 'Không thể dừng đo nhịp tim.',
    );
  }

  Future<bool> startSpO2Measure() async {
    _lowSpO2Values.clear();
    _isCheckingLowSpO2 = true;
    return _startMeasure(
      type: SmartRingMeasureType.bloodOxygen,
      starter: () => YcProductPlugin().appControlMeasureHealthData(
        true,
        DeviceAppControlMeasureHealthDataType.bloodOxygen,
      ),
      errorMessage: 'Không thể bắt đầu đo SpO2.',
    );
  }

  Future<bool> stopSpO2Measure() async {
    _isCheckingLowSpO2 = false;
    return _stopMeasure(
      stopper: () => YcProductPlugin().realTimeDataUpload(
        false,
        dataType: DeviceRealTimeDataType.bloodOxygen,
      ),
      errorMessage: 'Không thể dừng đo SpO2.',
    );
  }

  Future<bool> startBloodPressureMeasure() async {
    _currentBloodPressureMeasurements.clear();
    return _startMeasure(
      type: SmartRingMeasureType.bloodPressure,
      starter: () => YcProductPlugin().appControlMeasureHealthData(
        true,
        DeviceAppControlMeasureHealthDataType.bloodPressure,
      ),
      errorMessage: 'Không thể bắt đầu đo huyết áp.',
    );
  }

  Future<bool> stopBloodPressureMeasure() async {
    return _stopMeasure(
      stopper: () => YcProductPlugin().appControlMeasureHealthData(
        false,
        DeviceAppControlMeasureHealthDataType.bloodPressure,
      ),
      errorMessage: 'Không thể dừng đo huyết áp.',
    );
  }

  Future<SmartRingCombinedMeasurementResult>
  runCombinedMeasurementSequence() async {
    if (_isCombinedMeasurementRunning) {
      throw StateError('Smart Ring đang có một phiên đo khác.');
    }

    _isCombinedMeasurementRunning = true;
    _isCancellationRequested = false;
    try {
      final bool connected = await checkDeviceConnection(
        waitForReconnect: true,
      );
      if (!connected) {
        throw StateError(
          'Smart Ring chưa sẵn sàng. Vui lòng kết nối lại trước khi bắt đầu đo.',
        );
      }

      final HeartRateMeasureData heartRate =
          await _runMeasureStep<HeartRateMeasureData>(
            type: SmartRingMeasureType.heartRate,
            starter: startHeartRateMeasure,
            timeout: const Duration(seconds: 40),
            stopAfterFirstSample: true,
          );

      await Future<void>.delayed(const Duration(milliseconds: 900));

      final SpO2MeasureData spo2 = await _runMeasureStep<SpO2MeasureData>(
        type: SmartRingMeasureType.bloodOxygen,
        starter: startSpO2Measure,
        stopAfterFirstSample: false,
      );

      await Future<void>.delayed(const Duration(milliseconds: 900));

      final BloodPressureData bloodPressure =
          await _runMeasureStep<BloodPressureData>(
            type: SmartRingMeasureType.bloodPressure,
            starter: startBloodPressureMeasure,
            stopAfterFirstSample: false,
          );

      return SmartRingCombinedMeasurementResult(
        heartRate: heartRate,
        spo2: spo2,
        bloodPressure: bloodPressure,
      );
    } finally {
      _isCombinedMeasurementRunning = false;
      _isCancellationRequested = false;
      _pendingMeasureCompleter = null;
      _pendingMeasureType = null;
      _pendingMeasureStopsOnFirstSample = false;
      _lockedFirstSampleType = null;
    }
  }

  Future<void> cancelCombinedMeasurementSequence({
    String reason = 'Đã hủy phiên đo Smart Ring.',
  }) async {
    if (!_isCombinedMeasurementRunning && _pendingMeasureType == null) {
      return;
    }

    _isCancellationRequested = true;
    _isCheckingLowSpO2 = false;
    _lowSpO2Values.clear();

    final SmartRingMeasureType? type = _pendingMeasureType;
    if (type != null) {
      try {
        await _stopMeasureByType(type);
      } catch (_) {}
      _failPendingMeasure(StateError(reason));
    }

    _pendingMeasureStopsOnFirstSample = false;
    _lockedFirstSampleType = null;
    _updateState(SmartRingMeasureState.idle);
  }

  Future<T> _runMeasureStep<T>({
    required SmartRingMeasureType type,
    required Future<bool> Function() starter,
    Duration? timeout,
    bool stopAfterFirstSample = false,
  }) async {
    _pendingMeasureType = type;
    _pendingMeasureCompleter = Completer<Object>();
    _pendingMeasureStopsOnFirstSample = stopAfterFirstSample;
    _lockedFirstSampleType = null;

    final bool started = await starter();
    if (!started) {
      _pendingMeasureCompleter = null;
      _pendingMeasureType = null;
      _pendingMeasureStopsOnFirstSample = false;
      throw StateError('Không thể bắt đầu ${_measureTypeLabel(type)}.');
    }

    try {
      final Future<Object> pendingFuture = _pendingMeasureCompleter!.future;
      final Object result = timeout == null
          ? await pendingFuture
          : await pendingFuture.timeout(timeout);
      if (stopAfterFirstSample) {
        await _stopMeasureByType(type);
        await Future<void>.delayed(const Duration(milliseconds: 500));
        _lockedFirstSampleType = null;
      }
      _pendingMeasureStopsOnFirstSample = false;
      return result as T;
    } on TimeoutException {
      await _stopMeasureByType(type);
      _pendingMeasureCompleter = null;
      _pendingMeasureType = null;
      _pendingMeasureStopsOnFirstSample = false;
      _lockedFirstSampleType = null;
      throw TimeoutException(
        'Đo ${_measureTypeLabel(type)} quá thời gian chờ.',
        timeout,
      );
    }
  }

  Future<void> _stopMeasureByType(SmartRingMeasureType type) async {
    switch (type) {
      case SmartRingMeasureType.heartRate:
        await stopHeartRateMeasure();
        break;
      case SmartRingMeasureType.bloodPressure:
        await stopBloodPressureMeasure();
        break;
      case SmartRingMeasureType.bloodOxygen:
        await stopSpO2Measure();
        break;
    }
  }

  String _measureTypeLabel(SmartRingMeasureType type) {
    switch (type) {
      case SmartRingMeasureType.heartRate:
        return 'đo nhịp tim';
      case SmartRingMeasureType.bloodPressure:
        return 'đo huyết áp';
      case SmartRingMeasureType.bloodOxygen:
        return 'đo SpO2';
    }
  }

  Future<bool> _startMeasure({
    required SmartRingMeasureType type,
    required Future<PluginResponse?> Function() starter,
    required String errorMessage,
  }) async {
    await startListening();

    final bool connected = await checkDeviceConnection(waitForReconnect: true);
    if (!connected) {
      _updateState(SmartRingMeasureState.deviceDisconnected);
      _onError?.call(
        'Thiết bị chưa kết nối. Vui lòng kết nối Smart Ring trước khi đo.',
      );
      return false;
    }

    try {
      _updateState(SmartRingMeasureState.starting);
      final PluginResponse? result = await starter();
      if (result?.statusCode == PluginState.succeed) {
        _updateState(SmartRingMeasureState.measuring);
        return true;
      }
    } catch (error) {
      debugPrint('[SmartRingMeasureService] Start measure error: $error');
    }

    _updateState(SmartRingMeasureState.error);
    _onError?.call(errorMessage);
    return false;
  }

  Future<bool> _stopMeasure({
    required Future<PluginResponse?> Function() stopper,
    required String errorMessage,
  }) async {
    try {
      _updateState(SmartRingMeasureState.stopping);
      final PluginResponse? result = await stopper();
      if (result?.statusCode == PluginState.succeed) {
        _updateState(SmartRingMeasureState.success);
        return true;
      }
    } catch (error) {
      debugPrint('[SmartRingMeasureService] Stop measure error: $error');
    }

    _updateState(SmartRingMeasureState.error);
    _onError?.call(errorMessage);
    return false;
  }

  void _handleNativeEvent(Map<dynamic, dynamic> event) {
    final int? bluetoothState = event[NativeEventType.bluetoothStateChange];
    if (bluetoothState == BluetoothState.disconnected ||
        bluetoothState == BluetoothState.off ||
        bluetoothState == BluetoothState.connectFailed) {
      if (_currentState == SmartRingMeasureState.measuring ||
          _currentState == SmartRingMeasureState.starting ||
          _currentState == SmartRingMeasureState.stopping) {
        _failPendingMeasure(
          StateError(
            'Smart Ring đã ngắt kết nối. Vui lòng kết nối lại và thử lại.',
          ),
        );
        _updateState(SmartRingMeasureState.deviceDisconnected);
        _onError?.call(
          'Smart Ring đã ngắt kết nối. Vui lòng kết nối lại và thử lại.',
        );
      }
    }

    final Map? measureStateInfo =
        event[NativeEventType.deviceHealthDataMeasureStateChange];
    if (measureStateInfo != null) {
      _handleMeasureStateChange(measureStateInfo);
    }

    final int? heartRate = event[NativeEventType.deviceRealHeartRate];
    if (heartRate != null) {
      _handleHeartRateData(heartRate);
    }

    final int? bloodOxygen = event[NativeEventType.deviceRealBloodOxygen];
    if (bloodOxygen != null) {
      _handleBloodOxygenData(bloodOxygen);
    }

    final Map? bloodPressureInfo =
        event[NativeEventType.deviceRealBloodPressure];
    if (bloodPressureInfo != null) {
      _handleBloodPressureData(bloodPressureInfo);
    }
  }

  void _handleMeasureStateChange(Map<dynamic, dynamic> measureStateInfo) {
    final int? healthDataType = measureStateInfo['healthDataType'];
    final int? state = measureStateInfo['state'];

    if (healthDataType == null || state == null) {
      return;
    }

    if (healthDataType == 0) {
      if (state == 1 && _lastHeartRateData != null) {
        _completePendingMeasure(
          SmartRingMeasureType.heartRate,
          _lastHeartRateData!,
        );
        _onMeasureCompleted?.call(_lastHeartRateData!);
        _markSuccessThenIdle();
      } else if (state == 2) {
        _markInterrupted(
          'Đo nhịp tim bị gián đoạn. Vui lòng giữ yên tay và thử lại.',
        );
      }
      return;
    }

    if (healthDataType == 1) {
      if (state == 1 && _lastBloodPressureData != null) {
        _completePendingMeasure(
          SmartRingMeasureType.bloodPressure,
          _lastBloodPressureData!,
        );
        _onBloodPressureMeasureCompleted?.call(_lastBloodPressureData!);
        _markSuccessThenIdle();
      } else if (state == 2) {
        _markInterrupted(
          'Đo huyết áp bị gián đoạn. Vui lòng giữ nguyên tư thế và thử lại.',
        );
      }
      return;
    }

    if (healthDataType == 2) {
      if (state == 1 && _lastSpO2Data != null) {
        _completePendingMeasure(
          SmartRingMeasureType.bloodOxygen,
          _lastSpO2Data!,
        );
        _isCheckingLowSpO2 = false;
        _onMeasureCompleted?.call(
          HeartRateMeasureData(
            value: _lastSpO2Data!.value,
            timestamp: _lastSpO2Data!.timestamp,
            type: SmartRingMeasureType.bloodOxygen,
          ),
        );
        _markSuccessThenIdle();
      } else if (state == 2) {
        _isCheckingLowSpO2 = false;
        _markInterrupted(
          'Đo SpO2 bị gián đoạn. Vui lòng đeo nhẫn sát tay và thử lại.',
        );
      }
    }
  }

  void _handleHeartRateData(int heartRate) {
    if (_isCancellationRequested) {
      return;
    }
    if (_lockedFirstSampleType == SmartRingMeasureType.heartRate) {
      return;
    }

    _lastHeartRateData = HeartRateMeasureData(
      value: heartRate,
      timestamp: DateTime.now(),
      type: SmartRingMeasureType.heartRate,
    );
    _onHeartRateData?.call(_lastHeartRateData!);
    _completePendingMeasure(
      SmartRingMeasureType.heartRate,
      _lastHeartRateData!,
    );
  }

  void _handleBloodOxygenData(int bloodOxygen) {
    if (_isCancellationRequested) {
      return;
    }
    if (_lockedFirstSampleType == SmartRingMeasureType.bloodOxygen) {
      return;
    }

    _lastSpO2Data = SpO2MeasureData(
      value: bloodOxygen,
      timestamp: DateTime.now(),
      type: SmartRingMeasureType.bloodOxygen,
    );
    _onSpO2Data?.call(_lastSpO2Data!);
    if (_pendingMeasureStopsOnFirstSample) {
      _completePendingMeasure(SmartRingMeasureType.bloodOxygen, _lastSpO2Data!);
    }

    if (_isCheckingLowSpO2 &&
        _currentState == SmartRingMeasureState.measuring &&
        bloodOxygen < 95) {
      _lowSpO2Values.add(bloodOxygen);
      if (_lowSpO2Values.length >= 3) {
        _isCheckingLowSpO2 = false;
        stopSpO2Measure().then((_) {
          _failPendingMeasure(
            StateError(
              'Tín hiệu SpO2 không ổn định. Vui lòng đeo nhẫn đúng vị trí và thử lại.',
            ),
          );
          _updateState(SmartRingMeasureState.error);
          _onError?.call(
            'Tín hiệu SpO2 không ổn định. Vui lòng đeo nhẫn đúng vị trí và thử lại.',
          );
        });
      }
    }
  }

  void _handleBloodPressureData(Map<dynamic, dynamic> data) {
    if (_isCancellationRequested) {
      return;
    }
    if (_lockedFirstSampleType == SmartRingMeasureType.bloodPressure) {
      return;
    }

    final int? systolic =
        data['systolic'] ??
        data['high'] ??
        data['systolicBloodPressure'] ??
        data['SBP'];
    final int? diastolic =
        data['diastolic'] ??
        data['low'] ??
        data['diastolicBloodPressure'] ??
        data['DBP'];

    if (systolic == null || diastolic == null) {
      return;
    }

    _lastBloodPressureData = BloodPressureData(
      systolic: systolic,
      diastolic: diastolic,
      timestamp: DateTime.now(),
    );
    _currentBloodPressureMeasurements.add(_lastBloodPressureData!);
    _onBloodPressureData?.call(_lastBloodPressureData!);
    if (_pendingMeasureStopsOnFirstSample) {
      _completePendingMeasure(
        SmartRingMeasureType.bloodPressure,
        _lastBloodPressureData!,
      );
    }
  }

  void _markInterrupted(String message) {
    _failPendingMeasure(StateError(message));
    _updateState(SmartRingMeasureState.error);
    _onError?.call(message);
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (_currentState == SmartRingMeasureState.error) {
        _updateState(SmartRingMeasureState.idle);
      }
    });
  }

  void _markSuccessThenIdle() {
    _updateState(SmartRingMeasureState.success);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (_currentState == SmartRingMeasureState.success) {
        _updateState(SmartRingMeasureState.idle);
      }
    });
  }

  void _updateState(SmartRingMeasureState newState) {
    if (_currentState == newState) {
      return;
    }
    _currentState = newState;
    _onStateChanged?.call(newState);
  }

  void _completePendingMeasure(SmartRingMeasureType type, Object result) {
    if (_pendingMeasureType != type) {
      return;
    }
    final Completer<Object>? completer = _pendingMeasureCompleter;
    if (completer == null || completer.isCompleted) {
      return;
    }
    if (_pendingMeasureStopsOnFirstSample) {
      _lockedFirstSampleType = type;
    }
    completer.complete(result);
    _pendingMeasureCompleter = null;
    _pendingMeasureType = null;
  }

  void _failPendingMeasure(Object error) {
    final Completer<Object>? completer = _pendingMeasureCompleter;
    if (completer == null || completer.isCompleted) {
      return;
    }
    completer.completeError(error);
    _pendingMeasureCompleter = null;
    _pendingMeasureType = null;
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
    _isCombinedMeasurementRunning = false;
    _currentState = SmartRingMeasureState.idle;
    _isCheckingLowSpO2 = false;
    _lowSpO2Values.clear();
    _currentBloodPressureMeasurements.clear();
    _onHeartRateData = null;
    _onSpO2Data = null;
    _onBloodPressureData = null;
    _onStateChanged = null;
    _onError = null;
    _onMeasureCompleted = null;
    _onBloodPressureMeasureCompleted = null;
    _pendingMeasureCompleter = null;
    _pendingMeasureType = null;
    _pendingMeasureStopsOnFirstSample = false;
    _lockedFirstSampleType = null;
    _isCancellationRequested = false;
  }
}
