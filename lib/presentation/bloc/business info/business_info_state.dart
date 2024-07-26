part of 'business_info_bloc.dart';

abstract class BusinessTypeState extends Equatable {
  const BusinessTypeState();

  @override
  List<Object> get props => [];
}

class BusinessTypeInitial extends BusinessTypeState {}

class BusinessTypeLoading extends BusinessTypeState {}

class BusinessTypeLoaded extends BusinessTypeState {
  final List<BusinessType> businessTypes;

  const BusinessTypeLoaded(this.businessTypes);

  @override
  List<Object> get props => [businessTypes];
}

class BusinessTypeError extends BusinessTypeState {
  final String message;

  const BusinessTypeError(this.message);

  @override
  List<Object> get props => [message];
}
