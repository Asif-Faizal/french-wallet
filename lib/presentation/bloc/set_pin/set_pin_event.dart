import 'package:equatable/equatable.dart';

abstract class SetTransactionPinEvent extends Equatable {
  const SetTransactionPinEvent();

  @override
  List<Object?> get props => [];
}

class SubmitPinEvent extends SetTransactionPinEvent {
  final String pin;
  final String confirmPin;

  const SubmitPinEvent(this.pin, this.confirmPin);

  @override
  List<Object?> get props => [pin, confirmPin];
}
