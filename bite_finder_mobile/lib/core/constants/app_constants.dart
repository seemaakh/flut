class AppConstants {
  AppConstants._();

  static const String apiBaseUrl = 'http://localhost:3000/api/v1';

  static const String storageAuthTokenKey = 'auth_token';

  static const Duration apiConnectTimeout = Duration(seconds: 15);
  static const Duration apiReceiveTimeout = Duration(seconds: 30);
}