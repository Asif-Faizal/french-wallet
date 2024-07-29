import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ewallet2/shared/config/api_config.dart';

import 'checkmobile_model.dart';

abstract class LoginDataSource {
  Future<CheckMobileResponseModel> checkMobile(String mobile);
}

class LoginDataSourceImpl implements LoginDataSource {
  @override
  Future<CheckMobileResponseModel> checkMobile(String mobile) async {
    final Map<String, String> headers = {
      'X-Password': Config.password,
      'X-Username': Config.username,
      'Appversion': Config.appVersion,
      'Content-Type': 'application/json',
      'Deviceid': Config.deviceId,
    };

    final Map<String, String> body = {
      'mobile': mobile,
    };

    try {
      final response = await http.post(
        Uri.parse(Config.check_mobile_url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final checkMobileResponse =
            CheckMobileResponseModel.fromJson(responseData);
        return checkMobileResponse;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load data: ${e.toString()}');
    }
  }
}
