import '../../../../../core/api/api_client.dart';
import '../../../../../core/api/api_endpoints.dart';
import '../../models/auth_session_model.dart';

class AuthRemoteDataSource {
  final ApiClient _api;

  AuthRemoteDataSource(this._api);

  Future<AuthSessionModel> login({required String email, required String password}) async {
    final res = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.studentLogin,
      data: {
        'email': email,
        'password': password,
      },
    );
    return AuthSessionModel.fromLoginResponse(res.data ?? <String, dynamic>{});
  }

  Future<AuthSessionModel> signUp({
    required String name,
    required String email,
    required String username,
    required String password,
    required String phoneNumber,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.students,
      data: {
        'name': name,
        'email': email,
        'username': username,
        'password': password,
        'phoneNumber': phoneNumber,
      },
    );
    return AuthSessionModel.fromSignupResponse(res.data ?? <String, dynamic>{});
  }
}
