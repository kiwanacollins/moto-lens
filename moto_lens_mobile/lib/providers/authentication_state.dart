import '../models/auth/user.dart';

/// Authentication state enumeration
/// 
/// Represents different states of the authentication process:
/// - initial: App starting up, checking stored tokens
/// - authenticated: User is logged in with valid tokens
/// - unauthenticated: User is not logged in or tokens expired
/// - loading: Authentication operation in progress
enum AuthenticationStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

/// Authentication state class for the authentication provider
/// 
/// Contains the current authentication status, user data, and any errors
/// that occurred during authentication operations.
class AuthenticationState {
  const AuthenticationState({
    this.status = AuthenticationStatus.initial,
    this.user,
    this.isLoading = false,
    this.error,
    this.lastLoginAt,
  });

  final AuthenticationStatus status;
  final User? user;
  final bool isLoading;
  final String? error;
  final DateTime? lastLoginAt;

  /// Check if user is authenticated
  bool get isAuthenticated => status == AuthenticationStatus.authenticated && user != null;

  /// Check if user is not authenticated
  bool get isUnauthenticated => status == AuthenticationStatus.unauthenticated;

  /// Check if authentication is in initial/loading state
  bool get isInitializing => status == AuthenticationStatus.initial;

  /// Check if any authentication operation is in progress
  bool get isAuthLoading => isLoading || status == AuthenticationStatus.loading;

  /// Check if there's an authentication error
  bool get hasError => error != null;

  /// Get user's display name safely
  String get displayName {
    if (user == null) return 'Guest';
    return user!.displayName;
  }

  /// Get user's email safely
  String get userEmail {
    if (user == null) return '';
    return user!.email;
  }

  /// Get user's subscription tier safely
  bool get hasUnlimitedAccess {
    if (user == null) return false;
    return user!.subscriptionTier.hasUnlimitedLookups;
  }

  /// Check if user is professional (mechanic or admin)
  bool get isProfessionalUser {
    if (user == null) return false;
    return user!.role.isProfessional;
  }

  /// Create initial state
  static const AuthenticationState initial = AuthenticationState();

  /// Create authenticated state
  static AuthenticationState authenticated(User user) {
    return AuthenticationState(
      status: AuthenticationStatus.authenticated,
      user: user,
      isLoading: false,
      error: null,
      lastLoginAt: DateTime.now(),
    );
  }

  /// Create unauthenticated state
  static const AuthenticationState unauthenticated = AuthenticationState(
    status: AuthenticationStatus.unauthenticated,
    user: null,
    isLoading: false,
    error: null,
  );

  /// Create loading state
  static AuthenticationState loading({String? currentError}) {
    return AuthenticationState(
      status: AuthenticationStatus.loading,
      isLoading: true,
      error: currentError,
    );
  }

  /// Create error state
  static AuthenticationState withError(String errorMessage, {AuthenticationStatus? status}) {
    return AuthenticationState(
      status: status ?? AuthenticationStatus.unauthenticated,
      isLoading: false,
      error: errorMessage,
    );
  }

  /// Create copy with updated fields
  AuthenticationState copyWith({
    AuthenticationStatus? status,
    User? user,
    bool? isLoading,
    String? error,
    DateTime? lastLoginAt,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthenticationState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthenticationState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          user == other.user &&
          isLoading == other.isLoading &&
          error == other.error &&
          lastLoginAt == other.lastLoginAt;

  @override
  int get hashCode => Object.hash(
    status,
    user,
    isLoading,
    error,
    lastLoginAt,
  );

  @override
  String toString() {
    return 'AuthenticationState{status: $status, user: ${user?.email}, isLoading: $isLoading, error: $error}';
  }
}