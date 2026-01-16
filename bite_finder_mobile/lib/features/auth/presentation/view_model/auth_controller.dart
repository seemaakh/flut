import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_dependencies.dart';
import 'auth_state.dart';

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState.initial();
  }

  Future<void> init() async {
    final repo = ref.read(authRepositoryProvider);
    final token = await repo.getSavedToken();
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(isLoggedIn: true, token: token);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await ref.read(loginUseCaseProvider).call(
            email: email,
            password: password,
          );
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        token: session.token,
        user: session.user,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signUp(SignUpParams params) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(signUpUseCaseProvider).call(params);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signUpAndLogin(SignUpParams params) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(signUpUseCaseProvider).call(params);
      try {
        final session = await ref.read(loginUseCaseProvider).call(
              email: params.email,
              password: params.password,
            );
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: true,
          token: session.token,
          user: session.user,
        );
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
        throw Exception('Signup succeeded but login failed: ${e.toString()}');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider).call();
    state = AuthState.initial();
  }
}
