import 'package:equatable/equatable.dart';

abstract class UserProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserProfileLoadEvent extends UserProfileEvent {}
