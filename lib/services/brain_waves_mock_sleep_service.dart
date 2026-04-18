import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class BrainWavesMockSleepService {
  BrainWavesMockSleepService._();

  static const String _summaryStorageKey = 'brain_waves_mock_sleep_summary';
  static const String _summaryVersionStorageKey =
      'brain_waves_mock_sleep_summary_version';
  static const int _summaryVersion = 3;

  static const Map<String, Object> _defaultSummary = <String, Object>{
    'totalTime': 392,
    'score': 78,
    'quality': 'Giấc ngủ trung bình',
    'lightSleep': 204,
    'deepSleep': 116,
    'remSleep': 72,
    'awakeCount': 1,
    'sessionsCount': 1,
    'startTime': '23:41',
    'endTime': '06:13',
    'hasRealData': false,
  };

  static Map<String, dynamic> get defaultSummary =>
      Map<String, dynamic>.from(_defaultSummary);

  static Future<Map<String, dynamic>> loadSummary() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int storedVersion = prefs.getInt(_summaryVersionStorageKey) ?? 0;
    String? raw = prefs.getString(_summaryStorageKey);

    if (raw == null || raw.isEmpty || storedVersion < _summaryVersion) {
      final Map<String, dynamic> seeded = defaultSummary;
      await _saveSummary(prefs, seeded);
      return seeded;
    }

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) {
        throw const FormatException('Mock sleep summary is not a map');
      }
      return <String, dynamic>{
        ...defaultSummary,
        ...Map<String, dynamic>.from(decoded),
      };
    } catch (_) {
      final Map<String, dynamic> seeded = defaultSummary;
      await _saveSummary(prefs, seeded);
      return seeded;
    }
  }

  static Future<Map<String, dynamic>> regenerateSummary() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Random random = Random();

    final int totalTime = 360 + random.nextInt(95);
    final int deepSleep = 85 + random.nextInt(55);
    final int remSleep = 60 + random.nextInt(35);
    final int lightSleep = max(totalTime - deepSleep - remSleep, 150);
    final int awakeCount = random.nextInt(3);
    final int score = 70 + random.nextInt(16);
    final String quality = score >= 82
        ? 'Giấc ngủ tốt'
        : score >= 74
        ? 'Giấc ngủ trung bình'
        : 'Giấc ngủ kém';

    final int bedtimeMinute = 20 + random.nextInt(50);
    final int bedtimeHour = random.nextBool() ? 22 : 23;
    final int wakeMinuteTotal =
        bedtimeHour * 60 + bedtimeMinute + totalTime + awakeCount * 8;
    final int wakeHour = (wakeMinuteTotal ~/ 60) % 24;
    final int wakeMinute = wakeMinuteTotal % 60;

    final Map<String, dynamic> summary = <String, dynamic>{
      'totalTime': totalTime,
      'score': score,
      'quality': quality,
      'lightSleep': lightSleep,
      'deepSleep': deepSleep,
      'remSleep': remSleep,
      'awakeCount': awakeCount,
      'sessionsCount': 1,
      'startTime': _formatTime(bedtimeHour, bedtimeMinute),
      'endTime': _formatTime(wakeHour, wakeMinute),
      'hasRealData': false,
    };

    await _saveSummary(prefs, summary);
    return summary;
  }

  static Future<void> _saveSummary(
    SharedPreferences prefs,
    Map<String, dynamic> summary,
  ) async {
    await prefs.setString(_summaryStorageKey, jsonEncode(summary));
    await prefs.setInt(_summaryVersionStorageKey, _summaryVersion);
  }

  static String _formatTime(int hour, int minute) {
    final String hh = hour.toString().padLeft(2, '0');
    final String mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
