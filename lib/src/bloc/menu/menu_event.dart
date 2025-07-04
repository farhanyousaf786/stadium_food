part of 'menu_bloc.dart';

abstract class MenuEvent {}

class LoadStadiumMenu extends MenuEvent {
  final String stadiumId;
  final int limit;
  final DocumentSnapshot? lastDocument;

  LoadStadiumMenu({
    required this.stadiumId,
    required this.limit,
    this.lastDocument,
  });
}

class FilterMenuByCategory extends MenuEvent {
  final String category;
  final String stadiumId;

  FilterMenuByCategory({
    required this.category,
    required this.stadiumId,
  });
}
