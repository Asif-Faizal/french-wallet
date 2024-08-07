import 'package:equatable/equatable.dart';

abstract class SentOtpState extends Equatable {
  const SentOtpState();

  @override
  List<Object> get props => [];
}

class SentOtpInitial extends SentOtpState {}

class SentOtpLoading extends SentOtpState {}

class SentOtpSuccess extends SentOtpState {}

class SentOtpFailure extends SentOtpState {
  final String message;

  const SentOtpFailure(this.message);

  @override
  List<Object> get props => [message];
}
