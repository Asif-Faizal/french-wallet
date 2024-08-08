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
  bool _isLoading = false;
  String? _selectedItems;
  String? _number;
  String _userPin = '';

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
      _number = prefs.getString('money_number');
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
    await _showPinBottomSheet();

    if (_userPin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 4-digit PIN.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

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

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      if (status == 'Fail') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        GoRouter.of(context).pushNamed(AppRouteConst.errorAnimationRoute);
      } else if (status == 'Success') {
        GoRouter.of(context).pushNamed(AppRouteConst.completedAnimationRoute);
      }
    } else if (statusCode == 5) {
      final tokenResponse = await _refreshToken(refreshToken);

      if (tokenResponse != null) {
        final newJwtToken = tokenResponse['jwt_token'];
        final newRefreshToken = tokenResponse['refresh_token'];

        await prefs.setString('jwt_token', newJwtToken);
        await prefs.setString('refresh_token', newRefreshToken);

        final retryResponse = await _sendMoney(apiUrl, newJwtToken);
        final retryData = json.decode(retryResponse.body);

        final retryStatus = retryData['status'];
        final retryMessage = retryData['message'];

        if (retryStatus == 'Fail') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(retryMessage)),
          );
          GoRouter.of(context).pushNamed(AppRouteConst.errorAnimationRoute);
          prefs.remove('money_number');
        } else if (retryStatus == 'Success') {
          GoRouter.of(context).pushNamed(AppRouteConst.completedAnimationRoute);
          prefs.remove('money_number');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to refresh token. Please log in again.')),
        );
        GoRouter.of(context).pushNamed(AppRouteConst.loginRoute);
        prefs.remove('money_number');
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
        'mobile': _number,
        'currency': 'KWD',
        'amount': double.parse(_amountController.text),
        'user_pin': _userPin,
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

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  Future<void> _showPinBottomSheet() async {
    final TextEditingController pinController1 = TextEditingController();
    final TextEditingController pinController2 = TextEditingController();
    final TextEditingController pinController3 = TextEditingController();
    final TextEditingController pinController4 = TextEditingController();

    await showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Text(
                'Enter your 4-digit PIN',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPinField(pinController1, (value) {
                    if (value.isNotEmpty) {
                      FocusScope.of(context).nextFocus();
                    }
                  }),
                  _buildPinField(pinController2, (value) {
                    if (value.isNotEmpty) {
                      FocusScope.of(context).nextFocus();
                    }
                  }),
                  _buildPinField(pinController3, (value) {
                    if (value.isNotEmpty) {
                      FocusScope.of(context).nextFocus();
                    }
                  }),
                  _buildPinField(pinController4, (value) {
                    if (value.isNotEmpty) {
                      FocusScope.of(context).unfocus();
                    }
                  }),
                ],
              ),
              SizedBox(height: 20),
              NormalButton(
                size: MediaQuery.of(context).size,
                title: _getButtonTitle(),
                onPressed: () {
                  setState(() {
                    _userPin = pinController1.text +
                        pinController2.text +
                        pinController3.text +
                        pinController4.text;
                  });
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPinField(
    TextEditingController controller,
    Function(String) onChanged,
  ) {
    return Container(
      width: 50,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: NormalAppBar(text: widget.phoneNumber),
      body: Stack(
        children: [
          Padding(
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
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                Spacer(),
                NormalButton(
                  size: size,
                  title: _getButtonTitle(),
                  onPressed: _isButtonEnabled ? _handleSubmit : null,
                ),
              ],
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
