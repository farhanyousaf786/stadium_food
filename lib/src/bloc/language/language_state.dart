part of 'language_bloc.dart';

abstract class LanguageState extends Equatable {
  final Locale locale;

  const LanguageState(this.locale);

  @override
  List<Object> get props => [locale];
}

class LanguageInitial extends LanguageState {
  const LanguageInitial(Locale locale) : super(locale);
}

class LanguageLoadSuccess extends LanguageState {
  const LanguageLoadSuccess(Locale locale) : super(locale);
}
