import 'package:flutter_bloc/flutter_bloc.dart';
import 'set_pin_event.dart';
import 'set_pin_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../shared/config/api_config.dart';

class SetTransactionPinBloc
    extends Bloc<SetTransactionPinEvent, SetTransactionPinState> {
  SetTransactionPinBloc() : super(SetTransactionPinInitial()) {
    on<SubmitPinEvent>(_onSubmitPinEvent);
  }

  Future<void> _onSubmitPinEvent(
      SubmitPinEvent event, Emitter<SetTransactionPinState> emit) async {
    emit(SetTransactionPinLoading());
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwtToken = prefs.getString('jwt_token');

      final Map<String, String> headers = {
        'X-Password': Config.password,
        'X-Username': Config.username,
        'Appversion': Config.appVersion,
        'Content-Type': 'application/json',
        'Deviceid': Config.deviceId,
        'Authorization': 'Bearer $jwtToken',
      };

      final body = {
        "pin": event.pin,
        "re_pin": event.confirmPin,
        "password": 'passcode'
      };

      final response = await http.post(
        Uri.parse(Config.set_transaction_pin),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final status = responseData["status"];
        final message = responseData["message"];

        if (status == 'Success') {
          emit(SetTransactionPinSuccess(message));
        } else {
          emit(SetTransactionPinFailure(message));
        }
      } else {
        final responseData = jsonDecode(response.body);
        final message = responseData["message"];
        emit(SetTransactionPinFailure(message));
      }
    } catch (e) {
      emit(SetTransactionPinFailure('Exception: $e'));
    }
  }
}
