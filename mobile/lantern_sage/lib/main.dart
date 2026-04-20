import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'screens/ask_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/today_screen.dart';
import 'services/lantern_repository.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(LanternSageApp());
}

class LanternSageApp extends StatelessWidget {
  LanternSageApp({super.key})
      : repository = LanternRepository(config: AppConfig.fromEnvironment());

  final LanternRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lantern Sage',
      debugShowCheckedModeBanner: false,
      theme: LanternSageTheme.dark(),
      home: LanternSageShell(repository: repository),
    );
  }
}

class LanternSageShell extends StatefulWidget {
  const LanternSageShell({
    required this.repository,
    super.key,
  });

  final LanternRepository repository;

  @override
  State<LanternSageShell> createState() => _LanternSageShellState();
}

class _LanternSageShellState extends State<LanternSageShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      TodayScreen(repository: widget.repository),
      AskScreen(repository: widget.repository),
      HistoryScreen(repository: widget.repository),
      ProfileScreen(repository: widget.repository),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_twilight_outlined),
            selectedIcon: Icon(Icons.wb_twilight),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.question_answer_outlined),
            selectedIcon: Icon(Icons.question_answer),
            label: 'Ask',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
