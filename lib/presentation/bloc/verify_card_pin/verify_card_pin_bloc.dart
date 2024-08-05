import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../shared/config/api_config.dart';
import 'verify_card_pin_event.dart';
import 'verify_card_pin_state.dart';

class VerifyCardPinBloc
    extends Bloc<PinVerificationEvent, PinVerificationState> {
  VerifyCardPinBloc() : super(PinVerificationInitial()) {
    on<VerifyPin>(_onVerifyPin);
  }

  Future<void> _onVerifyPin(
      VerifyPin event, Emitter<PinVerificationState> emit) async {
    emit(PinVerificationLoading());

    final String cardPin = event.cardPin;
    if (cardPin.length != 4) {
      emit(PinVerificationFailure('Please enter a valid 4-digit PIN'));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final cardUid = prefs.getString('cardId');
    String? jwtToken = prefs.getString('jwt_token');
    String? refreshToken = prefs.getString('refresh_token');

    if (cardUid == null) {
      emit(PinVerificationFailure('Card ID not found'));
      return;
    }

    if (jwtToken == null || refreshToken == null) {
      emit(PinVerificationSessionExpired());
      return;
    }

    if (JwtDecoder.isExpired(jwtToken)) {
      jwtToken = await _refreshToken(refreshToken);
      if (jwtToken == null) {
        emit(PinVerificationSessionExpired());
        return;
      }
    }

    final url = Uri.parse(Config.verify_card_pin);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Deviceid': Config.deviceId,
        'Authorization': 'Bearer $jwtToken'
      },
      body: jsonEncode({
        'card_uid': cardUid,
        'card_pin': cardPin,
      }),
    );

    final responseData = jsonDecode(response.body);
    final status = responseData["status"];
    final message = responseData["message"];
    final status_code = responseData['status_code'];

    if (response.statusCode == 200) {
      if (status == 'Success') {
        emit(PinVerificationSuccess(message));
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
              'card_pin': cardPin,
            }),
          );

          final retryResponseData = jsonDecode(retryResponse.body);
          final retryStatus = retryResponseData["status"];
          final retryMessage = retryResponseData["message"];

          if (retryResponse.statusCode == 200) {
            if (retryStatus == 'Success') {
              emit(PinVerificationSuccess(retryMessage));
            } else {
              emit(PinVerificationFailure(retryMessage));
            }
          } else {
            emit(PinVerificationFailure('Failed to verify PIN'));
          }
        } else {
          emit(PinVerificationSessionExpired());
        }
      } else {
        emit(PinVerificationFailure(message));
      }
    } else {
      emit(PinVerificationFailure('Failed to verify PIN'));
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
