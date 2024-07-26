part of 'business_info_bloc.dart';

abstract class BusinessTypeEvent extends Equatable {
  const BusinessTypeEvent();

  @override
  List<Object> get props => [];
}

class FetchBusinessTypes extends BusinessTypeEvent {}
