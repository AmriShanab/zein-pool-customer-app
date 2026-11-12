import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../../domain/entities/customer_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return const FlutterSecureStorageServiceImpl();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(secureStorage: storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(apiClient: client, secureStorage: storage);
});

enum AuthStatus {
  initial,
  loading,
  codeSent,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.customer,
    this.mobile,
    this.challenge,
    this.errorMessage,
  });

  final AuthStatus status;
  final CustomerProfile? customer;
  final String? mobile;
  final OtpChallenge? challenge;
  final String? errorMessage;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && customer != null;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasCodeSent => status == AuthStatus.codeSent;

  AuthState copyWith({
    AuthStatus? status,
    CustomerProfile? customer,
    String? mobile,
    OtpChallenge? challenge,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      customer: customer ?? this.customer,
      mobile: mobile ?? this.mobile,
      challenge: challenge ?? this.challenge,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({required this.authRepository}) : super(const AuthState()) {
    checkAuthStatus();
  }

  final AuthRepository authRepository;

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final isAuth = await authRepository.isAuthenticated();
      if (!isAuth) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }
      final profile = await authRepository.getProfile();
      if (profile != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          customer: profile,
          mobile: profile.mobile,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> requestOtp(String mobile) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final challenge = await authRepository.requestOtp(mobile);
      state = state.copyWith(
        status: AuthStatus.codeSent,
        mobile: mobile,
        challenge: challenge,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst(RegExp(r'^[^:]*:\s*'), ''),
      );
      return false;
    }
  }

  Future<bool> verifyOtp(String otp, {String? name}) async {
    final mobile = state.mobile;
    if (mobile == null) return false;

    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final profile = await authRepository.verifyOtp(
        mobile: mobile,
        otp: otp,
        name: name,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        customer: profile,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.codeSent,
        errorMessage: e.toString().replaceFirst(RegExp(r'^[^:]*:\s*'), ''),
      );
      return false;
    }
  }

  Future<bool> updateProfile({required String name, String? notes}) async {
    try {
      final updated = await authRepository.updateProfile(
        name: name,
        notes: notes,
      );
      state = state.copyWith(customer: updated);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceFirst(RegExp(r'^[^:]*:\s*'), ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    await authRepository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void reset() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository: repo);
});
