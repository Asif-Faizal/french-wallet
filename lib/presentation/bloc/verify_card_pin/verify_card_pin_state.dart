abstract class PinVerificationState {}

class PinVerificationInitial extends PinVerificationState {}

class PinVerificationLoading extends PinVerificationState {}

class PinVerificationSuccess extends PinVerificationState {
  final String message;

  PinVerificationSuccess(this.message);
}

class PinVerificationFailure extends PinVerificationState {
  final String message;

  PinVerificationFailure(this.message);
}

class PinVerificationSessionExpired extends PinVerificationState {}
