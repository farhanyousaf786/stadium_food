part of 'language_bloc.dart';

abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object> get props => [];
}

class LanguageLoadStarted extends LanguageEvent {}

class LanguageSelected extends LanguageEvent {
  final String languageCode;

  const LanguageSelected(this.languageCode);

  @override
  List<Object> get props => [languageCode];
}
