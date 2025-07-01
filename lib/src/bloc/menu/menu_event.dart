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
