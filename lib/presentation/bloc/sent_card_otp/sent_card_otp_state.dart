abstract class SentCardOtpState {}

class SentCardOtpInitial extends SentCardOtpState {}

class SentCardOtpLoading extends SentCardOtpState {}

class SentCardOtpSuccess extends SentCardOtpState {
  final String message;

  SentCardOtpSuccess(this.message);
}

class SentCardOtpFailure extends SentCardOtpState {
  final String message;

  SentCardOtpFailure(this.message);
}

class SentCardOtpSessionExpired extends SentCardOtpState {}
