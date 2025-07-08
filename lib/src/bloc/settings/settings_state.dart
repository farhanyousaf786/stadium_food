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
