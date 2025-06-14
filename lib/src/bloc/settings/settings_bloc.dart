import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stadium_food/src/data/repositories/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository = SettingsRepository();

  SettingsBloc() : super(SettingsInitial()) {
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
  }
}
