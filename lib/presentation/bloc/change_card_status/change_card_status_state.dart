part of 'change_card_status_bloc.dart';

@immutable
abstract class ChangeCardStatusState {}

class ChangeCardStatusInitial extends ChangeCardStatusState {}

class ChangeCardStatusLoading extends ChangeCardStatusState {}

class ChangeCardStatusSuccess extends ChangeCardStatusState {
  final String message;

  ChangeCardStatusSuccess(this.message);
}

class ChangeCardStatusFailure extends ChangeCardStatusState {
  final String message;

  ChangeCardStatusFailure(this.message);
}

class ChangeCardStatusSessionExpired extends ChangeCardStatusState {}
