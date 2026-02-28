import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'dart:convert';

class AuthApiService {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Login with phone
  Future<LoginResponse> loginWithPhone(String phone, String code) async {
    final request = LoginRequest.phone(phone: phone, code: code);

    final response = await _apiService.post(
      ApiConstants.loginPhone,
      data: request.toJson(),
    );

    final loginResponse = LoginResponse.fromJson(response.data as Map<String, dynamic>);
    await _saveTokens(loginResponse);
    return loginResponse;
  }

  // Login with WeChat
  Future<LoginResponse> loginWithWechat(String wechatCode) async {
    final request = LoginRequest.wechat(wechatCode: wechatCode);

    final response = await _apiService.post(
      ApiConstants.loginWechat,
      data: request.toJson(),
    );

    final loginResponse = LoginResponse.fromJson(response.data as Map<String, dynamic>);
    await _saveTokens(loginResponse);
    return loginResponse;
  }

  // Refresh token
  Future<String> refreshToken() async {
    final refreshToken = await _storage.read(key: ApiConstants.refreshTokenKey);
    if (refreshToken == null) {
      throw ApiException('No refresh token available');
    }

    final response = await _apiService.post(
      ApiConstants.refreshToken,
      data: {'refresh_token': refreshToken},
    );

    final data = response.data as Map<String, dynamic>;
    final accessToken = data['access_token'] as String;
    final expiresIn = data['expires_in'] as int;

    // Save new access token
    await _storage.write(key: ApiConstants.accessTokenKey, value: accessToken);

    // Calculate and store expiry time
    final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));
    await _storage.write(
      key: ApiConstants.tokenExpiryKey,
      value: expiryTime.toIso8601String(),
    );

    return accessToken;
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConstants.logout);
    } catch (e) {
      // Continue with local logout even if API call fails
      print('Logout API call failed: $e');
    }

    await _apiService.clearTokens();
  }

  // Save tokens and user data
  Future<void> _saveTokens(LoginResponse loginResponse) async {
    await _storage.write(
      key: ApiConstants.accessTokenKey,
      value: loginResponse.accessToken,
    );
    await _storage.write(
      key: ApiConstants.refreshTokenKey,
      value: loginResponse.refreshToken,
    );

    // Calculate and store expiry time
    final expiryTime = DateTime.now().add(Duration(seconds: loginResponse.expiresIn));
    await _storage.write(
      key: ApiConstants.tokenExpiryKey,
      value: expiryTime.toIso8601String(),
    );

    // Save user data
    await _storage.write(
      key: ApiConstants.userDataKey,
      value: jsonEncode(loginResponse.user.toJson()),
    );
  }

  // Get stored user
  Future<User?> getStoredUser() async {
    final userJson = await _storage.read(key: ApiConstants.userDataKey);
    if (userJson == null) return null;

    try {
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userData);
    } catch (e) {
      print('Failed to parse stored user: $e');
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _apiService.isTokenValid();
  }

  // Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: ApiConstants.accessTokenKey);
  }
}
