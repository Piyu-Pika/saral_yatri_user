import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(authService, apiService);
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool isLoggedIn;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.isLoggedIn = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isLoggedIn,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final ApiService _apiService;

  AuthNotifier(this._authService, this._apiService) : super(AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    await _authService.initialize();

    if (_authService.isLoggedIn && await _authService.isTokenValid()) {
      state = state.copyWith(
        user: _authService.currentUser,
        isLoggedIn: true,
        isLoading: false,
      );
    } else {
      await _authService.logout();
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> login({required String username, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.post(ApiConstants.login, data: {
        'username': username,
        'password': password,
      });

      final data = response.data['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final userMap = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userMap);

      await _authService.saveAuthData(token, user);

      state = state.copyWith(
        user: user,
        isLoggedIn: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String phone,
    required String password,
    required String fullName,
    required String aadhaarNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.post(ApiConstants.register, data: {
        'username': username,
        'email': email,
        'phone': phone,
        'password': password,
        'full_name': fullName,
        'aadhaar_number': aadhaarNumber,
        'role': 'passenger',
      });

      final data = response.data['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final userMap = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userMap);

      await _authService.saveAuthData(token, user);

      state = state.copyWith(
        user: user,
        isLoggedIn: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }

  
}
