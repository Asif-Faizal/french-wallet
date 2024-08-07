import 'package:ewallet2/presentation/bloc/sent_otp/sent_otp_bloc.dart';
import 'package:ewallet2/presentation/bloc/sent_otp/sent_otp_state.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import '../../bloc/login/login_bloc.dart';
import '../../bloc/login/login_event.dart';
import '../../bloc/login/login_state.dart';
import '../../bloc/sent_otp/sent_otp_event.dart';

class SentOtpSignInScreen extends StatefulWidget {
  const SentOtpSignInScreen({super.key});

  @override
  _SentOtpSignInScreenState createState() => _SentOtpSignInScreenState();
}

class _SentOtpSignInScreenState extends State<SentOtpSignInScreen> {
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
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  void _showLoadingDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _onLoginButtonPressed() {
    if (_phoneController.text.isNotEmpty) {
      BlocProvider.of<SentOtpBloc>(context).add(SendOtp(_phoneController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocConsumer<SentOtpBloc, SentOtpState>(
      listener: (context, state) {
        if (state is SentOtpSuccess) {
          Navigator.of(context, rootNavigator: true).pop();
          _showOtpBottomSheet(context);
        } else if (state is SentOtpLoading) {
          _showLoadingDialog(context);
        } else if (state is SentOtpFailure) {
          Navigator.of(context, rootNavigator: true).pop();
          _showErrorDialog(context, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: NormalAppBar(text: ''),
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
                NormalButton(
                  title: 'Continue',
                  onPressed: _isButtonEnabled ? _onLoginButtonPressed : null,
                  size: size,
                ),
              ],
            ),
          ),
        );
      },
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

  void _login() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('number', widget.number);
    prefs.setBool('isLoggedIn', true);
    final password = _controllers.map((controller) => controller.text).join();
    BlocProvider.of<LoginBloc>(context).add(
      LoginSubmitted(
        password: password,
        mobile: widget.number,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          Navigator.of(context).pop();
          GoRouter.of(context).pushNamed(AppRouteConst.completedAnimationRoute);
        } else if (state is LoginError) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text(state.message),
          ));
        } else if (state is LoginLoading) {
          _showLoadingDialog(context);
        }
      },
      builder: (context, state) {
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
}
