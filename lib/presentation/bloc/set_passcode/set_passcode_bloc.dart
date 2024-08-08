// set_passcode_bloc.dart
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'set_passcode_event.dart';
import 'set_passcode_state.dart';
import '../../../shared/config/api_config.dart';

class SetPasscodeBloc extends Bloc<SetPasscodeEvent, SetPasscodeState> {
  SetPasscodeBloc() : super(PasscodeInitial()) {
    on<PasscodeSet>(_onPasscodeSet);
  }

  Future<void> _onPasscodeSet(
      PasscodeSet event, Emitter<SetPasscodeState> emit) async {
    if (event.passcode.isEmpty || event.confirmPasscode.isEmpty) {
      emit(const PasscodeFailure('Please enter both passcodes.'));
      return;
    }

    if (event.passcode != event.confirmPasscode) {
      emit(const PasscodeFailure('Passcodes do not match.'));
      return;
    }

    emit(PasscodeLoading());

    try {
      final result = await _sendDetails(event.passcode);
      if (result['status'] == 'Success') {
        emit(PasscodeSuccess('Passcode set successfully.'));
      } else {
        emit(PasscodeFailure('Error: ${result['message']}'));
      }
    } catch (e) {
      emit(PasscodeFailure('Exception: $e'));
    }
  }

  Future<Map<String, String>> _sendDetails(String passcode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? phoneNumber = prefs.getString('phoneNumber') ?? '';
    final String? email = prefs.getString('email') ?? '';
    final String? firstName = prefs.getString('firstName') ?? '';
    final String? nationality = prefs.getString('nationality') ?? '';
    final String? gender = prefs.getString('gender') ?? '';
    final String? idNumber = prefs.getString('idNumber') ?? '';
    final String? idImageFront = prefs.getString('idImageFront') ?? '';
    final String? selfieImage = prefs.getString('selfieImage') ?? '';
    final String? userType = prefs.getString('userType') ?? '';
    final String? fullName = prefs.getString('fullName') ?? '';
    final String? address = prefs.getString('address') ?? '';
    final String? turnover = prefs.getString('turnover') ?? '';
    final String? tinNumber = prefs.getString('tinNumber') ?? '';
    final String? panNumber = prefs.getString('panNumber') ?? '';
    final String? businessType = prefs.getString('businessType') ?? '';
    final String? industryType = prefs.getString('industryType') ?? '';
    final String? companyWebsite = prefs.getString('companyWebsite') ?? '';
    final String? companyPhone = prefs.getString('companyPhone') ?? '';
    final String? companyBuilding = prefs.getString('companyBuilding') ?? '';
    final String? companyCity = prefs.getString('companyCity') ?? '';
    final String? companyPincode = prefs.getString('companyPincode') ?? '';
    final String? companyMail = prefs.getString('companyMail') ?? '';

    final Map<String, String> headers = {
      'X-Password': Config.password,
      'X-Username': Config.username,
      'Appversion': Config.appVersion,
      'Content-Type': 'application/json',
      'Deviceid': Config.deviceId,
    };

    final body = {
      "mobile": phoneNumber ?? '',
      "email": email ?? '',
      "first_name": firstName ?? '',
      "user_country_id": nationality ?? '',
      "user_gender": gender ?? '',
      "password": passcode,
      "user_civil_id": idNumber ?? '',
      "civil_id_expiry": "EXP ID IF AVAILABLE",
      "fcm_id": "348ehweriwrew",
      "gcm_id": "348ehweriwrew",
      "civil_id_image": idImageFront ?? '',
      "selfie_image": selfieImage ?? '',
      "dob": '2006-12-03',
      "user_type": userType ?? '',
      "ubo_info": [
        {
          "full_name": fullName ?? '',
          "percentage_ubo": "50%",
          "part_of_ownership": "Owner",
          "nationality": nationality ?? '',
          "mobile": phoneNumber ?? '',
          "email": email ?? '',
          "alternate_email": "j.doe@example.com",
          "address": address ?? ''
        }
      ],
      "fin_info": {
        "annual_turnover": turnover ?? '100000000',
        "tin_number": tinNumber ?? '',
        "pan_number": panNumber ?? ''
      },
      "business_kyc_info": {
        "business_type": businessType ?? '',
        "industry_type": industryType ?? '',
        "official_website": companyWebsite ?? '',
        "alternate_mobile": companyPhone ?? '',
        "building_no": companyBuilding ?? '',
        "door_number": "12A",
        "street": "Main Street",
        "city": companyCity ?? '',
        "state": "StateName",
        "country": "CountryName",
        "postal_code": companyPincode ?? '',
        "email_address": companyMail ?? '',
        "alternate_email": "alt.business@example.com"
      }
    };

    final response = await http.post(
      Uri.parse(Config.register_v2),
      headers: headers,
      body: jsonEncode(body),
    );
    print(response.body);
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final jwt_token = responseData["jwt_token"];
      final refresh_token = responseData["refresh_token"];
      await prefs.setString('jwt_token', jwt_token);
      await prefs.setString('refresh_token', refresh_token);
      return {'status': 'Success', 'message': responseData["message"]};
    } else {
      final responseData = jsonDecode(response.body);
      return {'status': 'Fail', 'message': responseData["message"]};
    }
  }
}
