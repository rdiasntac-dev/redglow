import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/auth_screen.dart';
import 'theme/app_theme.dart';

class RedGlowApp extends StatelessWidget {
  const RedGlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'REDGLOW',
      theme: AppTheme.dark,
      home: const AuthScreen(),
    );
  }
}
