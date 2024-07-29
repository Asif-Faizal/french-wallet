import 'dart:convert';
import 'package:http/http.dart' as http;
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
      if (status == 'Fail') {
        throw Exception(responseData["message"]);
      } else if (status == 'Success') {
        return LoginResponse.fromJson(responseData);
      }
      return LoginResponse.fromJson(responseData);
    } else {
      throw Exception('Failed to login');
    }
  }
}
