part of 'industry_sector_bloc.dart';

abstract class IndustrySectorState extends Equatable {
  const IndustrySectorState();

  @override
  List<Object> get props => [];
}

class IndustrySectorInitial extends IndustrySectorState {}

class IndustrySectorLoading extends IndustrySectorState {}

class IndustrySectorLoaded extends IndustrySectorState {
  final List<IndustrySector> industrySectors;

  const IndustrySectorLoaded(this.industrySectors);

  @override
  List<Object> get props => [industrySectors];
}

class IndustrySectorError extends IndustrySectorState {
  final String message;

  const IndustrySectorError(this.message);

  @override
  List<Object> get props => [message];
}
