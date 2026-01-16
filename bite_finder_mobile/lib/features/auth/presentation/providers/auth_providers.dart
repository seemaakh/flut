import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_model/auth_controller.dart';
import '../view_model/auth_state.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});
