import 'package:equatable/equatable.dart';
import '../../../domain/login/login_entity.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final LoginEntity loginEntity;

  LoginSuccess(this.loginEntity);

  @override
  List<Object> get props => [loginEntity];
}

class LoginError extends LoginState {
  final String message;

  LoginError(this.message);

  @override
  List<Object> get props => [message];
}
