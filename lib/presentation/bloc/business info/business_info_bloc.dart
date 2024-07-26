import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/signup/business_type_entity.dart';
import '../../../domain/signup/get_business_type.dart';

part 'business_info_event.dart';
part 'business_info_state.dart';

class BusinessTypeBloc extends Bloc<BusinessTypeEvent, BusinessTypeState> {
  final GetBusinessTypes getBusinessTypes;

  BusinessTypeBloc({required this.getBusinessTypes})
      : super(BusinessTypeInitial()) {
    on<FetchBusinessTypes>(_onFetchBusinessTypes);
  }

  Future<void> _onFetchBusinessTypes(
    FetchBusinessTypes event,
    Emitter<BusinessTypeState> emit,
  ) async {
    try {
      emit(BusinessTypeLoading());
      final businessTypes = await getBusinessTypes();
      emit(BusinessTypeLoaded(businessTypes));
    } catch (_) {
      emit(BusinessTypeError('Failed to load business types'));
    }
  }
}
