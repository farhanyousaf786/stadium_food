part of 'stadium_bloc.dart';

@immutable
abstract class StadiumState {}

class StadiumInitial extends StadiumState {}

class StadiumsLoading extends StadiumState {}

class StadiumsLoaded extends StadiumState {
  final List<Stadium> stadiums;

  StadiumsLoaded(this.stadiums);
}

class StadiumSelected extends StadiumState {
  final Stadium stadium;

  StadiumSelected(this.stadium);
}

class StadiumError extends StadiumState {
  final String message;

  StadiumError(this.message);
}

class SectionsLoading extends StadiumState {}

class SectionsLoaded extends StadiumState {
  final List<Section> sections;

  SectionsLoaded(this.sections);
}

class SectionsError extends StadiumState {
  final String message;

  SectionsError(this.message);
}
