import 'dart:convert';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../shared/config/api_config.dart';

class SetTransactionPinScreen extends StatefulWidget {
  const SetTransactionPinScreen({Key? key}) : super(key: key);

  @override
  _SetTransactionPinScreenState createState() =>
      _SetTransactionPinScreenState();
}

class _SetTransactionPinScreenState extends State<SetTransactionPinScreen> {
  final List<TextEditingController> _pinControllers =
      List.generate(4, (index) => TextEditingController());
  final List<TextEditingController> _confirmPinControllers =
      List.generate(4, (index) => TextEditingController());

  final List<FocusNode> _pinFocusNodes =
      List.generate(4, (index) => FocusNode());
  final List<FocusNode> _confirmPinFocusNodes =
      List.generate(4, (index) => FocusNode());
  String? jwt_token;

  @override
  void initState() {
    _getUserInfo();
    super.initState();
  }

  void _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      jwt_token = prefs.getString('jwt_token');
    });
    print(jwt_token);
  }

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var controller in _confirmPinControllers) {
      controller.dispose();
    }
    for (var node in _pinFocusNodes) {
      node.dispose();
    }
    for (var node in _confirmPinFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<Map<String, String>> setPin() async {
    final Map<String, String> headers = {
      'X-Password': Config.password,
      'X-Username': Config.username,
      'Appversion': Config.appVersion,
      'Content-Type': 'application/json',
      'Deviceid': Config.deviceId,
      'Authorization': 'Bearer $jwt_token',
    };
    final body = {"pin": '1111', "re_pin": '1111', "password": "111111"};
    try {
      final response = await http.post(
        Uri.parse(Config.set_transaction_pin),
        headers: headers,
        body: jsonEncode(body),
      );
      print(body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final status = responseData["status"];
        final message = responseData["message"];
        print(status);
        print(response.body);
        print(message);
        return {'status': status, 'message': message};
      } else {
        final responseData = jsonDecode(response.body);
        final message = responseData["message"];
        return {'status': 'Fail', 'message': message};
      }
    } catch (e) {
      return {'status': 'Fail', 'message': 'Exception: $e'};
    }
  }

  void _checkPin() async {
    String pin = _pinControllers.map((controller) => controller.text).join();
    String confirmPin =
        _confirmPinControllers.map((controller) => controller.text).join();
    if (pin.isEmpty || confirmPin.isEmpty) {
      _showSnackBar('Please enter both PINs.');
    } else if (pin != confirmPin) {
      _showSnackBar('PINs do not match.');
    } else {
      final response = await setPin();
      if (response['status'] == 'Success') {
        _showSnackBar('PIN set successfully.');
        GoRouter.of(context).pushNamed(AppRouteConst.completedAnimationRoute);
      } else {
        _showSnackBar('Error creating PIN');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      content: Text(message),
    ));
  }

  Widget _buildPinFields(
      List<TextEditingController> controllers, List<FocusNode> focusNodes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        4,
        (index) => _buildTextField(controllers[index], focusNodes, index, 1),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller,
      List<FocusNode> focusNodes, int index, int maxLength) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.number,
        maxLength: maxLength,
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < focusNodes.length - 1) {
              FocusScope.of(context).requestFocus(focusNodes[index + 1]);
            }
          } else {
            if (index > 0) {
              FocusScope.of(context).requestFocus(focusNodes[index - 1]);
            }
          }
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          counterText: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: NormalAppBar(text: 'Set PIN'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Enter your 4-digit PIN:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            _buildPinFields(_pinControllers, _pinFocusNodes),
            const SizedBox(height: 30),
            const Text(
              'Confirm your 4-digit PIN:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            _buildPinFields(_confirmPinControllers, _confirmPinFocusNodes),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15),
        child: Container(
          height: size.height / 6,
          child: Column(
            children: [
              NormalButton(
                onPressed: _checkPin,
                title: 'Set PIN',
                size: size,
              ),
              SizedBox(
                height: size.height / 60,
              ),
              NormalButton(
                onPressed: () {
                  GoRouter.of(context)
                      .pushNamed(AppRouteConst.completedAnimationRoute);
                },
                title: 'Skip',
                size: size,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
