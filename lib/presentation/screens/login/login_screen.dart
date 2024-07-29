import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/presentation/widgets/shared/otp_bottom_sheet.dart';

import '../../../data/checkmobile/checkmobile_datasource.dart';
import '../../../data/checkmobile/checkmobile_repo_impl.dart';
import '../../../domain/checkmobile/checkmobile.dart';
import '../../bloc/checkmobile/checkmobile_bloc.dart';
import '../../bloc/checkmobile/checkmobile_event.dart';
import '../../bloc/checkmobile/checkmobile_state.dart';

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
  late LoginBloc _loginBloc;

  @override
  void initState() {
    super.initState();
    _retrieveData();
    _phoneController.addListener(_validatePhoneNumber);
    _loginBloc = LoginBloc(
        checkMobileUseCase: CheckMobileUseCase(
            checkMobileRepository:
                LoginRepositoryImpl(dataSource: LoginDataSourceImpl())));
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhoneNumber);
    _phoneController.dispose();
    _loginBloc.close();
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

  void _onLoginButtonPressed() {
    if (_phoneController.text.isNotEmpty) {
      _loginBloc.add(CheckMobileEvent(mobile: _phoneNumber.phoneNumber ?? ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: NormalAppBar(
        text: '',
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)?.login ?? '',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  setState(() {
                    _phoneNumber = number;
                  });
                },
                onInputValidated: (bool value) {},
                selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.DROPDOWN,
                ),
                ignoreBlank: false,
                selectorTextStyle: Theme.of(context).textTheme.bodyLarge,
                textStyle: Theme.of(context).textTheme.bodyLarge,
                initialValue: _phoneNumber,
                textFieldController: _phoneController,
                formatInput: true,
                maxLength: 10,
                keyboardType: TextInputType.number,
                inputDecoration: InputDecoration(
                  labelText: AppLocalizations.of(context)?.mobile_number,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            BlocConsumer<LoginBloc, LoginState>(
              bloc: _loginBloc,
              listener: (context, state) {
                if (state is LoginSuccess) {
                  _showOtpBottomSheet(context);
                } else if (state is LoginError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is LoginLoading) {
                  return const CircularProgressIndicator();
                }
                return NormalButton(
                  title: AppLocalizations.of(context)?.login ?? '',
                  onPressed: _isButtonEnabled ? _onLoginButtonPressed : null,
                  size: size,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
