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

class BatteryTimeApp extends StatelessWidget {
  const BatteryTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: '电池统计',
      home: HomePage(),
    );
  }
}