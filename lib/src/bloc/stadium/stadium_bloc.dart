import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/stadium_theme.dart';
import '../../data/models/stadium.dart';
import '../../data/models/section.dart';
import '../../data/repositories/stadium_repository.dart';
import '../../presentation/utils/app_colors.dart';

part 'stadium_event.dart';
part 'stadium_state.dart';

class StadiumBloc extends Bloc<StadiumEvent, StadiumState> {
  final StadiumRepository _repository = StadiumRepository();
  Stadium? _selectedStadium;

  Stadium? get selectedStadium => _selectedStadium;

  /// Last applied venue ThemeData (consumed by UI after SelectStadium).
  StadiumTheme? lastAppliedTheme;

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

        // Apply venue branding (color / logo / banner / brandName)
        final venue = StadiumTheme.fromStadium(event.stadium);
        AppColors.brandName = venue.appName;
        AppColors.logoUrl = venue.logoUrl;
        AppColors.bannerUrl = venue.bannerUrl;
        lastAppliedTheme = venue;
        venue.apply();
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selected_stadium_id', event.stadium.id);
        await prefs.setString('selected_stadium_name', event.stadium.name);
        
        // Save full stadium branding for splash / cold start restore
        var box = Hive.box('myBox');
        box.put('selectedStadium', event.stadium.toHiveMap());
        
        emit(StadiumSelected(event.stadium));
      } catch (e) {
        emit(StadiumError(e.toString()));
      }
    });

    on<FetchSections>((event, emit) async {
      emit(SectionsLoading());
      try {
        final sections = await _repository.fetchSections(event.stadiumId);
        emit(SectionsLoaded(sections));
      } catch (e) {
        emit(SectionsError(e.toString()));
      }
    });
  }
}
