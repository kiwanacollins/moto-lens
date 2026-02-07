import 'user.dart';

/// Authentication response model for login/register API endpoints
///
/// Contains user data, tokens, and session information returned
/// by the authentication API.
class AuthResponse {
  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.message,
  });

  final User user;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String? message;

  /// Check if access token is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Minutes until token expiration
  int get minutesUntilExpiry => expiresAt.difference(DateTime.now()).inMinutes;

  /// Check if token expires soon (within 5 minutes)
  bool get expiresSoon => minutesUntilExpiry <= 5 && minutesUntilExpiry > 0;

  /// Create AuthResponse from JSON
  ///
  /// Handles both flat and nested token formats:
  /// - Flat: { accessToken, refreshToken, ... }
  /// - Nested: { tokens: { accessToken, refreshToken }, ... }
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Extract tokens - backend nests them under 'tokens' key
    final tokens = json['tokens'] as Map<String, dynamic>?;
    final accessToken =
        (tokens?['accessToken'] ?? json['accessToken']) as String;
    final refreshToken =
        (tokens?['refreshToken'] ?? json['refreshToken']) as String;

    // Parse expiresAt if provided, otherwise default to 1 hour from now
    DateTime expiresAt;
    if (json['expiresAt'] != null) {
      expiresAt = DateTime.parse(json['expiresAt'] as String);
    } else {
      expiresAt = DateTime.now().add(const Duration(hours: 1));
    }

    return AuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      message: json['message'] as String?,
    );
  }

  /// Convert AuthResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      'message': message,
    };
  }

  /// Create copy with updated fields
  AuthResponse copyWith({
    User? user,
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? message,
  }) {
    return AuthResponse(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      message: message ?? this.message,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthResponse &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
          expiresAt == other.expiresAt &&
          message == other.message;

  @override
  int get hashCode =>
      Object.hash(user, accessToken, refreshToken, expiresAt, message);

  @override
  String toString() {
    return 'AuthResponse(user: ${user.email}, expiresAt: $expiresAt, message: $message)';
  }
}
