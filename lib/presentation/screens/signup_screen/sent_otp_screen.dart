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
      _isButtonEnabled = _phoneController.text.length == 10;
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
