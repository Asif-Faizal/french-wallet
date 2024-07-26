import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../shared/config/api_config.dart';
import 'business_type_model.dart';

abstract class BusinessInfoDataSource {
  Future<List<BusinessTypeModel>> fetchBusinessTypes();
}

class BusinessInfoDataSourceImpl implements BusinessInfoDataSource {
  final http.Client client;

  BusinessInfoDataSourceImpl({required this.client});

  @override
  Future<List<BusinessTypeModel>> fetchBusinessTypes() async {
    final Map<String, String> headers = {
      'X-Password': Config.password,
      'X-Username': Config.username,
      'Appversion': Config.appVersion,
      'Content-Type': 'application/json',
      'Deviceid': Config.deviceId,
    };

    final response = await client.post(
      Uri.parse(Config.get_business_type),
      headers: headers,
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<BusinessTypeModel>.from(
        data['business_type'].map((item) => BusinessTypeModel.fromJson(item)),
      );
    } else {
      throw Exception('Failed to load business types');
    }
  }
}
