import 'package:equatable/equatable.dart';

abstract class CheckEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CheckMobileEvent extends CheckEvent {
  final String mobile;

  CheckMobileEvent({required this.mobile});

  @override
  List<Object> get props => [mobile];
}
