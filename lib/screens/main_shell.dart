import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'secondary_screens.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    BookingsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: .15),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            return IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : AppColors.textMuted,
              size: 21,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return TextStyle(
              color: states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : AppColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          height: 66,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Início'),
            NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Buscar'),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_rounded),
              label: 'Agenda',
            ),
            NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}
