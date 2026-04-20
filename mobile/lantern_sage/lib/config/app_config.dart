class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.defaultCity,
    required this.defaultTimezone,
  });

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      apiBaseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://127.0.0.1:8000',
      ),
      defaultCity: String.fromEnvironment(
        'DEFAULT_CITY',
        defaultValue: 'Shanghai',
      ),
      defaultTimezone: String.fromEnvironment(
        'DEFAULT_TIMEZONE',
        defaultValue: 'Asia/Shanghai',
      ),
    );
  }

  final String apiBaseUrl;
  final String defaultCity;
  final String defaultTimezone;
}
