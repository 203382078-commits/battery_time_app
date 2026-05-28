import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/statistics.dart';
import '../services/storage_service.dart';

/// 电池状态提供者，管理所有电池相关状态和逻辑
class BatteryProvider extends ChangeNotifier {
  final Battery _battery = Battery();
  final StorageService _storage = StorageService();

  int _batteryLevel = 0;
  bool _isCharging = false;
  BatteryStatistics _statistics = BatteryStatistics();

  // 前台计时相关
  bool _isAppInForeground = false;

  // 前台亮屏计时（断开充电后）
  Timer? _screenOnTimer;

  // 电池状态监听
  StreamSubscription? _batteryStateSubscription;

  // Getter
  int get batteryLevel => _batteryLevel;
  bool get isCharging => _isCharging;
  BatteryStatistics get statistics => _statistics;

  /// 初始化 Provider
  Future<void> init() async {
    await _storage.init();
    _statistics = _storage.loadStatistics();

    try {
      _batteryLevel = await _battery.batteryLevel;
      _batteryStateSubscription = _battery.onBatteryStateChanged.listen(
        _onBatteryStateChanged,
      );
    } catch (_) {}

    // 如果已断开充电且在前台，恢复亮屏计时
    if (!_isCharging &&
        _statistics.chargeEndTime != null &&
        _isAppInForeground) {
      _startScreenOnTimer();
    }

    notifyListeners();
  }

  /// 处理电池状态变化
  void _onBatteryStateChanged(BatteryState state) {
    final newCharging =
        state == BatteryState.charging || state == BatteryState.full;

    if (newCharging == _isCharging) return;
    _isCharging = newCharging;

    if (_isCharging) {
      // ======== 开始充电 ========
      _statistics = BatteryStatistics(
        lastFullChargeDisconnectTime:
            _statistics.lastFullChargeDisconnectTime,
        totalForegroundSeconds: _statistics.totalForegroundSeconds,
        lastChargeStartLevel: _batteryLevel,
        chargeEndTime: _statistics.chargeEndTime,
        screenOnSecondsAfterCharge: _statistics.screenOnSecondsAfterCharge,
        chargeStartTime: DateTime.now(),
        chargeEndLevel: _statistics.chargeEndLevel,
      );
      _stopScreenOnTimer();
    } else {
      // ======== 结束充电 ========
      _statistics = BatteryStatistics(
        lastFullChargeDisconnectTime:
            _statistics.lastFullChargeDisconnectTime,
        totalForegroundSeconds: _statistics.totalForegroundSeconds,
        lastChargeStartLevel: _statistics.lastChargeStartLevel,
        chargeEndTime: DateTime.now(),
        screenOnSecondsAfterCharge: 0,
        chargeStartTime: _statistics.chargeStartTime,
        chargeEndLevel: _batteryLevel,
      );

      if (_isAppInForeground) {
        _startScreenOnTimer();
      }
    }

    _saveData();
    notifyListeners();
  }

  /// 更新电量（由定时器周期性调用）
  Future<void> updateBatteryLevel() async {
    try {
      final level = await _battery.batteryLevel;
      if (level != _batteryLevel) {
        _batteryLevel = level;
        await _storage.saveBatteryRecord(
          level: _batteryLevel,
          isCharging: _isCharging,
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  // ---- 前台运行时长相关 ----

  /// 应用进入前台
  void onAppForeground() {
    if (_isAppInForeground) return;
    _isAppInForeground = true;

    if (!_isCharging && _statistics.chargeEndTime != null) {
      _startScreenOnTimer();
    }
  }

  /// 应用进入后台
  void onAppBackground() {
    if (!_isAppInForeground) return;
    _isAppInForeground = false;
    _stopScreenOnTimer();
  }

  /// 启动亮屏计时器（每秒 +1）
  void _startScreenOnTimer() {
    _screenOnTimer?.cancel();
    _screenOnTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _statistics = BatteryStatistics(
        lastFullChargeDisconnectTime:
            _statistics.lastFullChargeDisconnectTime,
        totalForegroundSeconds: _statistics.totalForegroundSeconds,
        lastChargeStartLevel: _statistics.lastChargeStartLevel,
        chargeEndTime: _statistics.chargeEndTime,
        screenOnSecondsAfterCharge:
            _statistics.screenOnSecondsAfterCharge + 1,
        chargeStartTime: _statistics.chargeStartTime,
        chargeEndLevel: _statistics.chargeEndLevel,
      );
      _saveData();
      notifyListeners();
    });
  }

  /// 停止亮屏计时器
  void _stopScreenOnTimer() {
    _screenOnTimer?.cancel();
    _screenOnTimer = null;
  }

  // ---- 工具方法 ----

  Future<void> _saveData() async {
    await _storage.saveStatistics(_statistics);
  }

  /// 重置所有统计数据
  Future<void> resetStatistics() async {
    _statistics = BatteryStatistics();
    _stopScreenOnTimer();
    await _storage.clearAll();
    notifyListeners();
  }

  @override
  void dispose() {
    _batteryStateSubscription?.cancel();
    _stopScreenOnTimer();
    super.dispose();
  }
}
