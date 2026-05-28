import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/battery_provider.dart';
import '../widgets/battery_indicator.dart';
import '../widgets/stats_card.dart';

/// 主页 - iOS 风格电池统计界面
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBatteryUpdates();
    });
  }

  void _startBatteryUpdates() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return false;
      context.read<BatteryProvider>().updateBatteryLevel();
      return true;
    });
  }

  void _showResetConfirmation() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('重置统计数据'),
        content: const Text('确定要清除所有统计数据吗？此操作不可撤销。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('重置'),
            onPressed: () {
              Navigator.of(context).pop();
              context.read<BatteryProvider>().resetStatistics();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 根据屏幕高度动态调整间距
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final verticalSpacing = isSmallScreen ? 16.0 : 24.0;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('电池统计'),
        trailing: GestureDetector(
          onTap: _showResetConfirmation,
          child: const Icon(
            CupertinoIcons.trash,
            size: 22,
            color: CupertinoColors.destructiveRed,
          ),
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Consumer<BatteryProvider>(
              builder: (context, provider, _) {
                return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: isSmallScreen ? 8 : 20,
              ),
              child: Column(
                children: [
                  // 电量指示器
                  Center(
                    child: BatteryIndicator(
                      level: provider.batteryLevel,
                      isCharging: provider.isCharging,
                    ),
                  ),

                  SizedBox(height: verticalSpacing),
                  // 充电状态标签
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                  decoration: BoxDecoration(
                        color: provider.isCharging
                            ? CupertinoColors.systemGreen.withValues(alpha: 0.15)
                            : CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(20),
                  ),
                      child: Text(
                        provider.isCharging ? '⚡ 充电中' : '🔋 未充电',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: provider.isCharging
                              ? CupertinoColors.systemGreen
                              : CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: verticalSpacing),

                  // 统计卡片网格
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: '上次充电后\n亮屏',
                          value: provider.statistics.formattedScreenOnTime,
                          icon: CupertinoIcons.clock_fill,
                          iconColor: CupertinoColors.systemBlue,
                        ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          title: 'App 前台\n运行时长',
                          value: provider.statistics.formattedForegroundTime,
                          icon: CupertinoIcons.square_grid_2x2_fill,
                          iconColor: CupertinoColors.systemPurple,
                        ),
                  ),
                    ],
                  ),

                  SizedBox(height: verticalSpacing),

                  // 充电记录与说明
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.statistics.lastStartLevelText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• 开始充电时自动记录起始电量\n'
                          '• 断开充电后开始累计亮屏时间\n'
                          '• App 在前台运行时长自动累计\n'
                          '• 所有数据保存在本地设备中',
                          style: TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.secondaryLabel,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 底部留白
                  SizedBox(height: isSmallScreen ? 20 : 40),
                ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

