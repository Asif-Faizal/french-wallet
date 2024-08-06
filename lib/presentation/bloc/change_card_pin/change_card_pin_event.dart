abstract class ChangeCardPinEvent {}

class ChangePin extends ChangeCardPinEvent {
  final String cardPin;
  final String otp;

  ChangePin(this.cardPin, this.otp);
}
