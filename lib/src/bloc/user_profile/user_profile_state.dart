part of 'user_profile_bloc.dart';

abstract class UserProfileState {}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileSuccess extends UserProfileState {}

class UserProfileError extends UserProfileState {
  final String error;

  UserProfileError({required this.error});
}
