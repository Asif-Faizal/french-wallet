import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../shared/config/api_config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class WalletDataSource {
  Future<Map<String, dynamic>> fetchWalletDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwtToken = prefs.getString('jwt_token');
    String? refreshToken = prefs.getString('refresh_token');

    if (jwtToken == null || refreshToken == null) {
      throw Exception('Session expired. Please log in again.');
    }

    if (JwtDecoder.isExpired(jwtToken)) {
      jwtToken = await _refreshToken(refreshToken);
      if (jwtToken == null) {
        throw Exception('Session expired. Please log in again.');
      }
    }

    final url = Uri.parse(Config.wallet_info);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Deviceid': Config.deviceId,
        'Authorization': 'Bearer $jwtToken'
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData["status"] == "success") {
        return responseData;
      } else if (responseData["status"] == "Fail" &&
          responseData["code"] == 5) {
        throw Exception('Session TimedOut please Login again');
      } else {
        throw Exception('Failed to fetch wallet details.');
      }
    } else {
      throw Exception('Failed to fetch wallet details.');
    }
  }

  Future<String?> _refreshToken(String refreshToken) async {
    final url = Uri.parse(Config.refresh_token);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $refreshToken'
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final jwtToken = responseBody['jwt_token'];
      if (jwtToken != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('jwt_token', jwtToken);
        return jwtToken;
      }
    }
    return null;
  }
}
