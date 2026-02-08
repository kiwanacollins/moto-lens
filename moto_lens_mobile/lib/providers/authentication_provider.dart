import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/auth/auth.dart';
import '../services/services.dart';
import '../utils/error_handler.dart';
import 'authentication_state.dart';

/// Authentication provider for managing app-wide authentication state
///
/// Handles login, logout, registration, token refresh, and persistent
/// authentication state using ChangeNotifier pattern.
class AuthenticationProvider with ChangeNotifier {
  AuthenticationProvider({
    SecureStorageService? secureStorageService,
    ApiService? apiService,
  }) : _secureStorage = secureStorageService ?? SecureStorageService(),
       _apiService = apiService ?? ApiService() {
    _initialize();
  }

  final SecureStorageService _secureStorage;
  final ApiService _apiService;

  AuthenticationState _state = AuthenticationState.initial;
  Timer? _tokenRefreshTimer;

  /// Current authentication state
  AuthenticationState get state => _state;

  /// Convenience getters from state
  bool get isAuthenticated => _state.isAuthenticated;
  bool get isUnauthenticated => _state.isUnauthenticated;
  bool get isLoading => _state.isAuthLoading;
  bool get hasError => _state.hasError;
  User? get currentUser => _state.user;
  String? get error => _state.error;

  /// Initialize authentication state on app start
  Future<void> _initialize() async {
    await _checkStoredAuthentication();
    _startTokenRefreshTimer();
  }

  /// Check for stored authentication tokens
  Future<void> _checkStoredAuthentication() async {
    try {
      _updateState(AuthenticationState.loading());

      final hasValidTokens = await _secureStorage.hasValidTokens();

      if (hasValidTokens) {
        // Try to get current user profile from API
        await _loadUserProfile();
      } else {
        _updateState(AuthenticationState.unauthenticated);
      }
    } catch (e) {
      final userFriendlyMessage = ErrorHandler.getUserFriendlyMessage(e);
      _updateState(AuthenticationState.withError(userFriendlyMessage));
    }
  }

  /// Load user profile from API
  Future<void> _loadUserProfile() async {
    try {
      final userDataJson = await _apiService.getCurrentUser();
      final user = User.fromJson(userDataJson);

      _updateState(AuthenticationState.authenticated(user));
    } catch (e) {
      if (e is AuthenticationException) {
        // Tokens are invalid, clear them
        await _secureStorage.deleteTokens();
        _updateState(AuthenticationState.unauthenticated);
      } else {
        final userFriendlyMessage = ErrorHandler.getUserFriendlyMessage(e);
        _updateState(AuthenticationState.withError(userFriendlyMessage));
      }
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      _updateState(_state.copyWith(isLoading: true, clearError: true));

      final loginRequest = LoginRequest(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      // Validate request
      if (!loginRequest.isValid) {
        final errors = loginRequest.validate();
        _updateState(_state.copyWith(isLoading: false, error: errors.first));
        return false;
      }

      final authResponse = await _apiService.login(loginRequest);
      _updateState(AuthenticationState.authenticated(authResponse.user));

      _startTokenRefreshTimer();
      return true;
    } catch (e) {
      // Use ErrorHandler to translate technical errors to user-friendly messages
      final userFriendlyMessage = ErrorHandler.getUserFriendlyMessage(e);
      _updateState(
        _state.copyWith(isLoading: false, error: userFriendlyMessage),
      );
      return false;
    }
  }

  /// Register new user account
  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    String? username,
    String? garageName,
    String? phoneNumber,
    UserRole role = UserRole.mechanic,
    bool acceptTerms = false,
    bool acceptMarketing = false,
  }) async {
    try {
      _updateState(_state.copyWith(isLoading: true, clearError: true));

      final registerRequest = RegisterRequest(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        firstName: firstName,
        lastName: lastName,
        username: username,
        garageName: garageName,
        phoneNumber: phoneNumber,
        role: role,
        acceptTerms: acceptTerms,
        acceptMarketing: acceptMarketing,
      );

      // Validate request
      if (!registerRequest.isValid) {
        final errors = registerRequest.validate();
        _updateState(_state.copyWith(isLoading: false, error: errors.first));
        return false;
      }

      final authResponse = await _apiService.register(registerRequest);
      _updateState(AuthenticationState.authenticated(authResponse.user));

      _startTokenRefreshTimer();
      return true;
    } catch (e) {
      // Use ErrorHandler to translate technical errors to user-friendly messages
      final userFriendlyMessage = ErrorHandler.getUserFriendlyMessage(e);
      _updateState(
        _state.copyWith(isLoading: false, error: userFriendlyMessage),
      );
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      _updateState(_state.copyWith(isLoading: true, clearError: true));

      // Cancel token refresh timer
      _tokenRefreshTimer?.cancel();

      // Logout from API (fire and forget)
      _apiService.logout().catchError((_) {
        // Ignore logout API errors
      });

      // Always clear local state
      _updateState(AuthenticationState.unauthenticated);
    } catch (e) {
      // Even if logout fails, clear local state
      _updateState(AuthenticationState.unauthenticated);
    }
  }

  /// Request password reset
  Future<bool> requestPasswordReset(String email) async {
    try {
      _updateState(_state.copyWith(isLoading: true, clearError: true));

      if (!User.isValidEmail(email)) {
        _updateState(
          _state.copyWith(
            isLoading: false,
            error: 'Please enter a valid email address',
          ),
        );
        return false;
      }

      await _apiService.requestPasswordReset(email);

      _updateState(_state.copyWith(isLoading: false, error: null));
      return true;
    } catch (e) {
      // Use ErrorHandler to translate technical errors to user-friendly messages
      final userFriendlyMessage = ErrorHandler.getUserFriendlyMessage(e);
      _updateState(
        _state.copyWith(isLoading: false, error: userFriendlyMessage),
      );
      return false;
    }
  }

  /// Reset password with OTP code
  Future<bool> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      _updateState(_state.copyWith(isLoading: true, clearError: true));

      final authService = AuthService();
      final success = await authService.resetPassword(email, otp, newPassword);

      _updateState(_state.copyWith(isLoading: false, error: null));
      return success;
    } catch (e) {
      // Use ErrorHandler to translate technical errors to user-friendly messages
      final userFriendlyMessage = ErrorHandler.getUserFriendlyMessage(e);
      _updateState(
        _state.copyWith(isLoading: false, error: userFriendlyMessage),
      );
      return false;
    }
  }

  /// Refresh authentication tokens
  Future<bool> refreshTokens() async {
    try {
      final authResponse = await _apiService.refreshToken();
      _updateState(AuthenticationState.authenticated(authResponse.user));
      return true;
    } catch (e) {
      // Refresh failed, logout user
      await logout();
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      _updateState(_state.copyWith(isLoading: true, clearError: true));

      final updatedUserData = await _apiService.updateProfile(profileData);
      final updatedUser = User.fromJson(updatedUserData);

      _updateState(
        _state.copyWith(user: updatedUser, isLoading: false, clearError: true),
      );
      return true;
    } catch (e) {
      final userFriendlyMessage = ErrorHandler.getUserFriendlyMessage(e);
      _updateState(
        _state.copyWith(isLoading: false, error: userFriendlyMessage),
      );
      return false;
    }
  }

  /// Clear authentication error
  void clearError() {
    if (_state.hasError) {
      _updateState(_state.copyWith(clearError: true));
    }
  }

  /// Start automatic token refresh timer
  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();

    _tokenRefreshTimer = Timer.periodic(
      const Duration(minutes: 4), // Refresh every 4 minutes
      (_) => _checkTokenRefresh(),
    );
  }

  /// Check if tokens need refresh
  Future<void> _checkTokenRefresh() async {
    try {
      final expiresSoon = await _secureStorage.doTokensExpireSoon();

      if (expiresSoon && isAuthenticated) {
        await refreshTokens();
      }
    } catch (e) {
      // If token check fails, try to refresh anyway
      if (isAuthenticated) {
        await refreshTokens();
      }
    }
  }

  /// Update state and notify listeners
  void _updateState(AuthenticationState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  /// Get authentication status for debugging
  Map<String, dynamic> getDebugInfo() {
    return {
      'status': _state.status.name,
      'isAuthenticated': isAuthenticated,
      'isLoading': isLoading,
      'hasError': hasError,
      'error': error,
      'userEmail': currentUser?.email,
      'userRole': currentUser?.role.displayName,
      'subscriptionTier': currentUser?.subscriptionTier.displayName,
      'lastLoginAt': _state.lastLoginAt?.toIso8601String(),
    };
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    _apiService.dispose();
    super.dispose();
  }
}
