import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CheckMobileEvent extends LoginEvent {
  final String mobile;

  CheckMobileEvent({required this.mobile});

  @override
  List<Object> get props => [mobile];
}
