import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../../shared/config/api_config.dart';

class ElectricityBillPage extends StatelessWidget {
  final _accountNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final billPaymentCode = '1002';
  static const appRefId = '123456789012';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: NormalAppBar(text: 'Electricity Bill'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeading('Account Number'),
            _buildTextField(
              controller: _accountNumberController,
              labelText: 'Enter Account Number',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            _buildSectionHeading('Amount'),
            _buildTextField(
              controller: _amountController,
              labelText: 'Enter Amount',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(15),
        child: NormalButton(
          size: size,
          title: 'Submit',
          onPressed: () async {
            final accountNumber = _accountNumberController.text;
            final amount = double.tryParse(_amountController.text) ?? 0;

            if (accountNumber.isEmpty || amount <= 0) {
              _showSnackBar(context, 'Please enter valid details', Colors.red);
            } else {
              await _submitElectricityBill(
                  context, accountNumber, amount.toString());
            }
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(fontWeight: FontWeight.normal),
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
    );
  }

  Future<void> _submitElectricityBill(
      BuildContext context, String accountNumber, String amount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwtToken =
        // 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVZGlkIjoiOTg2dDUzNDY2NjU4NzY0NTM0MjM0NTI0MzI3MzQ4NTM0NTMzMTM0MzU3Njg5NTMyMyIsIkN1c3RvbWVySUQiOiIyNjEiLCJleHAiOjE3MjIzNDM0MzMsImlzcyI6IkFaZVdhbGxldCJ9.omAMwvWbylp95mFz3pr15ksCjnLF_k6rNW5Nq_DfJ_g';
        prefs.getString('jwt_token');

    String? refreshToken =
        // 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVZGlkIjoiOTg2dDUzNDY2NjU4NzY0NTM0MjM0NTI0MzI3MzQ4NTM0NTMzMTM0MzU3Njg5NTMyMyIsIkN1c3RvbWVySUQiOiIyNjEiLCJleHAiOjE3MjI0MjY4MzMsImlzcyI6IkFaZVdhbGxldCJ9.CDPNCI6SeMOZcjd0uTZkQhQJp4hNniYZ08mZmFI7kjc';
        prefs.getString('refresh_token');
    print('JWT Token: $jwtToken');
    print('Refresh Token: $refreshToken');
    if (jwtToken == null || refreshToken == null) {
      _showSnackBar(
          context, 'Session expired. Please log in again.', Colors.red);
      return;
    }

    if (JwtDecoder.isExpired(jwtToken)) {
      jwtToken = await _refreshToken(refreshToken, context);
      if (jwtToken == null) {
        _showSnackBar(
            context, 'Session expired. Please log in again.', Colors.red);
        return;
      }
    }

    final response = await _makeApiRequest(jwtToken, accountNumber, amount);

    if (response['status_code'] == 5) {
      jwtToken = await _refreshToken(refreshToken, context);
      if (jwtToken != null) {
        final retryResponse =
            await _makeApiRequest(jwtToken, accountNumber, amount);
        _handleApiResponse(context, retryResponse);
      } else {
        _showSnackBar(
            context, 'Session expired. Please log in again.', Colors.red);
      }
    } else {
      _handleApiResponse(context, response);
    }
  }

  Future<Map<String, dynamic>> _makeApiRequest(
      String jwtToken, String accountNumber, String amount) async {
    final url = Uri.parse(Config.billing);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Deviceid': Config.deviceId,
        'Authorization': 'Bearer $jwtToken'
      },
      body: jsonEncode({
        'amount': amount,
        'service_id': billPaymentCode,
        'account': accountNumber,
        'app_ref_id': appRefId,
      }),
    );

    return jsonDecode(response.body);
  }

  void _handleApiResponse(
      BuildContext context, Map<String, dynamic> responseBody) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userType = prefs.getString('userType');
    print(userType);
    print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@$responseBody');
    final String snackbarMessage =
        '${responseBody["message"]} ID:${responseBody["d_id"]}';
    if (responseBody['status'] == 'Success') {
      _showSnackBar(context, snackbarMessage, Colors.green);
      GoRouter.of(context).pushNamed(AppRouteConst.completedAnimationRoute);
    } else {
      _showSnackBar(context, 'Transaction Failed', Colors.red);
    }
  }

  Future<String?> _refreshToken(
      String refreshToken, BuildContext context) async {
    final url = Uri.parse(Config.refresh_token);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('jwt_token', responseBody['jwt_token']);
      return responseBody['jwt_token'];
    } else {
      return null;
    }
  }

  void _showSnackBar(
      BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
