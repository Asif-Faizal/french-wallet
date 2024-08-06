import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/config/api_config.dart';
import 'package:http/http.dart' as http;

part 'change_card_status_event.dart';
part 'change_card_status_state.dart';

class ChangeCardStatusBloc
    extends Bloc<ChangeCardStatusEvent, ChangeCardStatusState> {
  ChangeCardStatusBloc() : super(ChangeCardStatusInitial()) {
    on<ChangeStatus>(_onVerifyPin);
  }

  Future<void> _onVerifyPin(
      ChangeStatus event, Emitter<ChangeCardStatusState> emit) async {
    emit(ChangeCardStatusLoading());

    final int cardStatus = event.cardStatus;

    final prefs = await SharedPreferences.getInstance();
    final cardUid = prefs.getString('cardId');
    String? jwtToken = prefs.getString('jwt_token');
    String? refreshToken = prefs.getString('refresh_token');

    if (cardUid == null) {
      emit(ChangeCardStatusFailure('Card ID not found'));
      return;
    }

    if (jwtToken == null || refreshToken == null) {
      emit(ChangeCardStatusSessionExpired());
      return;
    }

    if (JwtDecoder.isExpired(jwtToken)) {
      jwtToken = await _refreshToken(refreshToken);
      if (jwtToken == null) {
        emit(ChangeCardStatusSessionExpired());
        return;
      }
    }

    final url = Uri.parse(Config.change_card_status);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Deviceid': Config.deviceId,
        'Authorization': 'Bearer $jwtToken'
      },
      body: jsonEncode({
        'card_uid': cardUid,
        'status': cardStatus,
      }),
    );
    print(cardUid);
    print(cardStatus);
    print(response.body);
    final responseData = jsonDecode(response.body);
    final status = responseData["status"];
    final message = responseData["message"];
    final status_code = responseData['status_code'];

    if (response.statusCode == 200) {
      if (status == 'Success') {
        emit(ChangeCardStatusSuccess(message));
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
              'status': cardStatus,
            }),
          );

          final retryResponseData = jsonDecode(retryResponse.body);
          final retryStatus = retryResponseData["status"];
          final retryMessage = retryResponseData["message"];

          if (retryResponse.statusCode == 200) {
            if (retryStatus == 'Success') {
              emit(ChangeCardStatusSuccess(retryMessage));
            } else {
              emit(ChangeCardStatusFailure(retryMessage));
            }
          } else {
            emit(ChangeCardStatusFailure('Failed to verify PIN'));
          }
        } else {
          emit(ChangeCardStatusSessionExpired());
        }
      } else {
        emit(ChangeCardStatusFailure(message));
      }
    } else {
      emit(ChangeCardStatusFailure('Failed to verify PIN'));
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
