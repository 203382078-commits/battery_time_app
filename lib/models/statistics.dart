/// 统计数据模型
class BatteryStatistics {
  /// 最近一次充满断开充电的时间
  final DateTime? lastFullChargeDisconnectTime;

  /// 累计前台运行秒数
  final int totalForegroundSeconds;

  /// 上次充电开始时的电量百分比
  final int? lastChargeStartLevel;

  /// 上次充电结束时间（断开充电的时刻）
  final DateTime? chargeEndTime;

  /// 距离上次充电后的前台累计亮屏秒数
  final int screenOnSecondsAfterCharge;

  BatteryStatistics({
    this.lastFullChargeDisconnectTime,
    this.totalForegroundSeconds = 0,
    this.lastChargeStartLevel,
    this.chargeEndTime,
    this.screenOnSecondsAfterCharge = 0,
  });

  /// 获取格式化的仪表盘时间字符串（从充满断开起）
  String get formattedSinceFullCharge {
    if (lastFullChargeDisconnectTime == null) return '--:--:--';
    final duration = DateTime.now().difference(lastFullChargeDisconnectTime!);
    return _formatDuration(duration);
  }

  /// 获取格式化的前台运行时长
  String get formattedForegroundTime {
    return _formatDuration(Duration(seconds: totalForegroundSeconds));
  }

  /// 格式化上次充电后的亮屏时间
  String get formattedScreenOnTime {
    return _formatDuration(Duration(seconds: screenOnSecondsAfterCharge));
  }

  /// 上次充电起始电量的描述文本
  String get lastStartLevelText {
    if (lastChargeStartLevel == null) return '暂无充电记录';
    return '上次从 $lastChargeStartLevel% 开始充电';
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Map<String, dynamic> toJson() => {
    'lastFullChargeDisconnectTime':
        lastFullChargeDisconnectTime?.toIso8601String(),
    'totalForegroundSeconds': totalForegroundSeconds,
    'lastChargeStartLevel': lastChargeStartLevel,
    'chargeEndTime': chargeEndTime?.toIso8601String(),
    'screenOnSecondsAfterCharge': screenOnSecondsAfterCharge,
  };

  factory BatteryStatistics.fromJson(Map<String, dynamic> json) =>
      BatteryStatistics(
        lastFullChargeDisconnectTime:
            json['lastFullChargeDisconnectTime'] != null
                ? DateTime.parse(json['lastFullChargeDisconnectTime'] as String)
                : null,
        totalForegroundSeconds: json['totalForegroundSeconds'] as int? ?? 0,
        lastChargeStartLevel: json['lastChargeStartLevel'] as int?,
        chargeEndTime: json['chargeEndTime'] != null
            ? DateTime.parse(json['chargeEndTime'] as String)
            : null,
        screenOnSecondsAfterCharge: json['screenOnSecondsAfterCharge'] as int? ?? 0,
      );
}

