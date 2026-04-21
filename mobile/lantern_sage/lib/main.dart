import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'screens/ask_screen.dart';
import 'screens/history_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/today_screen.dart';
import 'services/lantern_repository.dart';
import 'services/onboarding_store.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(LanternSageApp());
}

class LanternSageApp extends StatefulWidget {
  LanternSageApp({
    LanternRepository? repository,
    OnboardingStore? onboardingStore,
    super.key,
  })  : repository = repository ??
            LanternRepository(config: AppConfig.fromEnvironment()),
        onboardingStore = onboardingStore ?? OnboardingStore();

  final LanternRepository repository;
  final OnboardingStore onboardingStore;

  @override
  State<LanternSageApp> createState() => _LanternSageAppState();
}

class _LanternSageAppState extends State<LanternSageApp> {
  late Future<bool> _onboardingFuture;

  @override
  void initState() {
    super.initState();
    _onboardingFuture = _isReadyForShell();
  }

  Future<bool> _isReadyForShell() async {
    if (await widget.onboardingStore.isCompleted()) {
      return true;
    }
    return widget.repository.hasExistingGuestIdentity();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lantern Sage',
      debugShowCheckedModeBanner: false,
      theme: LanternSageTheme.dark(),
      home: FutureBuilder<bool>(
        future: _onboardingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data == true) {
            return LanternSageShell(repository: widget.repository);
          }

          return Scaffold(
            body: SafeArea(
              bottom: false,
              child: OnboardingScreen(
                repository: widget.repository,
                onCompleted: _completeOnboarding,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    await widget.onboardingStore.markCompleted();
    if (mounted) {
      setState(() {
        _onboardingFuture = Future.value(true);
      });
    }
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
  int? _pendingAskQuestionType;
  int _askSelectionRequestId = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      TodayScreen(
        repository: widget.repository,
        onAskQuestion: _openAskQuestion,
      ),
      AskScreen(
        repository: widget.repository,
        initialQuestionType: _pendingAskQuestionType,
        selectionRequestId: _askSelectionRequestId,
      ),
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
        height: 64,
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

  void _openAskQuestion(int questionType) {
    setState(() {
      _selectedIndex = 1;
      _pendingAskQuestionType = questionType;
      _askSelectionRequestId += 1;
    });
  }
}
