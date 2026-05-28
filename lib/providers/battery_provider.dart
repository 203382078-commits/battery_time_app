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
  Timer? _foregroundTimer;
  bool _isAppInForeground = false;
  DateTime? _foregroundStartTime;

  // 充电断开计时相关
  Timer? _fullChargeTimer;
  bool _hasTriggeredFullChargeTimer = false;

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

    // 获取当前电池状态
    _batteryLevel = await _battery.batteryLevel;
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen(
      _onBatteryStateChanged,
    );

    // 恢复充电断开计时状态
    _restoreFullChargeTimer();

    notifyListeners();
  }

  /// 恢复充满电断开后的计时
  void _restoreFullChargeTimer() {
    if (_statistics.lastFullChargeDisconnectTime != null) {
      _hasTriggeredFullChargeTimer = true;
      _startFullChargeTimer();
    }
  }

  /// 处理电池状态变化
  void _onBatteryStateChanged(BatteryState state) {
    final newCharging = state == BatteryState.charging ||
        state == BatteryState.full;

    // 如果充电状态发生了变化
    if (newCharging != _isCharging) {
      _isCharging = newCharging;

      // 充满电后断开充电 -> 开始计时
      if (!_isCharging &&
          _batteryLevel >= 100 &&
          !_hasTriggeredFullChargeTimer) {
        _statistics = BatteryStatistics(
          lastFullChargeDisconnectTime: DateTime.now(),
          totalForegroundSeconds: _statistics.totalForegroundSeconds,
        );
        _hasTriggeredFullChargeTimer = true;
        _startFullChargeTimer();
        _saveData();
      }

      // 开始充电 -> 重置计时状态
      if (_isCharging) {
        _hasTriggeredFullChargeTimer = false;
        _statistics = BatteryStatistics(
          lastFullChargeDisconnectTime: null,
          totalForegroundSeconds: _statistics.totalForegroundSeconds,
        );
        _stopFullChargeTimer();
        _saveData();
      }
    }

    notifyListeners();
  }

  /// 更新电量（由定时器周期性调用）
  Future<void> updateBatteryLevel() async {
    final level = await _battery.batteryLevel;

    if (level != _batteryLevel) {
      _batteryLevel = level;

      // 保存历史记录
      await _storage.saveBatteryRecord(
        level: _batteryLevel,
        isCharging: _isCharging,
      );

      // 达到100%并且正在充电
      if (_batteryLevel >= 100 && _isCharging) {
        _hasTriggeredFullChargeTimer = false; // 重置，等待断开时触发
      }

      notifyListeners();
    }
  }

  // ---- 前台运行时长相关 ----

  /// 应用进入前台
  void onAppForeground() {
    if (_isAppInForeground) return;
    _isAppInForeground = true;
    _foregroundStartTime = DateTime.now();

    // 启动前台计时器
    _foregroundTimer?.cancel();
    _foregroundTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateForegroundTime();
    });
  }

  /// 应用进入后台
  void onAppBackground() {
    if (!_isAppInForeground) return;
    _isAppInForeground = false;

    // 立即更新一次前台时间
    _updateForegroundTime();
    _foregroundTimer?.cancel();
    _foregroundTimer = null;
    _foregroundStartTime = null;
  }

  /// 更新前台累计运行时间
  void _updateForegroundTime() {
    if (_foregroundStartTime == null) return;
    final elapsed =
        DateTime.now().difference(_foregroundStartTime!).inSeconds;
    if (elapsed > 0) {
      _statistics = BatteryStatistics(
        lastFullChargeDisconnectTime:
            _statistics.lastFullChargeDisconnectTime,
        totalForegroundSeconds: _statistics.totalForegroundSeconds + elapsed,
      );
      _foregroundStartTime = DateTime.now();
      _saveData();
      notifyListeners();
    }
  }

  // ---- 充满电断开计时器 ----

  void _startFullChargeTimer() {
    _fullChargeTimer?.cancel();
    _fullChargeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  void _stopFullChargeTimer() {
    _fullChargeTimer?.cancel();
    _fullChargeTimer = null;
  }

  // ---- 工具方法 ----

  Future<void> _saveData() async {
    await _storage.saveStatistics(_statistics);
  }

  /// 重置所有统计数据
  Future<void> resetStatistics() async {
    _statistics = BatteryStatistics();
    _hasTriggeredFullChargeTimer = false;
    _stopFullChargeTimer();
    await _storage.clearAll();
    notifyListeners();
  }

  @override
  void dispose() {
    _batteryStateSubscription?.cancel();
    _foregroundTimer?.cancel();
    _fullChargeTimer?.cancel();
    super.dispose();
  }
}
