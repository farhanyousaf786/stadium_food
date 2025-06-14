import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeInitial()) {
    on<ToggleTheme>((event, emit) {
      final isDarkMode = state is ThemeChanged ? 
        (state as ThemeChanged).themeData.brightness == Brightness.dark : false;
      
      final newTheme = isDarkMode ? 
        ThemeData.light().copyWith(
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ) : 
        ThemeData.dark().copyWith(
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[900],
        );

      emit(ThemeChanged(themeData: newTheme));
    });

    on<ChangeTheme>((event, emit) {
      emit(ThemeChanged(themeData: event.themeData));
    });
  }
}
