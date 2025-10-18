import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dev_log/dev_log.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(
  ref.read(authServiceProvider),
));

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isLoggedIn;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isLoggedIn,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState()) {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        state = state.copyWith(
          user: user,
          isLoggedIn: true,
        );
      }
    } catch (e) {
      Log.e('Error checking login status: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authRepository.login(username, password);
      if (user != null) {
        state = state.copyWith(
          user: user,
          isLoading: false,
          isLoggedIn: true,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Login failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      if (user != null) {
        state = state.copyWith(
          user: user,
          isLoading: false,
          isLoggedIn: true,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Registration failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      state = AuthState();
    } catch (e) {
      Log.e('Error during logout: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}