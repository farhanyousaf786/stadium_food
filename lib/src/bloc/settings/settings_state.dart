part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

// Theme states
class ThemeToggled extends SettingsState {}

class ThemeToggleFailure extends SettingsState {}

// Logout states
class LogoutInProgress extends SettingsState {}

class LogoutSuccess extends SettingsState {}

class LogoutFailure extends SettingsState {}

// Account deletion states
class AccountDeletionInProgress extends SettingsState {}

class AccountDeletionSuccess extends SettingsState {}

class AccountDeletionFailure extends SettingsState {
  final String message;

  const AccountDeletionFailure(this.message);

  @override
  List<Object> get props => [message];
}

class LanguageChanged extends SettingsState {
  final String language;

  const LanguageChanged(this.language);

  @override
  List<Object> get props => [language];
}

class LanguageChangeFailure extends SettingsState {
  final String error;

  const LanguageChangeFailure(this.error);

  @override
  List<Object> get props => [error];
}

class CurrencyChanged extends SettingsState {
  final String currency;

  const CurrencyChanged(this.currency);

  @override
  List<Object> get props => [currency];
}

class CurrencyChangeFailure extends SettingsState {
  final String error;

  const CurrencyChangeFailure(this.error);

  @override
  List<Object> get props => [error];
}
