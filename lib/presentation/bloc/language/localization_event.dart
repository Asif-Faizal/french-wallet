part of 'localization_bloc.dart';

abstract class LocalizationEvent {
  const LocalizationEvent();
}

class LocalizationChanged extends LocalizationEvent {
  final Locale locale;

  const LocalizationChanged(this.locale);
}
