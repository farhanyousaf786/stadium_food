part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

// Toggle between light and dark theme
class ToggleTheme extends ThemeEvent {}

// Change to a specific theme
class ChangeTheme extends ThemeEvent {
  final ThemeData themeData;

  const ChangeTheme({required this.themeData});

  @override
  List<Object> get props => [themeData];
}
