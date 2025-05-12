part of 'stadium_bloc.dart';

@immutable
abstract class StadiumEvent {}

class LoadStadiums extends StadiumEvent {}

class SearchStadiums extends StadiumEvent {
  final String query;

  SearchStadiums(this.query);
}
