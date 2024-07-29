import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    setState(() {
      _isButtonEnabled = _phoneController.text.length >= 1;
    });
  }

  void _showOtpBottomSheet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
      useSafeArea: false,
      enableDrag: true,
      scrollControlDisabledMaxHeightRatio: size.height,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      context: context,
      builder: (BuildContext context) {
        return OtpBottomSheet(
          number: _phoneNumber.phoneNumber ?? '',
          userType: _userType,
          size: size,
          navigateTo: AppRouteConst.identityVerifyRoute,
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
              title: AppLocalizations.of(context)!.validate_num,
              onPressed: _isButtonEnabled
                  ? () async {
                      _showOtpBottomSheet(context);
                      print(_phoneNumber);
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString(
                          'phoneNumber', _phoneNumber.toString());
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

  // Future<String> sentOtpMobile(String mobile) async {
  //   final Map<String, String> headers = {
  //     'X-Password': Config.password,
  //     'X-Username': Config.username,
  //     'Appversion': Config.appVersion,
  //     'Content-Type': 'application/json',
  //     'Deviceid': Config.deviceId,
  //   };

  //   final Map<String, String> body = {
  //     'mobile': mobile,
  //   };

  //   try {
  //     final response = await http.post(
  //       Uri.parse(Config.sent_mobile_otp_url),
  //       headers: headers,
  //       body: jsonEncode(body),
  //     );
  //     final responseData = jsonDecode(response.body);
  //     final message = responseData["message"];
  //     print(message);

  //     if (response.statusCode == 200) {
  //       final responseData = jsonDecode(response.body);
  //       final status = responseData["status"];
  //       if (kDebugMode) {
  //         print('Response body: ${responseData}');
  //         print(
  //             '??????????????????????????????????????????????????????????????????');
  //         print(status);
  //       }
  //       return status;
  //     } else {
  //       if (kDebugMode) {
  //         print('Failed with status code: ${response.statusCode}');
  //         print('Response body: ${response.body}');
  //       }
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         content: Text('Error fetching data'),
  //         behavior: SnackBarBehavior.floating,
  //         backgroundColor: Colors.red,
  //       ));
  //       return 'Error';
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text(e.toString()),
  //       behavior: SnackBarBehavior.floating,
  //       backgroundColor: Colors.red,
  //     ));
  //     return 'Error';
  //   }
  // }

  // Future<void> verifyOtpMobile(String mobile, String otp) async {
  //   final Map<String, String> headers = {
  //     'X-Password': Config.password,
  //     'X-Username': Config.username,
  //     'Appversion': Config.appVersion,
  //     'Content-Type': 'application/json',
  //     'Deviceid': Config.deviceId,
  //   };

  //   final Map<String, String> body = {
  //     'mobile': mobile,
  //     'otp': otp,
  //   };

  //   try {
  //     final response = await http.post(
  //       Uri.parse(Config.verify_mobile_otp_url),
  //       headers: headers,
  //       body: jsonEncode(body),
  //     );

  //     if (response.statusCode == 200) {
  //       final responseData = jsonDecode(response.body);

  //       if (kDebugMode) {
  //         print('Response body: ${responseData}');
  //       }
  //     } else {
  //       if (kDebugMode) {
  //         print('Failed with status code: ${response.statusCode}');
  //         print('Response body: ${response.body}');
  //       }
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         content: Text('Error fetching data'),
  //         behavior: SnackBarBehavior.floating,
  //         backgroundColor: Colors.red,
  //       ));
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text(e.toString()),
  //       behavior: SnackBarBehavior.floating,
  //       backgroundColor: Colors.red,
  //     ));
  //   }
  // }