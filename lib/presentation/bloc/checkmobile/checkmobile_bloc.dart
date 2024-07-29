import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/checkmobile/checkmobile_model.dart';
import '../../../domain/checkmobile/checkmobile.dart';
import 'checkmobile_event.dart';
import 'checkmobile_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final CheckMobileUseCase checkMobileUseCase;

  LoginBloc({required this.checkMobileUseCase}) : super(LoginInitial()) {
    on<CheckMobileEvent>(_onCheckMobileEvent);
  }

  Future<void> _onCheckMobileEvent(
      CheckMobileEvent event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      // Call the use case and get the response
      final CheckMobileResponseModel response =
          await checkMobileUseCase.call(event.mobile);

      // Handle the response based on the data
      if (response.userLinkedDevices == 0 && response.primaryDevice == 0) {
        emit(LoginError(
            message:
                'Sign Up: Please sign in, as your mobile number is not registered with our application'));
      } else if (response.userLinkedDevices == 0 &&
          response.primaryDevice == 1) {
        emit(LoginSuccess());
      } else {
        // Handle other cases if needed
        emit(LoginSuccess()); // Or emit a specific state
      }
    } catch (e) {
      emit(LoginError(message: e.toString()));
    }
  }
}
