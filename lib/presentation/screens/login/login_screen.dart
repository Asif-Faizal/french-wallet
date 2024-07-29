import 'dart:convert';
import 'package:ewallet2/shared/config/api_config.dart';
import 'package:http/http.dart' as http;

import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';

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
            checkMobileRepository: CheckMobileRepositoryImpl(
                dataSource: CheckMobileDataSourceImpl())));
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
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Please Sign up'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Sign Up'),
              onPressed: () {
                Navigator.of(context).pop();
                GoRouter.of(context).pushNamed(AppRouteConst.verifyNumberRoute);
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Loading...'),
            ],
          ),
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
        text: AppLocalizations.of(context)?.login ?? '',
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
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
                  Navigator.of(context).pop();
                  _showOtpBottomSheet(context);
                } else if (state is LoginError) {
                  Navigator.of(context).pop();
                  _showErrorDialog(context, state.message);
                } else if (state is LoginLoading) {
                  _showLoadingDialog(context);
                }
              },
              builder: (context, state) {
                if (state is LoginLoading) {
                  return const Spacer();
                }
                return const Spacer();
              },
            ),
            NormalButton(
              title: 'Continue',
              onPressed: _isButtonEnabled ? _onLoginButtonPressed : null,
              size: size,
            ),
          ],
        ),
      ),
    );
  }
}

class OtpBottomSheet extends StatefulWidget {
  const OtpBottomSheet({
    Key? key,
    required this.number,
    required this.userType,
    required this.size,
  }) : super(key: key);

  final String number;
  final String userType;
  final Size size;

  @override
  _OtpBottomSheetState createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<OtpBottomSheet> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (index) => TextEditingController());
    _focusNodes = List.generate(6, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (int i = 0; i < 6; i++) {
      _controllers[i].dispose();
      _focusNodes[i].dispose();
    }
    super.dispose();
  }

  Future<void> _login() async {
    final password = _controllers.map((controller) => controller.text).join();
    final response = await http.post(
      Uri.parse(Config.login),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'X-Password': Config.password,
        'X-Username': Config.username,
        'Appversion': Config.appVersion,
        'Deviceid': Config.deviceId
      },
      body: jsonEncode(<String, String>{
        'mobile': widget.number,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final status = responseData["status"];
      final message = responseData["message"];
      print(response.body);
      print(status);
      print(message);
      if (status == 'Fail') {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text(message)));
      } else if (status == 'Success') {
        Navigator.of(context).pop();
        GoRouter.of(context).pushNamed(AppRouteConst.completedAnimationRoute);
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Login Failed'),
            content: Text('Invalid credentials. Please try again.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.0,
          right: 16.0,
          top: 16.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Passcode for ${widget.number}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: widget.size.height / 30),
            Text(
              'Passcode',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: widget.size.height / 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counter: Offstage(),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < 5) {
                        _focusNodes[index].unfocus();
                        FocusScope.of(context)
                            .requestFocus(_focusNodes[index + 1]);
                      }
                    },
                  ),
                );
              }),
            ),
            SizedBox(height: widget.size.height / 20),
            NormalButton(
              size: widget.size,
              title: 'Login',
              onPressed: _login,
            ),
            SizedBox(height: widget.size.height / 20),
          ],
        ),
      ),
    );
  }
}
