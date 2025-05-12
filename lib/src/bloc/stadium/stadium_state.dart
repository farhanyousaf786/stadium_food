part of 'stadium_bloc.dart';

@immutable
abstract class StadiumState {}

class StadiumInitial extends StadiumState {}

class StadiumsLoading extends StadiumState {}

class StadiumsLoaded extends StadiumState {
  final List<Stadium> stadiums;

  StadiumsLoaded(this.stadiums);
}

class StadiumError extends StadiumState {
  final String message;

  StadiumError(this.message);
}
