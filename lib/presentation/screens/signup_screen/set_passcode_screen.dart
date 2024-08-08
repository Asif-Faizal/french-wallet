import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bloc/set_passcode/set_passcode_bloc.dart';
import '../../bloc/set_passcode/set_passcode_event.dart';
import '../../bloc/set_passcode/set_passcode_state.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:go_router/go_router.dart';

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

  String? userType;
  String? phoneNumber;
  String? idNumber;
  String? idImageFront;
  String? idImageBack;
  String? selfieImage;
  String? firstName;
  String? fullName;
  String? gender;
  String? dob;
  String? nationality;
  String? address;
  String? email;
  String? panNumber;
  String? businessName;
  String? tinNumber;
  String? turnover;
  String? companyBuilding;
  String? companyCity;
  String? companyPincode;
  String? companyWebsite;
  String? companyMail;
  String? companyPhone;
  String? businessType;
  String? industryType;
  String? docId;
  String? jwt_token2;

  @override
  void initState() {
    _getUserInfo();
    super.initState();
  }

  void _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userType = prefs.getString('userType')!.toUpperCase();
      phoneNumber = prefs.getString('phoneNumber');
      idNumber = prefs.getString('idNumber');
      idImageFront = prefs.getString('idImageFront');
      idImageBack = prefs.getString('idImageBack');
      selfieImage = prefs.getString('selfieImage');
      firstName = prefs.getString('firstName');
      fullName = prefs.getString('fullName');
      gender = prefs.getString('gender');
      dob = prefs.getString('dob');
      nationality = prefs.getString('nationality');
      address = prefs.getString('address');
      email = prefs.getString('email');
      panNumber = prefs.getString('panNumber');
      businessName = prefs.getString('businessName');
      tinNumber = prefs.getString('tinNumber');
      turnover = prefs.getString('turnover');
      companyBuilding = prefs.getString('companyBuilding');
      companyCity = prefs.getString('companyCity');
      companyPincode = prefs.getString('companyPincode');
      companyWebsite = prefs.getString('companyWebsite');
      companyMail = prefs.getString('companyMail');
      companyPhone = prefs.getString('companyPhone');
      businessType = prefs.getString('businessType');
      industryType = prefs.getString('industryType');
      docId = prefs.getString('docId');
    });
    print('User Type: $userType');
    print('Phone Number: $phoneNumber');
    print('ID Number: $idNumber');
    print('ID Image Front: $idImageFront');
    print('ID Image Back: $idImageBack');
    print('Selfie Image: $selfieImage');
    print('First Name: $firstName');
    print('Full Name: $fullName');
    print('Gender: $gender');
    print('DOB: $dob');
    print('Nationality: $nationality');
    print('Address: $address');
    print('Email: $email');
    print('PAN Number: $panNumber');
    print('Business Name: $businessName');
    print('TIN Number: $tinNumber');
    print('Turnover: $turnover');
    print('Company Building: $companyBuilding');
    print('Company City: $companyCity');
    print('Company PinCode: $companyPincode');
    print('Company Website: $companyWebsite');
    print('Company Mail: $companyMail');
    print('Company Phone: $companyPhone');
    print('Business Type: $businessType');
    print('Industry Type: $industryType');
    print('DIC ID: $docId');
  }

  @override
  void dispose() {
    for (var controller in _passcodeControllers) {
      controller.dispose();
    }
    for (var controller in _confirmPasscodeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NormalAppBar(text: 'Set Passcode'),
      body: BlocProvider(
        create: (context) => SetPasscodeBloc(),
        child: BlocListener<SetPasscodeBloc, SetPasscodeState>(
          listener: (context, state) {
            if (state is PasscodeSuccess) {
              GoRouter.of(context)
                  .pushNamed(AppRouteConst.completedAnimationRoute);
            } else if (state is PasscodeFailure) {
              // Show error message
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: BlocBuilder<SetPasscodeBloc, SetPasscodeState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Enter Passcode:',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return _buildPasscodeField(_passcodeControllers[index],
                            _passcodeFocusNodes[index], index, true);
                      }),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Confirm Passcode:',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return _buildPasscodeField(
                            _confirmPasscodeControllers[index],
                            _confirmPasscodeFocusNodes[index],
                            index,
                            false);
                      }),
                    ),
                    const SizedBox(height: 40),
                    state is PasscodeLoading
                        ? const Center(child: CircularProgressIndicator())
                        : NormalButton(
                            size: MediaQuery.of(context).size,
                            title: 'Set Passcode',
                            onPressed: () {
                              final passcode = _passcodeControllers
                                  .map((controller) => controller.text)
                                  .join('');
                              final confirmPasscode =
                                  _confirmPasscodeControllers
                                      .map((controller) => controller.text)
                                      .join('');
                              context.read<SetPasscodeBloc>().add(PasscodeSet(
                                  passcode: passcode,
                                  confirmPasscode: confirmPasscode));
                            },
                          ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPasscodeField(TextEditingController controller,
      FocusNode focusNode, int index, bool isPasscode) {
    return SizedBox(
      width: 50,
      height: 50,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        obscureText: true,
        maxLength: 1,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          counterText: '',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            if (isPasscode && index < _passcodeFocusNodes.length - 1) {
              FocusScope.of(context)
                  .requestFocus(_passcodeFocusNodes[index + 1]);
            } else if (!isPasscode &&
                index < _confirmPasscodeFocusNodes.length - 1) {
              FocusScope.of(context)
                  .requestFocus(_confirmPasscodeFocusNodes[index + 1]);
            } else {
              FocusScope.of(context).unfocus();
            }
          } else if (value.isEmpty) {
            if (isPasscode && index > 0) {
              FocusScope.of(context)
                  .requestFocus(_passcodeFocusNodes[index - 1]);
            } else if (!isPasscode && index > 0) {
              FocusScope.of(context)
                  .requestFocus(_confirmPasscodeFocusNodes[index - 1]);
            }
          }
        },
      ),
    );
  }
}
