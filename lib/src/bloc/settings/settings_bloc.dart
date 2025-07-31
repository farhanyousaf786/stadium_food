import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stadium_food/src/data/services/currency_service.dart';
import 'package:stadium_food/src/data/services/language_service.dart';

import '../../data/repositories/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository = SettingsRepository();
  SettingsBloc() : super(SettingsInitial()) {
    on<ChangeLanguage>((event, emit) {
      try {
        LanguageService.setLanguage(event.language);
        emit(LanguageChanged(event.language));
      } catch (e) {
        emit(LanguageChangeFailure(e.toString()));
      }
    });

    on<ChangeCurrency>((event, emit) {
      try {
        CurrencyService.setCurrency(event.currency);
        emit(CurrencyChanged(event.currency));
      } catch (e) {
        emit(CurrencyChangeFailure(e.toString()));
      }
    });

    on<ToggleTheme>((event, emit) async {
      try {
        await settingsRepository.toggleTheme();
        emit(ThemeToggled());
      } catch (e) {
        emit(ThemeToggleFailure());
      }
    });

    on<Logout>((event, emit) async {
      emit(LogoutInProgress());
      try {
        await settingsRepository.logout();
        emit(LogoutSuccess());
      } catch (e) {
        emit(LogoutFailure());
      }
    });

    on<DeleteAccount>((event, emit) async {
      emit(AccountDeletionInProgress());
      try {
        await settingsRepository.deactivateAccount();
        emit(AccountDeletionSuccess());
      } catch (e) {
        emit(AccountDeletionFailure(e.toString()));
      }
    });
  }
}
