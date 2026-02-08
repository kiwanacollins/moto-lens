import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication_provider.dart';
import 'authentication_state.dart';
import '../models/auth/user.dart';

/// Extension on BuildContext for easy access to authentication
///
/// Provides convenient methods to access authentication state and
/// operations without having to call Provider.of manually.
extension AuthenticationContext on BuildContext {
  /// Get the authentication provider
  AuthenticationProvider get auth =>
      Provider.of<AuthenticationProvider>(this, listen: false);

  /// Watch authentication provider for changes
  AuthenticationProvider get authWatch =>
      Provider.of<AuthenticationProvider>(this, listen: true);

  /// Get current authentication state
  AuthenticationState get authState => authWatch.state;

  /// Authentication status getters
  bool get isAuthenticated => authWatch.isAuthenticated;
  bool get isUnauthenticated => authWatch.isUnauthenticated;
  bool get isAuthLoading => authWatch.isLoading;
  bool get hasAuthError => authWatch.hasError;

  /// Get current user (null if not authenticated)
  User? get currentUser => authWatch.currentUser;

  /// Get authentication error message (reactive - use in build method)
  String? get authError => authWatch.error;

  /// Get authentication error message (non-reactive - use in event handlers)
  String? get authErrorOnce => auth.error;

  /// Convenient user information getters (reactive - use in build method)
  String get userDisplayName => authState.displayName;
  String get userEmail => authState.userEmail;
  bool get hasUnlimitedAccess => authState.hasUnlimitedAccess;
  bool get isProfessionalUser => authState.isProfessionalUser;

  /// Non-reactive versions for use in event handlers
  User? get currentUserOnce => auth.currentUser;
  bool get isAuthenticatedOnce => auth.isAuthenticated;
  bool get isAuthLoadingOnce => auth.isLoading;

  /// Authentication operations

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) {
    return auth.login(email: email, password: password, rememberMe: rememberMe);
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    String? username,
    String? garageName,
    String? phoneNumber,
    bool acceptTerms = false,
    bool acceptMarketing = false,
  }) {
    return auth.register(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      firstName: firstName,
      lastName: lastName,
      username: username,
      garageName: garageName,
      phoneNumber: phoneNumber,
      acceptTerms: acceptTerms,
      acceptMarketing: acceptMarketing,
    );
  }

  /// Logout current user
  Future<void> logout() => auth.logout();

  /// Request password reset
  Future<bool> requestPasswordReset(String email) =>
      auth.requestPasswordReset(email);

  /// Reset password with OTP code
  Future<bool> resetPassword(String email, String otp, String newPassword) =>
      auth.resetPassword(email, otp, newPassword);

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> profileData) =>
      auth.updateProfile(profileData);

  /// Clear authentication error
  void clearAuthError() => auth.clearError();

  /// Refresh authentication tokens
  Future<bool> refreshTokens() => auth.refreshTokens();
}

/// Mixin for widgets that need authentication state
///
/// Provides common authentication-related functionality that can be
/// mixed into StatefulWidget State classes.
mixin AuthenticationMixin<T extends StatefulWidget> on State<T> {
  /// Get authentication provider without listening
  AuthenticationProvider get auth => context.auth;

  /// Get current authentication state
  AuthenticationState get authState => context.authState;

  /// Check if user is authenticated
  bool get isAuthenticated => context.isAuthenticated;

  /// Check if authentication is loading
  bool get isAuthLoading => context.isAuthLoading;

  /// Get current user
  User? get currentUser => context.currentUser;

  /// Show authentication error as snackbar
  void showAuthError([String? customMessage]) {
    final error = customMessage ?? context.authErrorOnce;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Show authentication success message
  void showAuthSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Navigate to login screen
  void navigateToLogin() {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  /// Navigate to home screen
  void navigateToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  /// Handle authentication state changes
  void handleAuthStateChange(AuthenticationState state) {
    // Clear previous errors
    context.clearAuthError();

    switch (state.status) {
      case AuthenticationStatus.authenticated:
        // User successfully authenticated, navigate to home
        if (mounted) {
          showAuthSuccess('Welcome ${state.user?.displayName ?? ''}!');
          navigateToHome();
        }
        break;
      case AuthenticationStatus.unauthenticated:
        // User logged out or authentication failed
        if (mounted && ModalRoute.of(context)?.settings.name != '/login') {
          navigateToLogin();
        }
        break;
      case AuthenticationStatus.initial:
      case AuthenticationStatus.loading:
        // Loading state, show progress indicator if needed
        break;
    }

    // Show errors
    if (state.hasError && mounted) {
      showAuthError();
    }
  }

  /// Listen to authentication state changes
  void initAuthListener() {
    auth.addListener(() {
      if (mounted) {
        handleAuthStateChange(authState);
      }
    });
  }
}
