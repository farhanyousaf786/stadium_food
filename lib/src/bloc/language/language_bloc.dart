import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:stadium_food/src/data/services/language_service.dart';

part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(LanguageInitial(Locale(LanguageService.getCurrentLanguage()))) {
    on<LanguageLoadStarted>(_onLanguageLoadStarted);
    on<LanguageSelected>(_onLanguageSelected);
  }

  void _onLanguageLoadStarted(
    LanguageLoadStarted event,
    Emitter<LanguageState> emit,
  ) {
    final languageCode = LanguageService.getCurrentLanguage();
    emit(LanguageLoadSuccess(Locale(languageCode)));
  }

  void _onLanguageSelected(
    LanguageSelected event,
    Emitter<LanguageState> emit,
  ) {
    LanguageService.setLanguage(event.languageCode);
    emit(LanguageLoadSuccess(Locale(event.languageCode)));
  }
}
