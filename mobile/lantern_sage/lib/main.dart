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
      bottomNavigationBar: _RitualBottomNavigation(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          _RitualNavigationItem(
            icon: Icons.wb_twilight_outlined,
            selectedIcon: Icons.wb_twilight,
            label: 'Today',
          ),
          _RitualNavigationItem(
            icon: Icons.question_answer_outlined,
            selectedIcon: Icons.question_answer,
            label: 'Ask',
          ),
          _RitualNavigationItem(
            icon: Icons.history_outlined,
            selectedIcon: Icons.history,
            label: 'History',
          ),
          _RitualNavigationItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
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

class _RitualNavigationItem {
  const _RitualNavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _RitualBottomNavigation extends StatelessWidget {
  const _RitualBottomNavigation({
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<_RitualNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF120700), Color(0xFF0A0300)],
        ),
        border: Border(
          top: BorderSide(
            color: LanternSageTheme.accent.withValues(alpha: 0.12),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: 64,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < items.length; index++)
                Expanded(
                  child: _RitualNavigationTile(
                    item: items[index],
                    selected: selectedIndex == index,
                    onTap: () => onDestinationSelected(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RitualNavigationTile extends StatelessWidget {
  const _RitualNavigationTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _RitualNavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: selected
              ? LanternSageTheme.textStrong
              : LanternSageTheme.textFaint,
          fontSize: 10,
          letterSpacing: 0.8,
        );

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: selected ? 42 : 0,
              height: 2,
              decoration: const BoxDecoration(
                color: LanternSageTheme.accent,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(2)),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    selected ? item.selectedIcon : item.icon,
                    color: selected
                        ? LanternSageTheme.textStrong
                        : LanternSageTheme.textFaint,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(item.label, style: labelStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
