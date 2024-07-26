import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../shared/config/api_config.dart';
import '../industry sector/industry_sector_model.dart';

abstract class IndustrySectorDataSource {
  Future<List<IndustrySectorModel>> fetchIndustrySectors();
}

class IndustrySectorDataSourceImpl implements IndustrySectorDataSource {
  final http.Client client;

  IndustrySectorDataSourceImpl({required this.client});

  @override
  Future<List<IndustrySectorModel>> fetchIndustrySectors() async {
    final Map<String, String> headers = {
      'X-Password': Config.password,
      'X-Username': Config.username,
      'Appversion': Config.appVersion,
      'Content-Type': 'application/json',
      'Deviceid': Config.deviceId,
    };

    final response = await client.post(
      Uri.parse(Config.get_industry_type),
      headers: headers,
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<IndustrySectorModel>.from(
        data['industry_type'].map((item) => IndustrySectorModel.fromJson(item)),
      );
    } else {
      throw Exception('Failed to load industry sectors');
    }
  }
}
