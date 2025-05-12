import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/stadium.dart';
import '../../data/repositories/stadium_repository.dart';

part 'stadium_event.dart';
part 'stadium_state.dart';

class StadiumBloc extends Bloc<StadiumEvent, StadiumState> {
  final StadiumRepository _repository = StadiumRepository();

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
  }
}
