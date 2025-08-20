part of 'menu_bloc.dart';

abstract class MenuEvent {}

class LoadStadiumMenu extends MenuEvent {
  final String stadiumId;


  LoadStadiumMenu({
    required this.stadiumId,

  });
}

class FilterMenuByCategory extends MenuEvent {
  final String category;

  FilterMenuByCategory({required this.category});
}

class FilterMenuBySearch extends MenuEvent {
  final String query;

  FilterMenuBySearch({required this.query});
}
