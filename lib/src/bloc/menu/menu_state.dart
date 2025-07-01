part of 'menu_bloc.dart';

abstract class MenuState {}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<Food> foods;
  final DocumentSnapshot? lastDocument;

  MenuLoaded({
    required this.foods,
    required this.lastDocument,
  });
}

class MenuError extends MenuState {
  final String message;

  MenuError({required this.message});
}
