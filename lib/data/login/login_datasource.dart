import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/config/api_config.dart';
import 'login_model.dart';

abstract class LoginDataSource {
  Future<LoginResponse> login(String mobile, String password);
}

class LoginDataSourceImpl implements LoginDataSource {
  @override
  Future<LoginResponse> login(String mobile, String password) async {
    final response = await http.post(
      Uri.parse(Config.login),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'X-Password': Config.password,
        'X-Username': Config.username,
        'Appversion': Config.appVersion,
        'Deviceid': Config.deviceId,
      },
      body:
          jsonEncode(LoginRequest(mobile: mobile, password: password).toJson()),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final status = responseData["status"];
      final message = responseData["message"];
      final jwt_token = responseData["jwt_token"];
      final refresh_token = responseData["refresh_token"];
      final user_type = responseData["user_type"];
      print(response.body);
      if (status == 'Fail') {
        throw Exception(message);
      } else if (status == 'Success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', jwt_token);
        await prefs.setString('refresh_token', refresh_token);
        // await prefs.setString('userType', user_type);
        print('qwertyui');
        print(user_type);
        return LoginResponse.fromJson(responseData);
      }
      return LoginResponse.fromJson(responseData);
    } else {
      throw Exception('Failed to login');
    }
  }
}