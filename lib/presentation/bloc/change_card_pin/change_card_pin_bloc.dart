import 'dart:convert';
import 'package:ewallet2/presentation/bloc/change_card_pin/change_card_pin_event.dart';
import 'package:ewallet2/presentation/bloc/change_card_pin/change_card_pin_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../shared/config/api_config.dart';

class ChangeCardPinBloc extends Bloc<ChangeCardPinEvent, ChangeCardPinState> {
  ChangeCardPinBloc() : super(ChangeCardPinInitial()) {
    on<ChangePin>(_onChangeCardPin);
  }

  Future<void> _onChangeCardPin(
      ChangePin event, Emitter<ChangeCardPinState> emit) async {
    emit(ChangeCardPinLoading());

    final String cardPin = event.cardPin;
    final String otp = event.otp;
    if (cardPin.length != 4) {
      emit(ChangeCardPinFailure('Please enter a valid 4-digit PIN'));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final cardUid = prefs.getString('cardId');
    String? jwtToken = prefs.getString('jwt_token');
    String? refreshToken = prefs.getString('refresh_token');

    if (cardUid == null) {
      emit(ChangeCardPinFailure('Card ID not found'));
      return;
    }

    if (jwtToken == null || refreshToken == null) {
      emit(ChangeCardPinSessionExpired());
      return;
    }

    if (JwtDecoder.isExpired(jwtToken)) {
      jwtToken = await _refreshToken(refreshToken);
      if (jwtToken == null) {
        emit(ChangeCardPinSessionExpired());
        return;
      }
    }

    final url = Uri.parse(Config.change_card_pin);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Deviceid': Config.deviceId,
        'Authorization': 'Bearer $jwtToken'
      },
      body: jsonEncode({'card_uid': cardUid, 'card_pin': cardPin, 'otp': otp}),
    );

    final responseData = jsonDecode(response.body);
    final status = responseData["status"];
    final message = responseData["message"];
    final status_code = responseData['status_code'];
    print(response.body);
    if (response.statusCode == 200) {
      if (status == 'Success') {
        emit(ChangeCardPinSuccess(message));
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
            body: jsonEncode(
                {'card_uid': cardUid, 'card_pin': cardPin, 'otp': otp}),
          );

          final retryResponseData = jsonDecode(retryResponse.body);
          final retryStatus = retryResponseData["status"];
          final retryMessage = retryResponseData["message"];

          if (retryResponse.statusCode == 200) {
            if (retryStatus == 'Success') {
              emit(ChangeCardPinSuccess(retryMessage));
            } else {
              emit(ChangeCardPinFailure(retryMessage));
            }
          } else {
            emit(ChangeCardPinFailure('Failed to verify PIN'));
          }
        } else {
          emit(ChangeCardPinSessionExpired());
        }
      } else {
        emit(ChangeCardPinFailure(message));
      }
    } else {
      emit(ChangeCardPinFailure('Failed to verify PIN'));
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
