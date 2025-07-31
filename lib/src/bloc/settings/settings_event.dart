part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}
class ToggleTheme extends SettingsEvent {}

// Log out the user
class Logout extends SettingsEvent {}

// Delete/Deactivate user account
class DeleteAccount extends SettingsEvent {}

class ChangeLanguage extends SettingsEvent {
  final String language;

  const ChangeLanguage(this.language);

  @override
  List<Object> get props => [language];
}

class ChangeCurrency extends SettingsEvent {
  final String currency;

  const ChangeCurrency(this.currency);

  @override
  List<Object> get props => [currency];
}
