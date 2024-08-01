import 'dart:convert';
import 'package:ewallet2/presentation/screens/services/shared/transaction_details.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/config/api_config.dart';

class TransactionHistoryPage extends StatefulWidget {
  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactionHistory();
  }

  Future<void> _fetchTransactionHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwtToken = prefs.getString('jwt_token');
    String? refreshToken = prefs.getString('refresh_token');

    if (jwtToken == null || refreshToken == null) {
      _showSnackBar('Session expired. Please log in again.', Colors.red);
      return;
    }

    if (JwtDecoder.isExpired(jwtToken)) {
      jwtToken = await _refreshToken(refreshToken);
      if (jwtToken == null) {
        _showSnackBar('Session expired. Please log in again.', Colors.red);
        return;
      }
    }

    final url = Uri.parse(Config.get_statement);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Deviceid': Config.deviceId,
        'Authorization': 'Bearer $jwtToken'
      },
      body: jsonEncode({
        'date_range': '30',
        'type': 'ALL',
      }),
    );

    if (response.statusCode == 200) {
      final responseBodyString = response.body;
      List<Map<String, dynamic>> parsedResponses =
          _parseConcatenatedJson(responseBodyString);

      if (parsedResponses.isNotEmpty) {
        setState(() {
          transactions = parsedResponses.first['data'];
          isLoading = false;
        });
      } else {
        _showSnackBar('Failed to fetch transactions.', Colors.red);
      }
    } else {
      _showSnackBar('Failed to fetch transactions.', Colors.red);
    }
  }

  List<Map<String, dynamic>> _parseConcatenatedJson(String responseBodyString) {
    List<Map<String, dynamic>> jsonObjects = [];
    RegExp regExp = RegExp(r'(\{.*?\})(?=\{|\s*$)');
    Iterable<RegExpMatch> matches = regExp.allMatches(responseBodyString);

    for (var match in matches) {
      try {
        jsonObjects.add(jsonDecode(match.group(0)!));
      } catch (e) {
        _showSnackBar('Failed to fetch transactions.', Colors.red);
      }
    }

    return jsonObjects;
  }

  Future<String?> _refreshToken(String refreshToken) async {
    final url = Uri.parse(Config.refresh_token);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
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

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: NormalAppBar(text: 'Transaction History'),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return Column(
                    children: [
                      ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TransactionDetailsPage(
                                      transactionId:
                                          transaction['transaction_id'])));
                        },
                        title: Text(
                            '${transaction['type']} - ${transaction['status']}'),
                        subtitle: Text(
                            '${transaction['description']} - ${_formatDate(transaction['date'])}'),
                        trailing: Text(
                            '${transaction['amount']} ${transaction['currency']}'),
                      ),
                      if (index < transactions.length - 1)
                        Divider(
                          thickness: 0.8,
                          color: Colors.blue.shade100,
                        ),
                    ],
                  );
                },
              ));
  }

  String _formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedDate);
  }
}
