import 'package:intl/intl.dart';

import '../config/app_config.dart';
import '../data/demo_data.dart';
import '../models/ask_question.dart';
import '../models/feedback_state.dart';
import '../models/history_entry.dart';
import '../models/important_date_guidance.dart';
import '../models/today_read.dart';
import '../models/user_profile.dart';
import 'api_client.dart';
import 'device_identity.dart';

class LanternRepository {
  LanternRepository({
    required this.config,
    LanternSageApiClient? apiClient,
    DeviceIdentityStore? identityStore,
  })  : _apiClient = apiClient ??
            LanternSageApiClient(baseUrl: _normalizeBaseUrl(config.apiBaseUrl)),
        _identityStore = identityStore ?? DeviceIdentityStore();

  final AppConfig config;
  final LanternSageApiClient _apiClient;
  final DeviceIdentityStore _identityStore;

  UserProfile? _profile;

  Future<UserProfile> getOrRegisterGuest({
    String? city,
    String? timezone,
  }) async {
    final cached = _profile;
    if (cached != null) {
      return cached;
    }

    final deviceId = await _identityStore.getOrCreateDeviceId();
    final json = await _apiClient.postJson('/user/register', {
      'device_id': deviceId,
      'city': city ?? config.defaultCity,
      'timezone': timezone ?? config.defaultTimezone,
    });
    final profile = UserProfile.fromJson(json);
    _profile = profile;
    return profile;
  }

  Future<bool> hasExistingGuestIdentity() {
    return _identityStore.hasDeviceId();
  }

  Future<UserProfile> updateSettings({
    required String city,
    required String timezone,
    String? reminderTime,
  }) async {
    final profile = await getOrRegisterGuest();
    final body = <String, dynamic>{
      'city': city,
      'timezone': timezone,
    };
    if (reminderTime != null) {
      body['reminder_time'] = reminderTime;
    }

    final json = await _apiClient.patchJson(
      '/user/settings',
      body,
      query: {'user_id': profile.id},
    );
    final updated = UserProfile.fromJson(json);
    _profile = updated;
    return updated;
  }

  Future<TodayRead> getToday() async {
    final profile = await getOrRegisterGuest();
    final now = DateTime.now();
    final currentDate = DateFormat('yyyy-MM-dd').format(now);
    final json = await _apiClient.postJson('/day/today', {
      'user_id': profile.id,
      'current_date': currentDate,
    });

    return TodayRead.fromJson(
        json, DateFormat('MMMM d, yyyy - EEEE').format(now));
  }

  Future<List<AskQuestion>> getAskQuestions() async {
    final json = await _apiClient.getJson('/ask/questions');
    final questions = json['questions'];
    if (questions is! List) {
      return askQuestions;
    }

    return questions.whereType<Map<String, dynamic>>().map((item) {
      final parsed = AskQuestion.fromJson(item);
      return AskQuestion(
        type: parsed.type,
        text: parsed.text,
        hint: _hintForQuestionType(parsed.type),
        available: parsed.available,
      );
    }).toList();
  }

  Future<AskAnswer> askQuestion(int questionType) async {
    final profile = await getOrRegisterGuest();
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final json = await _apiClient.postJson('/ask', {
      'user_id': profile.id,
      'question_type': questionType,
      'current_date': currentDate,
    });
    return AskAnswer.fromJson(json);
  }

  Future<List<HistoryEntry>> getHistory() async {
    final profile = await getOrRegisterGuest();
    final json = await _apiClient.getJson(
      '/history',
      query: {'user_id': profile.id},
    );
    final entries = json['entries'];
    if (entries is! List) {
      return const [];
    }

    return entries
        .whereType<Map<String, dynamic>>()
        .map(HistoryEntry.fromJson)
        .toList();
  }

  Future<FeedbackState> getFeedbackStatus() async {
    final profile = await getOrRegisterGuest();
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final json = await _apiClient.getJson(
      '/feedback/status',
      query: {
        'user_id': profile.id,
        'current_date': currentDate,
      },
    );
    return FeedbackState.fromJson(json);
  }

  Future<FeedbackState> submitFeedback(String rating) async {
    final profile = await getOrRegisterGuest();
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final json = await _apiClient.postJson('/feedback', {
      'user_id': profile.id,
      'date': currentDate,
      'rating': rating,
    });
    return FeedbackState(
      date: json['date'] as String? ?? currentDate,
      submitted: true,
      rating: json['rating'] as String? ?? rating,
    );
  }

  Future<ImportantDateGuidance> getImportantDateGuidance({
    required DateTime targetDate,
    required String eventType,
  }) async {
    final profile = await getOrRegisterGuest();
    final json = await _apiClient.postJson('/important-date', {
      'user_id': profile.id,
      'target_date': DateFormat('yyyy-MM-dd').format(targetDate),
      'event_type': eventType,
    });
    return ImportantDateGuidance.fromJson(json);
  }

  static String _normalizeBaseUrl(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  String _hintForQuestionType(int type) {
    for (final question in askQuestions) {
      if (question.type == type) {
        return question.hint;
      }
    }
    return '';
  }
}
