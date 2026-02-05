import '../auth/user.dart';

/// Login request model for authentication API
/// 
/// Contains credentials for user login with validation.
class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  final String email;
  final String password;
  final bool rememberMe;

  /// Validate login request data
  List<String> validate() {
    final errors = <String>[];

    if (email.isEmpty) {
      errors.add('Email is required');
    } else if (!User.isValidEmail(email)) {
      errors.add('Please enter a valid email address');
    }

    if (password.isEmpty) {
      errors.add('Password is required');
    }

    return errors;
  }

  /// Check if request is valid
  bool get isValid => validate().isEmpty;

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email.toLowerCase().trim(),
      'password': password,
      'rememberMe': rememberMe,
    };
  }

  /// Create LoginRequest from JSON
  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      rememberMe: json['rememberMe'] as bool? ?? false,
    );
  }

  /// Create copy with updated fields
  LoginRequest copyWith({
    String? email,
    String? password,
    bool? rememberMe,
  }) {
    return LoginRequest(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginRequest &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          password == other.password &&
          rememberMe == other.rememberMe;

  @override
  int get hashCode => Object.hash(email, password, rememberMe);

  @override
  String toString() {
    return 'LoginRequest(email: $email, rememberMe: $rememberMe)';
  }
}