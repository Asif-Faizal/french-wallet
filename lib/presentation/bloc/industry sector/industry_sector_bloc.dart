import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/signup/industry_sector/industry_type_entity.dart';
import '../../../domain/signup/industry_sector/get_industry_sector.dart';

part 'industry_sector_event.dart';
part 'industry_sector_state.dart';

class IndustrySectorBloc
    extends Bloc<IndustrySectorEvent, IndustrySectorState> {
  final GetIndustrySectors getIndustrySectors;

  IndustrySectorBloc({required this.getIndustrySectors})
      : super(IndustrySectorInitial()) {
    on<FetchIndustrySectors>(_onFetchIndustrySectors);
  }

  Future<void> _onFetchIndustrySectors(
    FetchIndustrySectors event,
    Emitter<IndustrySectorState> emit,
  ) async {
    try {
      emit(IndustrySectorLoading());
      final industrySectors = await getIndustrySectors();
      emit(IndustrySectorLoaded(industrySectors));
    } catch (_) {
      emit(IndustrySectorError('Failed to load industry sectors'));
    }
  }
}
