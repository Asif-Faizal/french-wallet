import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';

import '../../../data/checkmobile/checkmobile_datasource.dart';
import '../../../data/checkmobile/checkmobile_repo_impl.dart';
import '../../../domain/checkmobile/checkmobile.dart';
import '../../../shared/country_code.dart';
import '../../bloc/checkmobile/checkmobile_bloc.dart';
import '../../bloc/checkmobile/checkmobile_event.dart';
import '../../bloc/checkmobile/checkmobile_state.dart';
import '../../bloc/login/login_bloc.dart';
import '../../bloc/login/login_event.dart';
import '../../bloc/login/login_state.dart';

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
  late CheckMobileBloc _CheckMobileBloc;
  FocusNode _numberFocusNode = FocusNode();
  final List<Map<String, String>> _countryCodes = CountryCode.countryCodes;
  String _selectedCountryDialCode = '+91';

  @override
  void initState() {
    super.initState();
    _retrieveData();
    _phoneController.addListener(_validatePhoneNumber);
    _CheckMobileBloc = CheckMobileBloc(
        checkMobileUseCase: CheckMobileUseCase(
            checkMobileRepository: CheckMobileRepositoryImpl(
                dataSource: CheckMobileDataSourceImpl())));
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhoneNumber);
    _phoneController.dispose();
    _CheckMobileBloc.close();
    super.dispose();
  }

  void _showCountryCodePicker() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            List<Map<String, String>> filteredCountryCodes =
                List.from(_countryCodes);

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text('Select Country Code'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        filteredCountryCodes = _countryCodes.where((country) {
                          final name = country['name']?.toLowerCase() ?? '';
                          final dialCode =
                              country['dialCode']?.toLowerCase() ?? '';
                          final query = value.toLowerCase();

                          return name.contains(query) ||
                              dialCode.contains(query);
                        }).toList();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: filteredCountryCodes.map((country) {
                          return ListTile(
                            leading: Text(
                              country['flag']!,
                              style: TextStyle(fontSize: 24),
                            ),
                            title: Text(
                                '${country['name']} (${country['dialCode']})'),
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
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
    final number = _selectedCountryDialCode + _phoneController.text;
    if (_phoneController.text.isNotEmpty) {
      _CheckMobileBloc.add(CheckMobileEvent(mobile: number));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showCountryCodePicker,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        _selectedCountryDialCode,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                          hintText: 'Number',
                          hintStyle: TextStyle(color: Colors.blue.shade300),
                          filled: true,
                          fillColor: Colors.blue.shade50,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                                color: Colors.blue.shade300, width: 1),
                          ),
                          enabledBorder: _numberFocusNode.hasFocus
                              ? OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                      color: Colors.blue.shade300, width: 1),
                                )
                              : OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                      color: Colors.blue.shade300, width: 0),
                                )),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            BlocConsumer<CheckMobileBloc, CheckMobileState>(
              bloc: _CheckMobileBloc,
              listener: (context, state) {
                if (state is CheckMobileSuccess) {
                  Navigator.of(context).pop();
                  _showOtpBottomSheet(context);
                } else if (state is CheckMobileError) {
                  Navigator.of(context).pop();
                  _showErrorDialog(context, state.message);
                } else if (state is CheckMobileLoading) {
                  _showLoadingDialog(context);
                }
              },
              builder: (context, state) {
                if (state is CheckMobileLoading) {
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

  void _login() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('number', widget.number);
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
