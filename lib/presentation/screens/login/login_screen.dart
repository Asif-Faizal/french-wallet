import 'dart:async';
import 'dart:convert';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:go_router/go_router.dart';
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
      _isButtonEnabled = _phoneController.text.length >= 1;
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

  Future<void> _handleDeviceStatus(
      int userLinkedDevices, int primaryDevice) async {
    if (userLinkedDevices == 0 && primaryDevice == 0) {
      _showAlertDialog('Sign Up',
          'Please sign in, as your mobile number is not registered with our application');
    } else if (userLinkedDevices == 0 && primaryDevice == 1) {
      _showPasscodeBottomSheet();
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Sign Up'),
              onPressed: () {
                Navigator.of(context).pop();
                GoRouter.of(context).pushNamed(AppRouteConst.verifyNumberRoute);
              },
            ),
          ],
        );
      },
    );
  }

  void _showOtpErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red,
      content: Text(
        'Otp has been generated recently. Try again after some time.',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ));
  }

  Future<String> checkMobile(String mobile) async {
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
        final userLinkedDevices = responseData["user_linked_devices"];
        final primaryDevice = responseData["primary_device"];
        final message = responseData["message"];
        print(message);
        if (kDebugMode) {
          print('Response body: ${responseData}');
          print('User linked devices: $userLinkedDevices ++++++++++++++++++++');
          print('Primary device: $primaryDevice ++++++++++++++++++++');
        }

        await _handleDeviceStatus(userLinkedDevices, primaryDevice);
        return 'Success';
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

  void _showPasscodeBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      builder: (BuildContext context) {
        return PasscodeBottomSheet(
          onPasscodeEntered: (passcode) {
            print("Passcode entered: $passcode");
          },
        );
      },
    );
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

class PasscodeBottomSheet extends StatefulWidget {
  final Function(String) onPasscodeEntered;

  const PasscodeBottomSheet({required this.onPasscodeEntered, Key? key})
      : super(key: key);

  @override
  _PasscodeBottomSheetState createState() => _PasscodeBottomSheetState();
}

class _PasscodeBottomSheetState extends State<PasscodeBottomSheet> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  void _onTextChanged() {
    final passcode = _controllers.map((controller) => controller.text).join();
    if (passcode.length == 6) {
      widget.onPasscodeEntered(passcode);
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    for (var controller in _controllers) {
      controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.removeListener(_onTextChanged);
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.all(size.width / 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: size.width / 10,
                child: TextField(
                  controller: _controllers[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: size.height / 30),
          NormalButton(
            size: size,
            title: 'Submit',
            onPressed: () {
              final passcode =
                  _controllers.map((controller) => controller.text).join();
              if (passcode.length == 6) {
                widget.onPasscodeEntered(passcode);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
