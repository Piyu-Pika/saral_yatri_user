import 'package:dev_log/dev_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../../core/services/auth_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRepository(authService);
});

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<UserModel?> login(String username, String password) async {
    try {
      final user =
          await _authService.login(username: username, password: password);
      Log.i('Login successful for user: ${user.email}');
      return user;
    } catch (e) {
      Log.e('Login failed: $e');
      throw Exception('Login failed: $e');
    }
  }

  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final user = await _authService.register(
        username: name,
        email: email,
        password: password,
        phone: phone,
        role: 'user', // Default role
        fullName: name,
      );
      Log.i('Registration successful for user: ${user.email}');
      return user;
    } catch (e) {
      Log.e('Registration failed: $e');
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      Log.i('User logged out successfully');
    } catch (e) {
      Log.e('Error during logout: $e');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      return _authService.currentUser;
    } catch (e) {
      Log.e('Error getting current user: $e');
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      return _authService.isLoggedIn;
    } catch (e) {
      Log.e('Error checking login status: $e');
      return false;
    }
  }
}
