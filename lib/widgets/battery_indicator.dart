import 'package:flutter/cupertino.dart';

/// 电池图标指示器组件
class BatteryIndicator extends StatelessWidget {
  final int level;
  final bool isCharging;

  const BatteryIndicator({
    super.key,
    required this.level,
    required this.isCharging,
  });

  @override
  Widget build(BuildContext context) {
    // 根据屏幕高度决定电池大小
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final batteryHeight = isSmallScreen ? 100.0 : 130.0;
    final batteryWidth = isSmallScreen ? 60.0 : 75.0;
    final fontSize = isSmallScreen ? 28.0 : 34.0;

    return SizedBox(
      width: batteryWidth + 40,
      height: isSmallScreen ? 185 : 225,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBatteryBody(batteryHeight, batteryWidth),
          const SizedBox(height: 12),
          Text(
            '$level%',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          if (isCharging) ...[
            const SizedBox(height: 6),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.bolt_fill,
                  size: 18,
                  color: CupertinoColors.systemGreen,
                ),
                SizedBox(width: 4),
                Text(
                  '正在充电',
                  style: TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.systemGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBatteryBody(double bodyHeight, double bodyWidth) {
    // 根据电量决定颜色
    final Color batteryColor;
    if (level >= 80) {
      batteryColor = CupertinoColors.systemGreen;
    } else if (level >= 30) {
      batteryColor = CupertinoColors.systemOrange;
    } else {
      batteryColor = CupertinoColors.systemRed;
    }

    final fillColor = isCharging ? CupertinoColors.systemGreen : batteryColor;
    final capWidth = (bodyWidth * 0.35).clamp(20.0, 30.0);
    final capHeight = (bodyHeight * 0.04).clamp(4.0, 6.0);

    return SizedBox(
      width: bodyWidth,
      height: bodyHeight + capHeight + 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 电池头（正极凸起）
          Container(
            width: capWidth,
            height: capHeight,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey4,
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(3),
              ),
            ),
          ),
          // 电池主体
          Container(
            width: bodyWidth,
            height: bodyHeight,
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: CupertinoColors.systemGrey3,
                  width: 2.5,
                ),
              ),
              child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
                child: Column(
                  children: [
                    // 空电量部分
                    Expanded(
                      flex: 100 - level,
                      child: Container(
                        color: CupertinoColors.systemGrey6,
                      ),
                    ),
                    // 有电量部分
                    Expanded(
                      flex: level,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                            fillColor.withValues(alpha: 0.7),
                              fillColor,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

