import 'package:equatable/equatable.dart';

abstract class SetPasscodeEvent extends Equatable {
  const SetPasscodeEvent();

  @override
  List<Object> get props => [];
}

class PasscodeSet extends SetPasscodeEvent {
  final String passcode;
  final String confirmPasscode;

  const PasscodeSet({required this.passcode, required this.confirmPasscode});

  @override
  List<Object> get props => [passcode, confirmPasscode];
}
