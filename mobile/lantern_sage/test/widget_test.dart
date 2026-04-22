import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:lantern_sage/config/app_config.dart';
import 'package:lantern_sage/data/demo_data.dart';
import 'package:lantern_sage/main.dart';
import 'package:lantern_sage/models/ask_question.dart';
import 'package:lantern_sage/models/feedback_state.dart';
import 'package:lantern_sage/models/history_entry.dart';
import 'package:lantern_sage/models/important_date_guidance.dart';
import 'package:lantern_sage/models/today_read.dart';
import 'package:lantern_sage/models/user_profile.dart';
import 'package:lantern_sage/screens/ask_screen.dart';
import 'package:lantern_sage/screens/history_screen.dart';
import 'package:lantern_sage/screens/profile_screen.dart';
import 'package:lantern_sage/screens/today_screen.dart';
import 'package:lantern_sage/services/lantern_repository.dart';
import 'package:lantern_sage/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('first run onboarding registers a guest before showing Today',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = FakeRepository(hasExistingIdentity: false);

    await tester.pumpWidget(LanternSageApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Lantern Sage'), findsOneWidget);
    expect(find.text('Continue as guest'), findsOneWidget);

    await tester.tap(find.text('Shanghai / Asia/Shanghai'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('London / Europe/London').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();

    expect(repository.registeredCity, 'London');
    expect(repository.profile.timezone, 'Europe/London');
    expect(find.text('Today'), findsWidgets);
  });

  testWidgets('first run onboarding can continue when guest register fails',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = FakeRepository(
      hasExistingIdentity: false,
      registerError: true,
    );

    await tester.pumpWidget(LanternSageApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();

    expect(find.text('Continue as guest'), findsNothing);
    expect(find.text('Today'), findsWidgets);
  });

  testWidgets('existing users skip onboarding', (tester) async {
    SharedPreferences.setMockInitialValues(
        {'lantern_sage_onboarding_completed': true});

    await tester.pumpWidget(LanternSageApp(repository: FakeRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Continue as guest'), findsNothing);
    expect(find.text('Today'), findsWidgets);
  });

  testWidgets('bottom navigation opens the main MVP tabs', (tester) async {
    await tester
        .pumpWidget(_testApp(LanternSageShell(repository: FakeRepository())));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ask'));
    await tester.pumpAndSettle();
    expect(find.text('Free reads today'), findsOneWidget);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('Recent rhythm.'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Guest / Free tier'), findsOneWidget);
  });

  testWidgets('Today renders fallback copy and submits updated feedback',
      (tester) async {
    final repository = FakeRepository(todayError: true);

    await tester.pumpWidget(_testApp(TodayScreen(repository: repository)));
    await tester.pumpAndSettle();

    expect(
        find.text(
            'Using saved sample guidance while the service is unavailable.'),
        findsOneWidget);

    await tester.scrollUntilVisible(find.text('Neutral'), 500);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Neutral'));
    await tester.pumpAndSettle();

    expect(repository.feedbackRating, 'neutral');
    expect(find.text('Marked as Neutral.'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Accurate'));
    await tester.pumpAndSettle();

    expect(repository.feedbackRating, 'accurate');
    expect(find.text('Marked as Accurate.'), findsOneWidget);
  });

  testWidgets('Today expands hours and Ask preview opens selected Ask flow',
      (tester) async {
    final repository = FakeRepository();

    await tester.pumpWidget(_testApp(LanternSageShell(repository: repository)));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Show more hours'), 500);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show more hours'));
    await tester.pumpAndSettle();
    expect(find.text('1:00 PM - 3:00 PM'), findsOneWidget);
    expect(find.text('Hide hours'), findsOneWidget);

    await tester.scrollUntilVisible(
        find.text('Is this a good time to go out?'), 500);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Is this a good time to go out?').first);
    await tester.pumpAndSettle();

    expect(repository.lastQuestionType, 0);
    expect(find.text('Free reads today'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Proceed gently.'), 500);
    await tester.pumpAndSettle();
    expect(find.text('Proceed gently.'), findsOneWidget);
  });

  testWidgets('Ask submits a selected fixed question and renders the answer',
      (tester) async {
    final repository = FakeRepository();

    await tester.pumpWidget(_testApp(AskScreen(repository: repository)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Is this a good time to go out?'));
    await tester.pumpAndSettle();

    expect(repository.lastQuestionType, 0);
    await tester.scrollUntilVisible(find.text('Proceed gently.'), 500);
    await tester.pumpAndSettle();
    expect(find.text('Proceed gently.'), findsOneWidget);
    expect(find.text('Late morning'), findsOneWidget);
  });

  testWidgets('History renders empty and populated states', (tester) async {
    await tester.pumpWidget(
        _testApp(HistoryScreen(repository: FakeRepository(history: const []))));
    await tester.pumpAndSettle();
    expect(find.text('Your recent daily rhythm will collect here.'),
        findsOneWidget);

    await tester.pumpWidget(_testApp(HistoryScreen(
        repository: FakeRepository(history: const [
      HistoryEntry(
        date: '2026-04-21',
        dayOfWeek: 'Tuesday',
        message: 'A clear day for small progress.',
        goodForSummary: 'Planning',
        avoidSummary: 'Arguments',
        askCount: 2,
        feedback: 'accurate',
      ),
    ]))));
    await tester.pumpAndSettle();

    expect(find.text('A clear day for small progress.'), findsOneWidget);
    expect(find.text('2 asks'), findsOneWidget);
    expect(find.text('accurate'), findsOneWidget);
  });

  testWidgets('Profile updates location from the settings sheet',
      (tester) async {
    final repository = FakeRepository();

    await tester.pumpWidget(_testApp(ProfileScreen(repository: repository)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('City'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New York'));
    await tester.pumpAndSettle();

    expect(repository.profile.city, 'New York');
    expect(find.text('New York'), findsOneWidget);
    expect(find.text('America/New_York'), findsOneWidget);
  });

  testWidgets('Important Date validates date input and renders guidance',
      (tester) async {
    final repository = FakeRepository();
    final futureDate = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().add(const Duration(days: 10)));

    await tester.pumpWidget(_testApp(ProfileScreen(repository: repository)));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Open'), 500);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '2000-01-01');
    await tester.tap(find.text('Get guidance'));
    await tester.pumpAndSettle();
    expect(find.text('Choose today or a future date.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), futureDate);
    await tester.tap(find.text('Get guidance'));
    await tester.pumpAndSettle();

    expect(repository.importantDateEventType, 'meeting');
    expect(find.text('Useful for calm conversation with a short agenda.'),
        findsOneWidget);
  });

  testWidgets('paid offers bridge into an active access page', (tester) async {
    await tester
        .pumpWidget(_testApp(ProfileScreen(repository: FakeRepository())));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('See plans'), 500);
    await tester.pumpAndSettle();
    await tester.tap(find.text('See plans'));
    await tester.pumpAndSettle();

    expect(find.text('Payment bridge'), findsOneWidget);
    expect(find.text('Lantern Sage Plus'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Access active'), findsOneWidget);
    expect(find.text('Lantern Sage Plus is active.'), findsOneWidget);
    expect(
        find.text(
            'Plus access is shown as active for the MVP paid-state screen.'),
        findsOneWidget);
  });

  testWidgets('Ask preserves both paid CTAs for date pack and Plus',
      (tester) async {
    await tester.pumpWidget(_testApp(AskScreen(repository: FakeRepository())));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Open date pack'), 500);
    await tester.pumpAndSettle();
    expect(find.text('See Plus'), findsOneWidget);

    await tester.tap(find.text('Open date pack'));
    await tester.pumpAndSettle();
    expect(find.text('Payment bridge'), findsOneWidget);
    expect(find.text('Important Date Pack'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Access active'), findsOneWidget);
    expect(find.text('Important Date Pack is active.'), findsOneWidget);
  });

  testWidgets('History Plus CTA opens paid bridge', (tester) async {
    await tester
        .pumpWidget(_testApp(HistoryScreen(repository: FakeRepository())));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('See Plus'), 500);
    await tester.pumpAndSettle();
    await tester.tap(find.text('See Plus'));
    await tester.pumpAndSettle();

    expect(find.text('Payment bridge'), findsOneWidget);
    expect(find.text('Lantern Sage Plus'), findsOneWidget);
  });

  testWidgets('Profile one-time pack purchase opens paid bridge',
      (tester) async {
    await tester
        .pumpWidget(_testApp(ProfileScreen(repository: FakeRepository())));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
        find.text('Purchase Important Date Pack'), 500);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Purchase Important Date Pack'));
    await tester.pumpAndSettle();

    expect(find.text('Payment bridge'), findsOneWidget);
    expect(find.text('Important Date Pack'), findsOneWidget);
  });
}

Widget _testApp(Widget child) {
  return MaterialApp(
    theme: LanternSageTheme.dark(),
    home: Scaffold(
      body: SafeArea(
        bottom: false,
        child: child,
      ),
    ),
  );
}

class FakeRepository extends LanternRepository {
  FakeRepository({
    this.hasExistingIdentity = true,
    this.registerError = false,
    this.todayError = false,
    List<HistoryEntry>? history,
  })  : history = history ??
            const [
              HistoryEntry(
                date: '2026-04-21',
                dayOfWeek: 'Tuesday',
                message: 'A clear day for small progress.',
                goodForSummary: 'Planning',
                avoidSummary: 'Arguments',
                askCount: 1,
              ),
            ],
        super(
          config: const AppConfig(
            apiBaseUrl: 'http://127.0.0.1:8000',
            defaultCity: 'Shanghai',
            defaultTimezone: 'Asia/Shanghai',
          ),
        );

  final bool hasExistingIdentity;
  final bool registerError;
  final bool todayError;
  final List<HistoryEntry> history;

  UserProfile profile = const UserProfile(
    id: 'user-test',
    deviceId: 'guest-test',
    city: 'Shanghai',
    timezone: 'Asia/Shanghai',
    language: 'en',
    tier: 'free',
    reminderTime: '20:00',
  );
  String? registeredCity;
  String? feedbackRating;
  int? lastQuestionType;
  String? importantDateEventType;

  @override
  Future<bool> hasExistingGuestIdentity() async => hasExistingIdentity;

  @override
  Future<UserProfile> getOrRegisterGuest(
      {String? city, String? timezone}) async {
    if (registerError) {
      throw Exception('register offline');
    }
    registeredCity = city ?? registeredCity;
    profile = profile.copyWith(
      city: city,
      timezone: timezone,
    );
    return profile;
  }

  @override
  Future<UserProfile> updateSettings({
    required String city,
    required String timezone,
    String? reminderTime,
  }) async {
    profile = profile.copyWith(
      city: city,
      timezone: timezone,
      reminderTime: reminderTime,
    );
    return profile;
  }

  @override
  Future<TodayRead> getToday() async {
    if (todayError) {
      throw Exception('offline');
    }
    return demoToday;
  }

  @override
  Future<List<AskQuestion>> getAskQuestions() async => askQuestions;

  @override
  Future<AskAnswer> askQuestion(int questionType) async {
    lastQuestionType = questionType;
    return demoAnswer;
  }

  @override
  Future<List<HistoryEntry>> getHistory() async => history;

  @override
  Future<FeedbackState> getFeedbackStatus() async {
    return FeedbackState(
      date: '2026-04-21',
      submitted: feedbackRating != null,
      rating: feedbackRating,
    );
  }

  @override
  Future<FeedbackState> submitFeedback(String rating) async {
    feedbackRating = rating;
    return FeedbackState(
      date: '2026-04-21',
      submitted: true,
      rating: rating,
    );
  }

  @override
  Future<ImportantDateGuidance> getImportantDateGuidance({
    required DateTime targetDate,
    required String eventType,
  }) async {
    importantDateEventType = eventType;
    return demoImportantDate;
  }
}
