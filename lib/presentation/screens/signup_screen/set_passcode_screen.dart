import 'dart:convert';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../shared/config/api_config.dart';

class SetPasscodeScreen extends StatefulWidget {
  const SetPasscodeScreen({Key? key}) : super(key: key);

  @override
  _SetPasscodeScreenState createState() => _SetPasscodeScreenState();
}

class _SetPasscodeScreenState extends State<SetPasscodeScreen> {
  final List<TextEditingController> _passcodeControllers =
      List.generate(6, (index) => TextEditingController());
  final List<TextEditingController> _confirmPasscodeControllers =
      List.generate(6, (index) => TextEditingController());

  final List<FocusNode> _passcodeFocusNodes =
      List.generate(6, (index) => FocusNode());
  final List<FocusNode> _confirmPasscodeFocusNodes =
      List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _passcodeControllers) {
      controller.dispose();
    }
    for (var controller in _confirmPasscodeControllers) {
      controller.dispose();
    }
    for (var node in _passcodeFocusNodes) {
      node.dispose();
    }
    for (var node in _confirmPasscodeFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> sendDetails() async {
    final Map<String, String> headers = {
      'X-Password': Config.password,
      'X-Username': Config.username,
      'Appversion': Config.appVersion,
      'Content-Type': 'application/json',
      'Deviceid': Config.deviceId,
    };

    final body = {
      "mobile": "+917559913633",
      "email": "tes@gmail.com",
      "first_name": "tesname",
      "user_country_id": "IND",
      "user_gender": "1",
      "password": "loginpwd",
      "user_civil_id": "ADHAR ID",
      "civil_id_expiry": "EXP ID IF AVAILABLE",
      "fcm_id": "348ehweriwrew",
      "gcm_id": "348ehweriwrew",
      "civil_id_image": "image of aadhar",
      "selfie_image": "selfie image",
      "dob": "2019-12-02",
      "user_type": "MERCHANT",
      "ubo_info": [
        {
          "full_name": "John Doe",
          "percentage_ubo": "50%",
          "part_of_ownership": "Owner",
          "nationality": "Indian",
          "mobile": "+919876543210",
          "email": "john.doe@example.com",
          "alternate_email": "j.doe@example.com",
          "address": "123 Street, City, Country"
        }
      ],
      "fin_info": {
        "annual_turnover": "1000000",
        "tin_number": "TIN123456",
        "pan_number": "PAN123456"
      },
      "business_kyc_info": {
        "business_type": "Education",
        "industry_type": "E-Commerce",
        "official_website": "https://www.example.com",
        "alternate_mobile": "+919876543211",
        "building_no": "10",
        "door_number": "12A",
        "street": "Main Street",
        "city": "Metropolis",
        "state": "StateName",
        "country": "CountryName",
        "postal_code": "123456",
        "email_address": "business@example.com",
        "alternate_email": "alt.business@example.com"
      }
    };

    try {
      final response = await http.post(
        Uri.parse('https://api-innovitegra.online/login/Register/register_v2'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final jwtToken = responseData["jwt_token"];
        print(jwtToken);
        print(response.body);
        return jwtToken;
      } else {
        _showSnackBar('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showSnackBar('Exception: $e');
    }
    return null;
  }

  void _setPasscode() async {
    String passcode =
        _passcodeControllers.map((controller) => controller.text).join();
    String confirmPasscode =
        _confirmPasscodeControllers.map((controller) => controller.text).join();

    if (passcode.isEmpty || confirmPasscode.isEmpty) {
      _showSnackBar('Please enter both passcodes.');
    } else if (passcode != confirmPasscode) {
      _showSnackBar('Passcodes do not match.');
    } else {
      await sendDetails();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('passcode', passcode);
      GoRouter.of(context).pushNamed(AppRouteConst.retailHomeRoute);
      _showSnackBar('Passcode set successfully.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildPasscodeFields(List<TextEditingController> controllers,
      List<FocusNode> focusNodes, double fieldHeight) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 40,
            height: fieldHeight,
            child: TextField(
              obscureText: true,
              obscuringCharacter: '*',
              controller: controllers[index],
              focusNode: focusNodes[index],
              keyboardType: TextInputType.number,
              textInputAction:
                  index == 5 ? TextInputAction.done : TextInputAction.next,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                if (value.isNotEmpty && index < 5) {
                  FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                } else if (value.isNotEmpty && index == 5) {
                  FocusScope.of(context)
                      .requestFocus(_confirmPasscodeFocusNodes[0]);
                }
                if (value.isEmpty && index > 0) {
                  FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                }
              },
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: NormalAppBar(text: ''),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height / 60),
            Text(
              'Set a PIN for accessing your eWallet securely',
              style: theme.textTheme.headlineMedium,
            ),
            SizedBox(height: size.height / 20),
            Text('Enter Passcode', style: theme.textTheme.bodyMedium),
            SizedBox(height: size.height / 40),
            _buildPasscodeFields(
                _passcodeControllers, _passcodeFocusNodes, size.height / 16),
            SizedBox(height: size.height / 20),
            Text('Confirm Passcode', style: theme.textTheme.bodyMedium),
            SizedBox(height: size.height / 40),
            _buildPasscodeFields(_confirmPasscodeControllers,
                _confirmPasscodeFocusNodes, size.height / 16),
            SizedBox(height: size.height / 20),
            const Spacer(),
            NormalButton(
                size: size, title: 'Set Passcode', onPressed: _setPasscode),
          ],
        ),
      ),
    );
  }
}
