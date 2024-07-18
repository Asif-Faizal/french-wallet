import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/presentation/widgets/shared/otp_bottom_sheet.dart';
import 'package:ewallet2/shared/config/api_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'IN');
  String _userType = '';
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _retrieveData();
    _phoneController.addListener(_validatePhoneNumber);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhoneNumber);
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _retrieveData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userType = prefs.getString('userType') ?? 'default_value';
    });
  }

  void _validatePhoneNumber() {
    setState(() {
      _isButtonEnabled = _phoneController.text.length == 10;
    });
  }

  void _showOtpBottomSheet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
      useSafeArea: false,
      enableDrag: true,
      isDismissible: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      context: context,
      builder: (BuildContext context) {
        return OtpBottomSheet(
          number: _phoneNumber.phoneNumber ?? '',
          userType: _userType,
          size: size,
          navigateTo: '',
        );
      },
    );
  }

  Future<void> checkMobile(String mobile) async {

    final Map<String, String> headers = {
      'X-Password': Config.password,
      'X-Username': Config.username,
      'Appversion': Config.appVersion,
      'Content-Type': 'application/json',
      'Deviceid': Config.deviceId,
    };

    final Map<String, String> body = {
      'mobile': mobile,
    };

    try {
      final response = await http.post(
        Uri.parse(Config.check_mobile_url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (kDebugMode) {
          print('Response body: ${response.body}');
        }
      } else {
        if (kDebugMode) {
          print('Failed with status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error fetching data'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> sentOtpMobile(String mobile) async {

    final Map<String, String> headers = {
      'X-Password': Config.password,
      'X-Username': Config.username,
      'Appversion': Config.appVersion,
      'Content-Type': 'application/json',
      'Deviceid': Config.deviceId,
    };

    final Map<String, String> body = {
      'mobile': mobile,
    };

    try {
      final response = await http.post(
        Uri.parse(Config.sent_mobile_otp_url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (kDebugMode) {
          print('Response body: ${response.body}');
        }
      } else {
        if (kDebugMode) {
          print('Failed with status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error fetching data'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ));
    }
  }

  
  Future<void> verifyOtpMobile(String mobile,String otp) async {

    final Map<String, String> headers = {
      'X-Password': Config.password,
      'X-Username': Config.username,
      'Appversion': Config.appVersion,
      'Content-Type': 'application/json',
      'Deviceid': Config.deviceId,
    };

    final Map<String, String> body = {
      'mobile': mobile,
      'otp': otp,
    };

    try {
      final response = await http.post(
        Uri.parse(Config.verify_mobile_otp_url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (kDebugMode) {
          print('Response body: ${response.body}');
        }
      } else {
        if (kDebugMode) {
          print('Failed with status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error fetching data'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: NormalAppBar(
        text: AppLocalizations.of(context)!.login,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: size.height / 30,
          horizontal: size.width / 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height / 20),
            Text(
              AppLocalizations.of(context)!.enter_mobile_number,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: size.height / 40),
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                setState(() {
                  _phoneNumber = number;
                });
              },
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.DROPDOWN,
              ),
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.disabled,
              initialValue: _phoneNumber,
              textFieldController: _phoneController,
              formatInput: false,
              keyboardType: const TextInputType.numberWithOptions(
                  signed: true, decimal: true),
              inputDecoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                hintText: AppLocalizations.of(context)!.mobile_number,
              ),
            ),
            const Spacer(),
            NormalButton(
              size: size,
              title: 'Get OTP',
              onPressed: _isButtonEnabled
                  ? () async {
                      await checkMobile(_phoneNumber.phoneNumber ?? '');
                      await sentOtpMobile(_phoneNumber.phoneNumber ?? '');
                      await verifyOtpMobile(_phoneNumber.phoneNumber ?? '','1234');
                      _showOtpBottomSheet(context);
                    }
                  : null,
            ),
            SizedBox(height: size.height / 40),
          ],
        ),
      ),
    );
  }
}
