import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EnterAmountPage extends StatefulWidget {
  const EnterAmountPage({super.key, required this.phoneNumber});
  final String phoneNumber;

  @override
  _EnterAmountPageState createState() => _EnterAmountPageState();
}

class _EnterAmountPageState extends State<EnterAmountPage> {
  final TextEditingController _amountController = TextEditingController();
  bool _isButtonEnabled = false;
  String? _selectedItems;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _amountController.addListener(_validateAmount);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedItems = prefs.getString('selected_value');
    });
  }

  @override
  void dispose() {
    _amountController.removeListener(_validateAmount);
    _amountController.dispose();
    super.dispose();
  }

  void _validateAmount() {
    setState(() {
      _isButtonEnabled = _amountController.text.isNotEmpty;
    });
  }

  String _getButtonTitle() {
    if (_selectedItems == 'Send') {
      return 'Pay';
    } else if (_selectedItems == 'Receive') {
      return 'Request';
    } else {
      return 'Proceed';
    }
  }

  Future<void> _handleSubmit() async {
    final String apiUrl =
        "https://api-innovitegra.online/bank_accounts/Send_money/send_money_to_user";
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String jwtToken = prefs.getString('jwt_token') ?? '';
    final String refreshToken = prefs.getString('refresh_token') ?? '';

    final response = await _sendMoney(apiUrl, jwtToken);
    final Map<String, dynamic> responseData = json.decode(response.body);

    final status = responseData['status'];
    final message = responseData['message'];
    final statusCode = responseData['status_code'];

    if (response.statusCode == 200) {
      if (status == 'Fail') {
        GoRouter.of(context).pushNamed(AppRouteConst.errorAnimationRoute);
      } else if (status == 'Success') {
        GoRouter.of(context).pushNamed(AppRouteConst.completedAnimationRoute);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else if (statusCode == 5) {
      final tokenResponse = await _refreshToken(refreshToken);

      if (tokenResponse != null) {
        final newJwtToken = tokenResponse['jwt_token'];
        final newRefreshToken = tokenResponse['refresh_token'];

        await prefs.setString('jwt_token', newJwtToken);
        await prefs.setString('refresh_token', newRefreshToken);

        final retryResponse = await _sendMoney(apiUrl, newJwtToken);
        final retryData = json.decode(retryResponse.body);

        print(response.body);
        final retryStatus = retryData['status'];
        final retryMessage = retryData['message'];

        if (retryStatus == 'Fail') {
          GoRouter.of(context).pushNamed(AppRouteConst.errorAnimationRoute);
        } else if (retryStatus == 'Success') {
          GoRouter.of(context).pushNamed(AppRouteConst.completedAnimationRoute);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(retryMessage)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to refresh token. Please log in again.')),
        );
        GoRouter.of(context)
            .pushNamed(AppRouteConst.loginRoute); // Redirect to login
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred.')),
      );
    }
  }

  Future<http.Response> _sendMoney(String apiUrl, String token) async {
    return await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'mobile': widget.phoneNumber,
        'currency': 'KWD',
        'amount': double.parse(_amountController.text),
        'user_pin': '1111',
        'remark': 'Test transaction',
      }),
    );
  }

  Future<Map<String, dynamic>?> _refreshToken(String refreshToken) async {
    final String refreshTokenUrl =
        "https://api-innovitegra.online/login/refresh_token";

    final response = await http.post(
      Uri.parse(refreshTokenUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $refreshToken',
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: NormalAppBar(text: widget.phoneNumber),
      body: Padding(
        padding: EdgeInsets.all(size.width / 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: size.height / 10),
            Text(
              'Enter the Amount',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: size.height / 20),
            TextField(
              textAlign: TextAlign.center,
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0.00',
                hintStyle: TextStyle(
                  fontSize: 32,
                  color: Theme.of(context).primaryColor.withOpacity(0.4),
                ),
                contentPadding: EdgeInsets.only(
                  bottom: size.height / 60,
                ),
              ),
            ),
            SizedBox(height: size.height / 30),
            NormalButton(
              onPressed: _isButtonEnabled ? _handleSubmit : null,
              title: _getButtonTitle(),
              size: size,
            ),
          ],
        ),
      ),
    );
  }
}
