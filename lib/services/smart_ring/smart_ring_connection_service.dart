import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yc_product_plugin/yc_product_plugin.dart';

import 'smart_ring_event_bus.dart';
import 'smart_ring_storage_service.dart';

class SmartRingConnectionService {
  SmartRingConnectionService._();

  static final SmartRingConnectionService instance =
      SmartRingConnectionService._();

  final ValueNotifier<bool> isInitializingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isScanningNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isConnectingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<int> bluetoothStateNotifier = ValueNotifier<int>(
    BluetoothState.disconnected,
  );
  final ValueNotifier<List<BluetoothDevice>> scanResultsNotifier =
      ValueNotifier<List<BluetoothDevice>>(<BluetoothDevice>[]);
  final ValueNotifier<BluetoothDevice?> connectedDeviceNotifier =
      ValueNotifier<BluetoothDevice?>(null);

  StreamSubscription<Map<dynamic, dynamic>>? _eventSubscription;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      await refreshConnectionState();
      return;
    }

    isInitializingNotifier.value = true;
    try {
      await YcProductPlugin().initPlugin(
        isReconnectEnable: true,
        isLogEnable: kDebugMode,
      );
      SmartRingEventBus.instance.ensureListening();
      _eventSubscription = SmartRingEventBus.instance.events.listen(
        _handleNativeEvent,
      );
      _initialized = true;
      await refreshConnectionState();
    } finally {
      isInitializingNotifier.value = false;
    }
  }

  Future<bool> ensurePermissions() async {
    if (Platform.isAndroid) {
      final statuses = await <Permission>[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();

      return statuses.values.every((status) => status.isGranted);
    }

    if (Platform.isIOS) {
      final bluetoothStatus = await Permission.bluetooth.request();
      return bluetoothStatus.isGranted || bluetoothStatus.isLimited;
    }

    return true;
  }

  Future<void> refreshConnectionState() async {
    final int state =
        await YcProductPlugin().getBluetoothState() ??
        BluetoothState.disconnected;
    final bool connected = await isDeviceConnected(rawState: state);
    final BluetoothDevice? cachedDevice =
        YcProductPlugin().connectedDevice ??
        await SmartRingStorageService.getSavedDevice();

    bluetoothStateNotifier.value = connected
        ? BluetoothState.connected
        : _normalizeState(state);
    connectedDeviceNotifier.value = connected ? cachedDevice : null;
  }

  Future<bool> isDeviceConnected({int? rawState}) async {
    final int state =
        rawState ??
        await YcProductPlugin().getBluetoothState() ??
        BluetoothState.disconnected;

    if (state == BluetoothState.connected) {
      return true;
    }

    if (Platform.isIOS &&
        state == BluetoothState.on &&
        YcProductPlugin().connectedDevice != null) {
      return true;
    }

    return false;
  }

  Future<void> startScan() async {
    await initialize();

    final bool hasPermissions = await ensurePermissions();
    if (!hasPermissions) {
      throw Exception(
        'Chưa được cấp đủ quyền Bluetooth/Vị trí để quét Smart Ring.',
      );
    }

    isScanningNotifier.value = true;
    scanResultsNotifier.value = <BluetoothDevice>[];

    try {
      final List<BluetoothDevice>? devices = await YcProductPlugin().scanDevice(
        time: 6,
        isWatch: false,
      );
      scanResultsNotifier.value = devices ?? <BluetoothDevice>[];
      await refreshConnectionState();
    } finally {
      isScanningNotifier.value = false;
    }
  }

  Future<void> connectDevice(BluetoothDevice device) async {
    await initialize();
    isConnectingNotifier.value = true;

    try {
      final bool? connected = await YcProductPlugin().connectDevice(device);
      if (connected != true) {
        throw Exception('Không thể kết nối tới ${device.name}.');
      }

      YcProductPlugin().connectedDevice = device;
      connectedDeviceNotifier.value = device;
      bluetoothStateNotifier.value = BluetoothState.connected;
      await SmartRingStorageService.saveDevice(device);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await refreshConnectionState();
    } finally {
      isConnectingNotifier.value = false;
    }
  }

  Future<void> disconnectDevice() async {
    await initialize();
    await YcProductPlugin().disconnectDevice();
    YcProductPlugin().connectedDevice = null;
    connectedDeviceNotifier.value = null;
    bluetoothStateNotifier.value = BluetoothState.disconnected;
    await SmartRingStorageService.clearDevice();
  }

  int _normalizeState(int state) {
    if (state == BluetoothState.connectFailed) {
      return BluetoothState.disconnected;
    }
    return state;
  }

  void _handleNativeEvent(Map<dynamic, dynamic> event) {
    final int? bluetoothState = event[NativeEventType.bluetoothStateChange];
    if (bluetoothState == null) {
      return;
    }

    final int normalizedState = _normalizeState(bluetoothState);
    bluetoothStateNotifier.value = normalizedState;

    if (normalizedState == BluetoothState.connected) {
      connectedDeviceNotifier.value =
          YcProductPlugin().connectedDevice ?? connectedDeviceNotifier.value;
      return;
    }

    if (normalizedState == BluetoothState.off ||
        normalizedState == BluetoothState.disconnected) {
      connectedDeviceNotifier.value = null;
    }
  }

  void dispose() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }
}
