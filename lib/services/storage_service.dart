import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/statistics.dart';

/// 本地存储服务，用于持久化统计数据
class StorageService {
  static const String _statisticsKey = 'battery_statistics';
  static const String _batteryHistoryKey = 'battery_history';
  static const int _maxHistoryRecords = 1000;

  late SharedPreferences _prefs;

  /// 初始化 SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 保存统计数据
  Future<void> saveStatistics(BatteryStatistics stats) async {
    final json = jsonEncode(stats.toJson());
    await _prefs.setString(_statisticsKey, json);
  }

  /// 读取统计数据
  BatteryStatistics loadStatistics() {
    final jsonStr = _prefs.getString(_statisticsKey);
    if (jsonStr == null) return BatteryStatistics();
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return BatteryStatistics.fromJson(json);
    } catch (e) {
      return BatteryStatistics();
    }
  }

  /// 保存历史电量记录
  Future<void> saveBatteryRecord({
    required int level,
    required bool isCharging,
  }) async {
    final records = _loadBatteryHistory();
    records.add({
      'level': level,
      'isCharging': isCharging,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // 限制记录数量，保留最新的
    while (records.length > _maxHistoryRecords) {
      records.removeAt(0);
    }

    await _prefs.setString(_batteryHistoryKey, jsonEncode(records));
  }

  /// 加载历史电量记录
  List<Map<String, dynamic>> _loadBatteryHistory() {
    final jsonStr = _prefs.getString(_batteryHistoryKey);
    if (jsonStr == null) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// 获取最近的历史记录（用于显示图表）
  List<Map<String, dynamic>> getRecentHistory({int count = 50}) {
    final records = _loadBatteryHistory();
    if (records.length <= count) return records;
    return records.sublist(records.length - count);
  }

  /// 清除所有数据
  Future<void> clearAll() async {
    await _prefs.remove(_statisticsKey);
    await _prefs.remove(_batteryHistoryKey);
  }
}
