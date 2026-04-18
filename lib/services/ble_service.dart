import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleDeviceInfo {
  const BleDeviceInfo({required this.id, required this.name, this.rssi});

  final String id;
  final String name;
  final int? rssi;
}

class BleService {
  BleService._();

  static final BleService instance = BleService._();

  static final Guid serviceUuid = Guid('4fafc201-1fb5-459e-8fcc-c5c9c331914b');
  static final Guid characteristicUuid = Guid(
    'beb5483e-36e1-4688-b7f5-ea07361b26a8',
  );
  static const String targetName = 'ESP32S3_TOUCH';

  final ValueNotifier<bool> isScanningNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<List<BleDeviceInfo>> scanResultsNotifier =
      ValueNotifier<List<BleDeviceInfo>>(<BleDeviceInfo>[]);
  final ValueNotifier<String?> connectedDeviceNameNotifier =
      ValueNotifier<String?>(null);
  final ValueNotifier<bool?> touchDetectedNotifier = ValueNotifier<bool?>(null);

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _characteristic;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _notifySubscription;

  /// Rate-limit: track last scan start time to avoid Android's 5-in-30s limit.
  DateTime _lastScanStart = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _minScanInterval = Duration(seconds: 6);
  bool _scanInProgress = false;

  /// Debounce touch state changes: only commit after 1s of stable signal.
  Timer? _touchDebounceTimer;
  static const Duration _touchDebounceDuration = Duration(seconds: 1);

  Future<bool> _ensurePermissions() async {
    if (Platform.isAndroid) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();

      final allGranted = statuses.values.every(
        (s) => s == PermissionStatus.granted,
      );
      if (!allGranted) {
        debugPrint('[BLE] Permissions not granted: $statuses');
        return false;
      }
    }
    return true;
  }

  Future<void> startScan() async {
    // Guard: prevent concurrent scans
    if (_scanInProgress) {
      debugPrint('[BLE] startScan ignored — scan already in progress');
      return;
    }

    // Rate limit: Android blocks >5 scans per 30 seconds
    final now = DateTime.now();
    final elapsed = now.difference(_lastScanStart);
    if (elapsed < _minScanInterval) {
      debugPrint(
        '[BLE] startScan throttled — wait ${(_minScanInterval - elapsed).inSeconds}s',
      );
      return;
    }

    final hasPermission = await _ensurePermissions();
    if (!hasPermission) {
      isScanningNotifier.value = false;
      return;
    }

    _scanInProgress = true;
    _lastScanStart = now;

    await stopScan();
    scanResultsNotifier.value = <BleDeviceInfo>[];
    isScanningNotifier.value = true;

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      final Map<String, BleDeviceInfo> devices = <String, BleDeviceInfo>{
        for (final BleDeviceInfo item in scanResultsNotifier.value)
          item.id: item,
      };

      for (final result in results) {
        if (!_matchesTarget(result)) {
          continue;
        }

        final name = _displayName(
          result.device.platformName,
          result.advertisementData.advName,
        );
        devices[result.device.remoteId.str] = BleDeviceInfo(
          id: result.device.remoteId.str,
          name: name,
          rssi: result.rssi,
        );
      }

      scanResultsNotifier.value = devices.values.toList()
        ..sort((a, b) => (b.rssi ?? -999).compareTo(a.rssi ?? -999));
    });

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 4),
      withServices: <Guid>[serviceUuid],
    );

    _scanInProgress = false;
    isScanningNotifier.value = false;
  }

  Future<void> stopScan() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }
    _scanInProgress = false;
    isScanningNotifier.value = false;
  }

  Future<void> connect(BleDeviceInfo info) async {
    await stopScan();
    await disconnect();

    final device = BluetoothDevice.fromId(info.id);
    _connectedDevice = device;

    _connectionSubscription = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        connectedDeviceNameNotifier.value = null;
        touchDetectedNotifier.value = null;
        _characteristic = null;
      }
    });

    await device.connect(timeout: const Duration(seconds: 10));
    connectedDeviceNameNotifier.value = info.name;

    final services = await device.discoverServices();
    for (final service in services) {
      if (service.uuid != serviceUuid) {
        continue;
      }
      for (final characteristic in service.characteristics) {
        if (characteristic.uuid == characteristicUuid) {
          _characteristic = characteristic;
          break;
        }
      }
    }

    final characteristic = _characteristic;
    if (characteristic == null) {
      await disconnect();
      throw Exception('Không tìm thấy characteristic BLE của ESP32.');
    }

    await characteristic.setNotifyValue(true);
    // Use onValueReceived so we only process actual device reads/notifications,
    // not our own write payloads echoed by lastValueStream.
    _notifySubscription = characteristic.onValueReceived.listen(_handlePayload);
    debugPrint('[BLE] Notify subscription active, reading initial state...');
    await characteristic.read();
    debugPrint(
      '[BLE] Initial state read complete. touchDetected=${touchDetectedNotifier.value}',
    );

    // Force firmware back to AUTO sensing mode in case a previous manual test
    // left the ESP32 stuck at a constant true/false state.
    debugPrint('[BLE] Sending auto mode command to ESP32 touch monitor...');
    await sendCommand('auto');
    await Future<void>.delayed(const Duration(milliseconds: 250));
    await characteristic.read();
    debugPrint(
      '[BLE] Auto mode confirmed. touchDetected=${touchDetectedNotifier.value}',
    );
  }

  Future<void> disconnect() async {
    _touchDebounceTimer?.cancel();
    _touchDebounceTimer = null;
    await _notifySubscription?.cancel();
    _notifySubscription = null;
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    final device = _connectedDevice;
    _connectedDevice = null;
    _characteristic = null;
    connectedDeviceNameNotifier.value = null;
    touchDetectedNotifier.value = null;

    if (device != null) {
      try {
        await device.disconnect();
      } catch (_) {}
    }
  }

  Future<void> sendCommand(String command) async {
    final characteristic = _characteristic;
    if (characteristic == null) {
      return;
    }
    await characteristic.write(utf8.encode(command), withoutResponse: false);
  }

  bool _matchesTarget(ScanResult result) {
    final advertisedName = result.advertisementData.advName;
    final platformName = result.device.platformName;
    final serviceMatch = result.advertisementData.serviceUuids.any(
      (uuid) =>
          uuid.toString().toLowerCase() == serviceUuid.str128.toLowerCase(),
    );

    return advertisedName == targetName ||
        platformName == targetName ||
        serviceMatch;
  }

  String _displayName(String platformName, String advertisedName) {
    if (advertisedName.isNotEmpty) {
      return advertisedName;
    }
    if (platformName.isNotEmpty) {
      return platformName;
    }
    return targetName;
  }

  void _handlePayload(List<int> raw) {
    if (raw.isEmpty) {
      return;
    }

    final payload = utf8.decode(raw, allowMalformed: true).trim().toLowerCase();
    debugPrint('[BLE] payload received: "$payload" (${raw.length} bytes)');
    if (payload == 'true') {
      debugPrint('[BLE] Touch event → TOUCHING (debounce 1s)');
      _debounceTouchState(true);
    } else if (payload == 'false') {
      debugPrint('[BLE] Touch event → NOT TOUCHING (debounce 1s)');
      _debounceTouchState(false);
    } else {
      debugPrint('[BLE] Unknown payload ignored: "$payload"');
    }
  }

  void _debounceTouchState(bool newValue) {
    _touchDebounceTimer?.cancel();
    // If the value is already the same, nothing to do.
    if (touchDetectedNotifier.value == newValue) return;
    _touchDebounceTimer = Timer(_touchDebounceDuration, () {
      debugPrint('[BLE] Touch state committed → $newValue (stable for 1s)');
      touchDetectedNotifier.value = newValue;
    });
  }
}
