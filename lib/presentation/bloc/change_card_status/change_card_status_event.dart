part of 'change_card_status_bloc.dart';

@immutable
abstract class ChangeCardStatusEvent {}

class ChangeStatus extends ChangeCardStatusEvent {
  final int cardStatus;

  ChangeStatus(this.cardStatus);
}
