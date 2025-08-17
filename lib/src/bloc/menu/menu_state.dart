part of 'menu_bloc.dart';

abstract class MenuState {}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<Food> foods;


  MenuLoaded({
    required this.foods,

  });
}

class MenuError extends MenuState {
  final String message;

  MenuError({required this.message});
}
