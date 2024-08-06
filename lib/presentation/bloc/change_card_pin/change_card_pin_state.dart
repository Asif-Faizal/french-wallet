abstract class ChangeCardPinState {}

class ChangeCardPinInitial extends ChangeCardPinState {}

class ChangeCardPinLoading extends ChangeCardPinState {}

class ChangeCardPinSuccess extends ChangeCardPinState {
  final String message;

  ChangeCardPinSuccess(this.message);
}

class ChangeCardPinFailure extends ChangeCardPinState {
  final String message;

  ChangeCardPinFailure(this.message);
}

class ChangeCardPinSessionExpired extends ChangeCardPinState {}
