part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;
  final String fcmToken;

  LoginSubmitted({
    required this.email,
    required this.password,
    required this.fcmToken,
  });
}
