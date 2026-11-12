abstract final class AppEnvironment {
  static const name = String.fromEnvironment('APP_ENV', defaultValue: 'local');

  // Default points to backend local server or staging; configurable via dart-define
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://book.horixpro.com/api/v1',
  );

  static const appName = "Zein's Pool";
  static const appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );
  static const buildNumber = String.fromEnvironment(
    'BUILD_NUMBER',
    defaultValue: '1',
  );

  static bool get isProduction => name == 'production';
  static bool get isLocal => name == 'local';
}
