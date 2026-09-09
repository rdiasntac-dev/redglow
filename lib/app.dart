import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/auth_screen.dart';
import 'state/demo_app_state.dart';
import 'theme/app_theme.dart';

class RedGlowApp extends StatefulWidget {
  const RedGlowApp({super.key});

  @override
  State<RedGlowApp> createState() => _RedGlowAppState();
}

class _RedGlowAppState extends State<RedGlowApp> {
  final _demoState = DemoAppState();

  @override
  void dispose() {
    _demoState.dispose();
    super.dispose();
  }

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

    return DemoAppScope(
      controller: _demoState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'REDGLOW',
        theme: AppTheme.dark,
        home: const AuthScreen(),
      ),
    );
  }
}
