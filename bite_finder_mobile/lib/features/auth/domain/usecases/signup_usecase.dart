import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repo;

  SignUpUseCase(this._repo);

  Future<AuthSession> call(SignUpParams params) {
    return _repo.signUp(params);
  }
}
