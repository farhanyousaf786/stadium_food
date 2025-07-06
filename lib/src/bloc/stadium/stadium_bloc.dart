import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/stadium.dart';
import '../../data/repositories/stadium_repository.dart';

part 'stadium_event.dart';
part 'stadium_state.dart';

class StadiumBloc extends Bloc<StadiumEvent, StadiumState> {
  final StadiumRepository _repository = StadiumRepository();
  Stadium? _selectedStadium;

  Stadium? get selectedStadium => _selectedStadium;

  StadiumBloc() : super(StadiumInitial()) {
    on<LoadStadiums>((event, emit) async {
      emit(StadiumsLoading());
      try {
        final stadiums = await _repository.fetchStadiums();
        emit(StadiumsLoaded(stadiums));
      } catch (e) {
        emit(StadiumError(e.toString()));
      }
    });

    on<SearchStadiums>((event, emit) async {
      emit(StadiumsLoading());
      try {
        final stadiums = await _repository.searchStadiums(event.query);
        emit(StadiumsLoaded(stadiums));
      } catch (e) {
        emit(StadiumError(e.toString()));
      }
    });

    on<SelectStadium>((event, emit) async {
      try {
        _selectedStadium = event.stadium;
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selected_stadium_id', event.stadium.id);
        await prefs.setString('selected_stadium_name', event.stadium.name);
        
        emit(StadiumSelected(event.stadium));
      } catch (e) {
        emit(StadiumError(e.toString()));
      }
    });
  }
}
