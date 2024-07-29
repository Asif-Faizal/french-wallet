import 'dart:convert';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../shared/config/api_config.dart';

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
  String? passcode;
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
      passcode = prefs.getString('passcode');
    });

    print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
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
    print('Company Pincode: $companyPincode');
    print('Company Website: $companyWebsite');
    print('Company Mail: $companyMail');
    print('Company Phone: $companyPhone');
    print('Business Type: $businessType');
    print('Industry Type: $industryType');
    print('DIC ID: $docId');
    print('Passcode: $passcode');
  }

  @override
  void dispose() {
    for (var controller in _passcodeControllers) {
      controller.dispose();
    }
    for (var controller in _confirmPasscodeControllers) {
      controller.dispose();
    }
    for (var node in _passcodeFocusNodes) {
      node.dispose();
    }
    for (var node in _confirmPasscodeFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<Map<String, String>> sendDetails() async {
    final Map<String, String> headers = {
      'X-Password': Config.password,
      'X-Username': Config.username,
      'Appversion': Config.appVersion,
      'Content-Type': 'application/json',
      'Deviceid': Config.deviceId,
    };

    final body = {
      "mobile": "+917559913001",
      "email": "tes@gmail.com",
      "first_name": "tesname",
      "user_country_id": "IND",
      "user_gender": "1",
      "password": "loginpwd",
      "user_civil_id": "ADHAR ID",
      "civil_id_expiry": "EXP ID IF AVAILABLE",
      "fcm_id": "348ehweriwrew",
      "gcm_id": "348ehweriwrew",
      "civil_id_image": "image of aadhar",
      "selfie_image": "selfie image",
      "dob": "2019-12-02",
      "user_type": "MERCHANT",
      "ubo_info": [
        {
          "full_name": "John Doe",
          "percentage_ubo": "50%",
          "part_of_ownership": "Owner",
          "nationality": "Indian",
          "mobile": "+919876543210",
          "email": "john.doe@example.com",
          "alternate_email": "j.doe@example.com",
          "address": "123 Street, City, Country"
        }
      ],
      "fin_info": {
        "annual_turnover": "1000000",
        "tin_number": "TIN123456",
        "pan_number": "PAN123456"
      },
      "business_kyc_info": {
        "business_type": "Education",
        "industry_type": "E-Commerce",
        "official_website": "https://www.example.com",
        "alternate_mobile": "+919876543211",
        "building_no": "10",
        "door_number": "12A",
        "street": "Main Street",
        "city": "Metropolis",
        "state": "StateName",
        "country": "CountryName",
        "postal_code": "123456",
        "email_address": "business@example.com",
        "alternate_email": "alt.business@example.com"
      }
    }

        // {
        //   "mobile": phoneNumber,
        //   "email": email,
        //   "first_name": firstName,
        //   "user_country_id": nationality,
        //   "user_gender": gender,
        //   "password": passcode,
        //   "user_civil_id": idNumber,
        //   "civil_id_expiry": "EXP ID IF AVAILABLE",
        //   "fcm_id": "348ehweriwrew",
        //   "gcm_id": "348ehweriwrew",
        //   "civil_id_image": idImageFront,
        //   "selfie_image": selfieImage,
        //   "dob": '2006-08-03',
        //   "user_type": userType,
        //   "ubo_info": [
        //     {
        //       "full_name": fullName,
        //       "percentage_ubo": "50%",
        //       "part_of_ownership": "Owner",
        //       "nationality": nationality,
        //       "mobile": phoneNumber,
        //       "email": email,
        //       "alternate_email": "j.doe@example.com",
        //       "address": address
        //     }
        //   ],
        //   "fin_info": {
        //     "annual_turnover": turnover,
        //     "tin_number": tinNumber,
        //     "pan_number": panNumber
        //   },
        //   "business_kyc_info": {
        //     "business_type": businessType,
        //     "industry_type": industryType,
        //     "official_website": companyWebsite,
        //     "alternate_mobile": companyPhone,
        //     "building_no": companyBuilding,
        //     "door_number": "12A",
        //     "street": "Main Street",
        //     "city": companyCity,
        //     "state": "StateName",
        //     "country": "CountryName",
        //     "postal_code": companyPincode,
        //     "email_address": companyMail,
        //     "alternate_email": "alt.business@example.com"
        //   }
        // }
        ;
    try {
      final response = await http.post(
        Uri.parse(Config.register_v2),
        headers: headers,
        body: jsonEncode(body),
      );
      print(body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final status = responseData["status"];
        final message = responseData["message"];
        final jwt_token = responseData["jwt_token"];
        final refresh_token = responseData["refresh_token"];
        print(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', jwt_token);
        await prefs.setString('refresh_token', refresh_token);
        jwt_token2 = prefs.getString('jwt_token');
        print('JWT TOKEN: $jwt_token2');
        return {'status': status, 'message': message};
      } else {
        final responseData = jsonDecode(response.body);
        final message = responseData["message"];
        return {'status': 'Fail', 'message': message};
      }
    } catch (e) {
      return {'status': 'Fail', 'message': 'Exception: $e'};
    }
  }

  void _setPasscode() async {
    String passcode =
        _passcodeControllers.map((controller) => controller.text).join();
    String confirmPasscode =
        _confirmPasscodeControllers.map((controller) => controller.text).join();

    if (passcode.isEmpty || confirmPasscode.isEmpty) {
      _showSnackBar('Please enter both passcodes.');
    } else if (passcode != confirmPasscode) {
      _showSnackBar('Passcodes do not match.');
    } else {
      final result = await sendDetails();
      if (result['status'] == 'Success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        GoRouter.of(context).pushNamed(AppRouteConst.setTransactionPinRoute);
        _showSnackBar('Passcode set successfully.');
        prefs.clear();
        await prefs.setString('passcode', passcode);
        await prefs.setString('jwt_token', jwt_token2!);
      } else {
        _showSnackBar('Error: ${result['message']}');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        content: Text(message)));
  }

  Widget _buildPasscodeFields(
      List<TextEditingController> controllers, List<FocusNode> focusNodes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        6,
        (index) => _buildPasscodeField(controllers[index], focusNodes, index),
      ),
    );
  }

  Widget _buildPasscodeField(
      TextEditingController controller, List<FocusNode> focusNodes, int index) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < focusNodes.length - 1) {
              FocusScope.of(context).requestFocus(focusNodes[index + 1]);
            }
          } else {
            if (index > 0) {
              FocusScope.of(context).requestFocus(focusNodes[index - 1]);
            }
          }
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          counterText: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: NormalAppBar(text: 'Set Passcode'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Enter your 6-digit passcode:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            _buildPasscodeFields(_passcodeControllers, _passcodeFocusNodes),
            const SizedBox(height: 50),
            const Text(
              'Confirm your 6-digit passcode:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            _buildPasscodeFields(
                _confirmPasscodeControllers, _confirmPasscodeFocusNodes),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(15),
        child: NormalButton(
          onPressed: _setPasscode,
          title: 'Confirm Passcode',
          size: size,
        ),
      ),
    );
  }
}
