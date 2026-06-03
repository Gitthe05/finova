import 'dart:io' show Platform;

class AppConstants {
  static const appName = 'FINOVA';
  static const minPasswordLength = 6;
  static const financialGoalDefault = 5000.0;

  static String get defaultApiBaseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://127.0.0.1:3000';
  }
}
