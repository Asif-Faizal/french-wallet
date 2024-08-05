import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../shared/config/api_config.dart';
import 'sent_card_otp_event.dart';
import 'sent_card_otp_state.dart';

class SentCardOtpBloc extends Bloc<SentCardOtpEvent, SentCardOtpState> {
  SentCardOtpBloc() : super(SentCardOtpInitial()) {
    on<SentCardOtp>(_onSentCardOtp);
  }

  Future<void> _onSentCardOtp(
      SentCardOtp event, Emitter<SentCardOtpState> emit) async {
    emit(SentCardOtpLoading());

    final prefs = await SharedPreferences.getInstance();
    final cardUid = prefs.getString('cardId');
    String? jwtToken = prefs.getString('jwt_token');
    String? refreshToken = prefs.getString('refresh_token');

    if (cardUid == null) {
      emit(SentCardOtpFailure('Card ID not found'));
      return;
    }

    if (jwtToken == null || refreshToken == null) {
      emit(SentCardOtpSessionExpired());
      return;
    }

    if (JwtDecoder.isExpired(jwtToken)) {
      jwtToken = await _refreshToken(refreshToken);
      if (jwtToken == null) {
        emit(SentCardOtpSessionExpired());
        return;
      }
    }

    final url = Uri.parse(Config.send_card_otp);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Deviceid': Config.deviceId,
        'Authorization': 'Bearer $jwtToken'
      },
      body: jsonEncode({
        'card_uid': cardUid,
      }),
    );

    final responseData = jsonDecode(response.body);
    print(response.body);
    final status = responseData["status"];
    final message = responseData["remark"];
    final status_code = responseData["code"];
    final otp = responseData["otp"];
    print('=============================$otp=========================');

    if (response.statusCode == 200) {
      if (status == 'Success') {
        emit(SentCardOtpSuccess(message));
      } else if (status == 'Fail' && status_code == 5) {
        jwtToken = await _refreshToken(refreshToken);
        if (jwtToken != null) {
          final retryResponse = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Deviceid': Config.deviceId,
              'Authorization': 'Bearer $jwtToken'
            },
            body: jsonEncode({
              'card_uid': cardUid,
            }),
          );

          final retryResponseData = jsonDecode(retryResponse.body);
          final retryStatus = retryResponseData["status"];
          final retryMessage = retryResponseData["remark"];

          if (retryResponse.statusCode == 200) {
            if (retryStatus == 'Success') {
              emit(SentCardOtpSuccess(retryMessage));
            } else {
              emit(SentCardOtpFailure(retryMessage));
            }
          } else {
            emit(SentCardOtpFailure('Failed to send OTP'));
          }
        } else {
          emit(SentCardOtpSessionExpired());
        }
      } else {
        emit(SentCardOtpFailure(message));
      }
    } else {
      emit(SentCardOtpFailure('Failed to send OTP'));
    }
  }

  Future<String?> _refreshToken(String refreshToken) async {
    final url = Uri.parse(Config.refresh_token);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $refreshToken'
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final jwtToken = responseBody['jwt_token'];
      final newRefreshToken = responseBody['refresh_token'];
      if (jwtToken != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('jwt_token', jwtToken);
        prefs.setString('refresh_token', newRefreshToken);
        return jwtToken;
      } else {
        throw Exception('Session TimedOut please Login again');
      }
    }
    return null;
  }
}
