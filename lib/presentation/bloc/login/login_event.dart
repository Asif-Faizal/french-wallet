import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginSubmitted extends LoginEvent {
  final String mobile;
  final String password;

  LoginSubmitted({required this.mobile, required this.password});

  @override
  List<Object> get props => [mobile, password];
}
