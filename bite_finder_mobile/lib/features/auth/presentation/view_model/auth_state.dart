import '../../domain/entities/user_entity.dart';

class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final String? token;
  final UserEntity? user;
  final String? error;

  const AuthState({
    required this.isLoading,
    required this.isLoggedIn,
    this.token,
    this.user,
    this.error,
  });

  factory AuthState.initial() => const AuthState(
        isLoading: false,
        isLoggedIn: false,
      );

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    String? token,
    UserEntity? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      token: token ?? this.token,
      user: user ?? this.user,
      error: error,
    );
  }
}
