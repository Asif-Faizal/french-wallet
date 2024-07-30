import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../shared/config/api_config.dart';
import 'acoount_model.dart';

class UserProfileRepository {
  Future<UserProfileResponse> fetchUserProfile() async {
    final String apiUrl = "https://api-innovitegra.online/user/Profile/view";
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Deviceid': Config.deviceId,
        'Authorization': Config.token
      },
    );
    if (response.statusCode == 200) {
      print(response.body);
      final Map<String, dynamic> data = json.decode(response.body);
      return UserProfileResponse.fromJson(data);
    } else {
      throw Exception('Failed to load user profile');
    }
  }
}
