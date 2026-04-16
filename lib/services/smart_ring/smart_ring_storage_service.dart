import 'package:shared_preferences/shared_preferences.dart';
import 'package:yc_product_plugin/yc_product_plugin.dart';

class SmartRingStorageService {
  SmartRingStorageService._();

  static const String _keyDeviceName = 'smart_ring_device_name';
  static const String _keyDeviceIdentifier = 'smart_ring_device_identifier';
  static const String _keyMacAddress = 'smart_ring_mac_address';
  static const String _keyDeviceBunId = 'smart_ring_device_bun_id';

  static Future<void> saveDevice(BluetoothDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDeviceName, device.name);
    await prefs.setString(_keyDeviceIdentifier, device.deviceIdentifier);
    await prefs.setString(_keyMacAddress, device.macAddress);
    await prefs.setString(_keyDeviceBunId, device.deviceBunId);
  }

  static Future<BluetoothDevice?> getSavedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceName = prefs.getString(_keyDeviceName);
    final deviceIdentifier = prefs.getString(_keyDeviceIdentifier);

    if (deviceName == null ||
        deviceName.isEmpty ||
        deviceIdentifier == null ||
        deviceIdentifier.isEmpty) {
      return null;
    }

    return BluetoothDevice.formJson({
      'name': deviceName,
      'deviceIdentifier': deviceIdentifier,
      'macAddress': prefs.getString(_keyMacAddress) ?? '',
      'deviceBunId': prefs.getString(_keyDeviceBunId) ?? '',
      'rssiValue': 0,
    });
  }

  static Future<void> clearDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDeviceName);
    await prefs.remove(_keyDeviceIdentifier);
    await prefs.remove(_keyMacAddress);
    await prefs.remove(_keyDeviceBunId);
  }
}
