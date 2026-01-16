import '../../domain/entities/auth_session.dart';
import 'user_model.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({required super.token, required super.user});

  factory AuthSessionModel.fromLoginResponse(Map<String, dynamic> json) {
    final token = (json['token'] ?? '').toString();
    final userJson = (json['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    return AuthSessionModel(token: token, user: UserModel.fromJson(userJson));
  }

  /// Signup endpoint in the provided API returns only `{ success, data }`.
  /// We treat it as "session created" with empty token.
  factory AuthSessionModel.fromSignupResponse(Map<String, dynamic> json) {
    final userJson = (json['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    return AuthSessionModel(token: '', user: UserModel.fromJson(userJson));
  }
}
