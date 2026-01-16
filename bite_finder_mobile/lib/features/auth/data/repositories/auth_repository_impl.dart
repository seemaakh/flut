import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage/storage_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final StorageService _storage;

  AuthRepositoryImpl({required AuthRemoteDataSource remote, required StorageService storage})
      : _remote = remote,
        _storage = storage;

  @override
  Future<AuthSession> login({required String email, required String password}) async {
    final session = await _remote.login(email: email, password: password);
    if (session.token.isNotEmpty) {
      await _storage.setString(AppConstants.storageAuthTokenKey, session.token);
    }
    return session;
  }

  @override
  Future<AuthSession> signUp(SignUpParams params) async {
    final session = await _remote.signUp(
      name: params.name,
      email: params.email,
      username: params.username,
      password: params.password,
      phoneNumber: params.phoneNumber,
    );

    // Signup endpoint doesn't return token. Do not set token here.
    return session;
  }

  @override
  Future<String?> getSavedToken() async {
    return _storage.getString(AppConstants.storageAuthTokenKey);
  }

  @override
  Future<void> logout() async {
    await _storage.remove(AppConstants.storageAuthTokenKey);
  }
}
