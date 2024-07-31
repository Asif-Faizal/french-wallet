import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/config/api_config.dart';

class TransactionDetailsPage extends StatefulWidget {
  final String transactionId;

  TransactionDetailsPage({required this.transactionId});

  @override
  _TransactionDetailsPageState createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  Map<String, dynamic>? transactionDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactionDetails();
  }

  Future<void> _fetchTransactionDetails() async {
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

    final url = Uri.parse(
        'https://api-innovitegra.online/transaction/statement/transaction_view');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Deviceid': Config.deviceId,
        'Authorization': 'Bearer $jwtToken'
      },
      body: jsonEncode({'tr_id': widget.transactionId}),
    );

    if (response.statusCode == 200) {
      final responseBodyString = response.body;
      setState(() {
        transactionDetails = jsonDecode(responseBodyString);
        isLoading = false;
      });
    } else {
      _showSnackBar('Failed to fetch transaction details.', Colors.red);
    }
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
      appBar: AppBar(
        title: Text('Transaction Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : transactionDetails != null && transactionDetails!['data'] != null
              ? ListView(
                  padding: EdgeInsets.all(10),
                  children: [
                    ListTile(
                      title: Text('Transaction ID'),
                      subtitle:
                          Text(transactionDetails!['data']['tr_id'] ?? 'N/A'),
                    ),
                    ListTile(
                      title: Text('Amount'),
                      subtitle: Text(
                          '${transactionDetails!['data']['amount']} ${transactionDetails!['data']['currency']}'),
                    ),
                    ListTile(
                      title: Text('Status'),
                      subtitle:
                          Text(transactionDetails!['data']['status'] ?? 'N/A'),
                    ),
                    ListTile(
                      title: Text('Category'),
                      subtitle: Text(
                          transactionDetails!['data']['category'] ?? 'N/A'),
                    ),
                    ListTile(
                      title: Text('Date'),
                      subtitle: Text(
                          _formatDate(transactionDetails!['data']['date'])),
                    ),
                    ListTile(
                      title: Text('Time'),
                      subtitle:
                          Text(transactionDetails!['data']['time'] ?? 'N/A'),
                    ),
                    ListTile(
                      title: Text('Remark'),
                      subtitle:
                          Text(transactionDetails!['data']['remark'] ?? 'N/A'),
                    ),
                    ListTile(
                      title: Text('Mobile'),
                      subtitle:
                          Text(transactionDetails!['data']['mobile'] ?? 'N/A'),
                    ),
                    ListTile(
                      title: Text('User Name'),
                      subtitle: Text(
                          transactionDetails!['data']['user_name'] ?? 'N/A'),
                    ),
                    ListTile(
                      title: Text('Receipt'),
                      subtitle: transactionDetails!['receipt_url'] != null
                          ? GestureDetector(
                              onTap: () {},
                              child: Text(
                                'View Receipt',
                                style: TextStyle(color: Colors.blue),
                              ),
                            )
                          : Text('N/A'),
                    ),
                  ],
                )
              : Center(child: Text('No transaction details available.')),
    );
  }

  String _formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }
}
