part of 'user_profile_bloc.dart';

abstract class UserProfileEvent {}

class UpdateUserProfile extends UserProfileEvent {
  final String firstName;
  final String lastName;
  final String phone;
  final String? photoUrl;

  UpdateUserProfile({
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.photoUrl,
  });
}
