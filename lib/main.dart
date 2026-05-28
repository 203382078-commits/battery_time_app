import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'providers/battery_provider.dart';
import 'pages/home_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BatteryProvider()..init(),
      child: const BatteryTimeApp(),
    ),
  );
}

class BatteryTimeApp extends StatefulWidget {
  const BatteryTimeApp({super.key});

  @override
  State<BatteryTimeApp> createState() => _BatteryTimeAppState();
}

class _BatteryTimeAppState extends State<BatteryTimeApp>
    with WidgetsBindingObserver {
    @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BatteryProvider>().onAppForeground();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final provider = context.read<BatteryProvider>();
    if (state == AppLifecycleState.resumed) {
      provider.onAppForeground();
    } else if (state == AppLifecycleState.paused) {
      provider.onAppBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: '电池统计',
      home: HomePage(),
    );
  }
}