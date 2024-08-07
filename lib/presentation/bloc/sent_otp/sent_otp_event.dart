import 'package:equatable/equatable.dart';

abstract class SentOtpEvent extends Equatable {
  const SentOtpEvent();
}

class SendOtp extends SentOtpEvent {
  final String mobile;

  const SendOtp(this.mobile);

  @override
  List<Object> get props => [mobile];
}
