/// 电池数据模型
class BatteryData {
  final int level;        // 电量百分比 0-100
  final bool isCharging;  // 是否正在充电
  final DateTime timestamp;

  BatteryData({
    required this.level,
    required this.isCharging,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'level': level,
    'isCharging': isCharging,
    'timestamp': timestamp.toIso8601String(),
  };

  factory BatteryData.fromJson(Map<String, dynamic> json) => BatteryData(
    level: json['level'] as int,
    isCharging: json['isCharging'] as bool,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}
