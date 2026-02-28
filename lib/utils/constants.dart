class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://localhost:8082/api/v1';

  // Auth endpoints
  static const String loginPhone = '/auth/login/phone';
  static const String loginWechat = '/auth/login/wechat';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Task endpoints
  static const String tasks = '/tasks';
  static String taskById(String id) => '/tasks/$id';
  static String completeTask(String id) => '/tasks/$id/complete';

  // Stats endpoints
  static const String statsSummary = '/stats/summary';

  // User endpoints
  static const String userProfile = '/user/profile';
  static const String userAvatar = '/user/avatar';

  // Sync endpoints
  static const String syncStatus = '/sync/status';
  static const String syncPull = '/sync/pull';
  static const String syncPush = '/sync/push';

  // Headers
  static const String authorizationHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
  static const String contentTypeJson = 'application/json';

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenExpiryKey = 'token_expiry';
  static const String userDataKey = 'user_data';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
