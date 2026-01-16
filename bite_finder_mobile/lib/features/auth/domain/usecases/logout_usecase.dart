import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repo;

  LogoutUseCase(this._repo);

  Future<void> call() {
    return _repo.logout();
  }
}
