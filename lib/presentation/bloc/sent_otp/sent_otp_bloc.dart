import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../shared/config/api_config.dart';
import 'sent_otp_event.dart';
import 'sent_otp_state.dart';

class SentOtpBloc extends Bloc<SentOtpEvent, SentOtpState> {
  SentOtpBloc() : super(SentOtpInitial()) {
    on<SendOtp>(_onSendOtp);
  }

  Future<void> _onSendOtp(SendOtp event, Emitter<SentOtpState> emit) async {
    emit(SentOtpLoading());
    final responseData = await _sendOtpMobile(event.mobile);
    if (responseData["status"] == 'Success') {
      emit(SentOtpSuccess());
    } else {
      emit(SentOtpFailure(responseData["message"]));
    }
  }

  Future<Map<String, dynamic>> _sendOtpMobile(String mobile) async {
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
        Uri.parse(Config.sent_mobile_otp_url),
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
