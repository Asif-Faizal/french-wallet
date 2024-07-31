import 'dart:convert';
import 'package:ewallet2/data/account_info/acoount_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/config/api_config.dart';

class UserProfileRepository {
  Future<UserProfileResponse> fetchUserProfile() async {
    final String apiUrl = "https://api-innovitegra.online/user/Profile/view";
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Deviceid': Config.deviceId,
        'Authorization': 'Bearer ${prefs.getString('jwt_token')}',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return UserProfileResponse.fromJson(data);
    } else if (response.statusCode == 200) {
      final Map<String, dynamic> errorData = json.decode(response.body);
      if (errorData['status_code'] == 5) {
        await _refreshToken();
        return await fetchUserProfile();
      }
      throw Exception('Failed to load user profile');
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<void> _refreshToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String refreshToken = prefs.getString('refresh_token') ?? '';
    final String refreshTokenUrl =
        "https://api-innovitegra.online/login/refresh_token";

    final response = await http.post(
      Uri.parse(refreshTokenUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $refreshToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      await prefs.setString('jwt_token', data['jwt_token']);
      await prefs.setString('refresh_token', data['refresh_token']);
    } else {
      throw Exception('Failed to refresh token');
    }
  }
}
