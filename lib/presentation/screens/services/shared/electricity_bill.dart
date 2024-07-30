import 'package:flutter/material.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    final url = Uri.parse(
        'https://api-innovitegra.online/Billers/service/process_service');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Deviceid': Config.deviceId,
        'Authorization': Config.token
      },
      body: jsonEncode({
        'amount': amount,
        'service_id': billPaymentCode,
        'account': accountNumber,
        'app_ref_id': appRefId,
      }),
    );

    final responseBody = jsonDecode(response.body);
    print(responseBody);

    if (responseBody['status'] == 'Success') {
      _showSnackBar(context, 'Transaction Successful', Colors.green);
    } else {
      _showSnackBar(context, 'Transaction Failed', Colors.red);
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
