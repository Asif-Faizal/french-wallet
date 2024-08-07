import 'dart:convert';
import 'package:ewallet2/presentation/bloc/verify_otp/verify_otp_event.dart';
import 'package:ewallet2/presentation/bloc/verify_otp/verify_otp_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../shared/config/api_config.dart';

class VerifyOtpBloc extends Bloc<VerifyOtpEvent, VerifyOtpState> {
  VerifyOtpBloc() : super(VerifyOtpInitial()) {
    on<VerifyOtp>(_onSendOtp);
  }

  Future<void> _onSendOtp(VerifyOtp event, Emitter<VerifyOtpState> emit) async {
    emit(VerifyOtpLoading());
    final responseData = await _sendOtpMobile(event.mobile, event.otp);
    if (responseData["status"] == 'Success') {
      emit(VerifyOtpSuccess(responseData["message"]));
    } else {
      emit(VerifyOtpFailure(responseData["message"]));
    }
  }

  Future<Map<String, dynamic>> _sendOtpMobile(String mobile, String otp) async {
    final Map<String, String> headers = {
      'X-Password': Config.password,
      'X-Username': Config.username,
      'Appversion': Config.appVersion,
      'Content-Type': 'application/json',
      'Deviceid': Config.deviceId,
    };
    final Map<String, String> body = {'mobile': mobile, "otp": otp};
    try {
      final response = await http.post(
        Uri.parse(Config.verify_mobile_otp_url),
        headers: headers,
        body: jsonEncode(body),
      );
      print(response.body);
      final responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {
        'status': 'Error',
        'message': e.toString(),
      };
    }
  }
}
