import 'user_entity.dart';

class AuthSession {
  final String token;
  final UserEntity user;

  const AuthSession({required this.token, required this.user});
}
