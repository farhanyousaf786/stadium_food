part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

// Toggle theme between light and dark mode
class ToggleTheme extends SettingsEvent {}

// Log out the user
class Logout extends SettingsEvent {}
