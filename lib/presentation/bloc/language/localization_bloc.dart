import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'localization_event.dart';
part 'localization_state.dart';

class LocalizationBloc extends Bloc<LocalizationEvent, LocalizationState> {
  LocalizationBloc() : super(LocalizationState(const Locale('en'))) {
    on<LocalizationChanged>((event, emit) {
      emit(LocalizationState(event.locale));
    });
  }
}
