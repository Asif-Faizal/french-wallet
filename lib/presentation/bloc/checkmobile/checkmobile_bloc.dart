import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/checkmobile/checkmobile_model.dart';
import '../../../domain/checkmobile/checkmobile.dart';
import 'checkmobile_event.dart';
import 'checkmobile_state.dart';

class CheckMobileBloc extends Bloc<CheckMobileEvent, CheckMobileState> {
  final CheckMobileUseCase checkMobileUseCase;

  CheckMobileBloc({required this.checkMobileUseCase})
      : super(CheckMobileInitial()) {
    on<CheckMobileEvent>(_onCheckMobileEvent);
  }

  Future<void> _onCheckMobileEvent(
      CheckMobileEvent event, Emitter<CheckMobileState> emit) async {
    emit(CheckMobileLoading());
    try {
      final CheckMobileResponseModel response =
          await checkMobileUseCase.call(event.mobile);
      if (response.userLinkedDevices == 0 && response.primaryDevice == 0) {
        emit(CheckMobileError(
            message:
                'Sign Up: Please sign in, as your mobile number is not registered with our application'));
      } else if (response.userLinkedDevices == 0 &&
          response.primaryDevice == 1) {
        emit(CheckMobileSuccess());
      } else {
        emit(CheckMobileSuccess());
      }
    } catch (e) {
      emit(CheckMobileError(message: e.toString()));
    }
  }
}
