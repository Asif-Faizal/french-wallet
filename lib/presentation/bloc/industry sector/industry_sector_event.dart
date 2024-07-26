part of 'industry_sector_bloc.dart';

abstract class IndustrySectorEvent extends Equatable {
  const IndustrySectorEvent();

  @override
  List<Object> get props => [];
}

class FetchIndustrySectors extends IndustrySectorEvent {}
