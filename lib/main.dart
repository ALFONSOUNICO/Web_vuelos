import 'package:flutter/material.dart';

import 'screens/login_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SapFlightAnalyticsApp());
}

class SapFlightAnalyticsApp extends StatelessWidget {
  const SapFlightAnalyticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAP Flight Analytics',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginPage(),
    );
  }
}
