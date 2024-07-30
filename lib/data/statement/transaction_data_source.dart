import 'package:ewallet2/shared/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'transaction_model.dart';

class TransactionDataSource {
  static const String url = Config.get_statement;
  static const String deviceId = Config.deviceId;
  static const String bearerToken = Config.token;

  Future<List<TransactionModel>> fetchTransactions() async {
    String body = jsonEncode({"date_range": "30", "type": "ALL"});

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Deviceid': deviceId,
        'Content-Type': 'application/json',
        'Authorization': bearerToken,
      },
      body: body,
    );

    try {
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data') && responseData['data'] != null) {
          List<TransactionModel> transactions = (responseData['data'] as List)
              .map((data) => TransactionModel.fromJson(data))
              .toList();
          return transactions;
        } else {
          throw Exception('No data found in the response');
        }
      } else {
        throw Exception(
            'Failed to load transactions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      throw Exception('Failed to parse transactions. Error: ${e.toString()}');
    }
  }
}
