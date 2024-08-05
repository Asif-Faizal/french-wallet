abstract class PinVerificationEvent {}

class VerifyPin extends PinVerificationEvent {
  final String cardPin;

  VerifyPin(this.cardPin);
}
