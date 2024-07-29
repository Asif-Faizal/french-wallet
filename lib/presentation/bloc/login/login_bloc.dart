import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/login/login.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;

  LoginBloc({required this.loginUseCase}) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final loginEntity =
          await loginUseCase.execute(event.mobile, event.password);
      emit(LoginSuccess(loginEntity));
    } catch (e) {
      emit(LoginError('Login failed'));
    }
  }
}
