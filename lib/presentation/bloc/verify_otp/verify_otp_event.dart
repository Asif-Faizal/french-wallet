import 'package:equatable/equatable.dart';

abstract class VerifyOtpEvent extends Equatable {
  const VerifyOtpEvent();
}

class VerifyOtp extends VerifyOtpEvent {
  final String mobile;
  final String otp;

  const VerifyOtp(this.mobile, this.otp);

  @override
  List<Object> get props => [mobile, otp];
}
