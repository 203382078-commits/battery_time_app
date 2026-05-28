import 'package:flutter/cupertino.dart';

/// 统计卡片组件
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).barBackgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CupertinoColors.systemGrey5,
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: iconColor ?? CupertinoColors.systemBlue,
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
