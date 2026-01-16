import '../entities/auth_session.dart';

class SignUpParams {
  final String name;
  final String email;
  final String username;
  final String password;
  final String phoneNumber;

  const SignUpParams({
    required this.name,
    required this.email,
    required this.username,
    required this.password,
    required this.phoneNumber,
  });
}

abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});

  Future<AuthSession> signUp(SignUpParams params);

  Future<String?> getSavedToken();

  Future<void> logout();
}
