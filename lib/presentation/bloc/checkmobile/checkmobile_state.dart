import 'package:equatable/equatable.dart';

abstract class CheckMobileState extends Equatable {
  @override
  List<Object> get props => [];
}

class CheckMobileInitial extends CheckMobileState {}

class CheckMobileLoading extends CheckMobileState {}

class CheckMobileSuccess extends CheckMobileState {}

class CheckMobileError extends CheckMobileState {
  final String message;

  CheckMobileError({required this.message});

  @override
  List<Object> get props => [message];
}
