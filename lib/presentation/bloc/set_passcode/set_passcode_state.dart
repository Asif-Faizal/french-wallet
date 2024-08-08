import 'package:equatable/equatable.dart';

abstract class SetPasscodeState extends Equatable {
  const SetPasscodeState();

  @override
  List<Object> get props => [];
}

class PasscodeInitial extends SetPasscodeState {}

class PasscodeLoading extends SetPasscodeState {}

class PasscodeSuccess extends SetPasscodeState {
  final String message;

  const PasscodeSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class PasscodeFailure extends SetPasscodeState {
  final String message;

  const PasscodeFailure(this.message);

  @override
  List<Object> get props => [message];
}
