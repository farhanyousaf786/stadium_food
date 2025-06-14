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
