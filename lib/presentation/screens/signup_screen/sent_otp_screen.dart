import 'dart:convert';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../shared/config/api_config.dart';
import '../../../shared/country_code.dart';
import '../../widgets/shared/normal_appbar.dart';
import '../../widgets/shared/otp_bottom_sheet.dart';

class SentOtpSignInScreen extends StatefulWidget {
  const SentOtpSignInScreen({super.key});

  @override
  _SentOtpSignInState createState() => _SentOtpSignInState();
}

class _SentOtpSignInState extends State<SentOtpSignInScreen> {
  final TextEditingController _phoneController = TextEditingController();
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'IN');
  String _userType = '';
  bool _isButtonEnabled = false;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final List<Map<String, String>> _countryCodes = CountryCode.countryCodes;
  String _selectedCountryDialCode = '+91';

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
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _userType = prefs.getString('userType') ?? 'default_value';
    });
  }

  void _validatePhoneNumber() {
    final isValid = _phoneController.text.isNotEmpty;
    setState(() {
      _isButtonEnabled = isValid;
      _phoneNumber = PhoneNumber(
        phoneNumber: _phoneController.text,
        isoCode: _selectedCountryDialCode,
      );
    });
  }

  void _showOtpBottomSheet(BuildContext context, String mobile) {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
      useSafeArea: false,
      enableDrag: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      context: context,
      builder: (BuildContext context) {
        return OtpBottomSheet(
          number: mobile,
          userType: _userType,
          size: size,
          navigateTo: AppRouteConst.identityVerifyRoute,
        );
      },
    );
  }

  void _showCountryCodePicker() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Country Code'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _countryCodes.map((country) {
                return ListTile(
                  leading: Text(
                    country['flag']!,
                    style: TextStyle(fontSize: 24),
                  ),
                  title: Text('${country['name']} (${country['dialCode']})'),
                  onTap: () {
                    setState(() {
                      _selectedCountryDialCode = country['dialCode']!;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: NormalAppBar(
        text: AppLocalizations.of(context)!.sign_in,
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
              AppLocalizations.of(context)!.enter_number_to_register,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: size.height / 40),
            Row(
              children: [
                GestureDetector(
                  onTap: _showCountryCodePicker,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      _selectedCountryDialCode,
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      setState(() {
                        _phoneNumber = PhoneNumber(
                          phoneNumber: value,
                          isoCode: _selectedCountryDialCode,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
            const Spacer(),
            NormalButton(
              size: size,
              title: AppLocalizations.of(context)!.validate_num,
              onPressed: _isButtonEnabled
                  ? () async {
                      final mobile =
                          _selectedCountryDialCode + _phoneController.text;
                      final status = await sentOtpMobile(mobile);
                      if (status == 'Success') {
                        _showOtpBottomSheet(context, mobile);
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setString('phoneNumber', mobile);
                      }
                    }
                  : null,
            ),
            SizedBox(height: size.height / 40),
          ],
        ),
      ),
    );
  }

  Future<String> sentOtpMobile(String mobile) async {
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
      final responseData = jsonDecode(response.body);
      final message = responseData["message"];
      print(response.body);
      if (response.statusCode == 200) {
        final status = responseData["status"];
        if (status == 'Success') {
          return status;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ));
          return 'Fail';
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed with status code: ${response.statusCode}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ));
        return 'Error';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ));
      return 'Error';
    }
  }
}
