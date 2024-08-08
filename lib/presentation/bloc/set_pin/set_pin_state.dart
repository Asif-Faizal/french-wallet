import 'package:equatable/equatable.dart';

abstract class SetTransactionPinState extends Equatable {
  const SetTransactionPinState();

  @override
  List<Object?> get props => [];
}

class SetTransactionPinInitial extends SetTransactionPinState {}

class SetTransactionPinLoading extends SetTransactionPinState {}

class SetTransactionPinSuccess extends SetTransactionPinState {
  final String message;

  const SetTransactionPinSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SetTransactionPinFailure extends SetTransactionPinState {
  final String error;

  const SetTransactionPinFailure(this.error);

  @override
  List<Object?> get props => [error];
}
