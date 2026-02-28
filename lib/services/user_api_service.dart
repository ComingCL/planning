import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class UserApiService {
  final ApiService _apiService = ApiService();

  // Get user profile
  Future<User> getProfile() async {
    final response = await _apiService.get(ApiConstants.userProfile);
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  // Update user profile
  Future<User> updateProfile({
    String? nickname,
    String? email,
  }) async {
    final data = <String, dynamic>{};
    if (nickname != null) data['nickname'] = nickname;
    if (email != null) data['email'] = email;

    final response = await _apiService.put(
      ApiConstants.userProfile,
      data: data,
    );

    return User.fromJson(response.data as Map<String, dynamic>);
  }

  // Upload avatar
  Future<String> uploadAvatar(String filePath) async {
    final response = await _apiService.uploadFile(
      ApiConstants.userAvatar,
      filePath,
      fieldName: 'avatar',
    );

    final data = response.data as Map<String, dynamic>;
    return data['avatar_url'] as String;
  }
}
