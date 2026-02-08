import '../auth/user.dart';
import '../auth/user_role.dart';

/// Registration request model for user signup API
///
/// Contains all required data for creating a new user account
/// with comprehensive validation.
class RegisterRequest {
  const RegisterRequest({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.firstName,
    required this.lastName,
    this.username,
    this.garageName,
    this.phoneNumber,
    this.role = UserRole.mechanic, // Default role
    this.acceptTerms = false,
    this.acceptMarketing = false,
  });

  final String email;
  final String password;
  final String confirmPassword;
  final String firstName;
  final String lastName;
  final String? username;
  final String? garageName;
  final String? phoneNumber;
  final UserRole role;
  final bool acceptTerms;
  final bool acceptMarketing;

  /// Validate registration request data
  List<String> validate() {
    final errors = <String>[];

    // Email validation
    if (email.isEmpty) {
      errors.add('Email is required');
    } else if (!User.isValidEmail(email)) {
      errors.add('Please enter a valid email address');
    }

    // Password validation
    if (password.isEmpty) {
      errors.add('Password is required');
    } else if (!User.isValidPassword(password)) {
      errors.add(
        'Password must be at least 8 characters with uppercase, lowercase, and number',
      );
    }

    // Confirm password validation
    if (confirmPassword.isEmpty) {
      errors.add('Please confirm your password');
    } else if (password != confirmPassword) {
      errors.add('Passwords do not match');
    }

    // Name validation
    if (!User.isValidName(firstName)) {
      errors.add('First name must be at least 2 characters');
    }

    if (!User.isValidName(lastName)) {
      errors.add('Last name must be at least 2 characters');
    }

    // Optional fields validation
    if (!User.isValidGarageName(garageName)) {
      errors.add('Garage name must be at least 2 characters');
    }

    if (!User.isValidPhoneNumber(phoneNumber)) {
      errors.add('Please enter a valid phone number');
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
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'username': username?.trim(),
      'garageName': garageName?.trim(),
      'phoneNumber': phoneNumber?.trim(),
      'role': role.value,
      'acceptTerms': acceptTerms,
      'acceptMarketing': acceptMarketing,
    };
  }

  /// Create RegisterRequest from JSON
  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      confirmPassword: json['confirmPassword'] as String? ?? '',
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      username: json['username'] as String?,
      garageName: json['garageName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'mechanic'),
      acceptTerms: json['acceptTerms'] as bool? ?? false,
      acceptMarketing: json['acceptMarketing'] as bool? ?? false,
    );
  }

  /// Create copy with updated fields
  RegisterRequest copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    String? firstName,
    String? lastName,
    String? username,
    String? garageName,
    String? phoneNumber,
    UserRole? role,
    bool? acceptTerms,
    bool? acceptMarketing,
  }) {
    return RegisterRequest(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      garageName: garageName ?? this.garageName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      acceptTerms: acceptTerms ?? this.acceptTerms,
      acceptMarketing: acceptMarketing ?? this.acceptMarketing,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterRequest &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          password == other.password &&
          confirmPassword == other.confirmPassword &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          username == other.username &&
          garageName == other.garageName &&
          phoneNumber == other.phoneNumber &&
          role == other.role &&
          acceptTerms == other.acceptTerms &&
          acceptMarketing == other.acceptMarketing;

  @override
  int get hashCode => Object.hash(
    email,
    password,
    confirmPassword,
    firstName,
    lastName,
    username,
    garageName,
    phoneNumber,
    role,
    acceptTerms,
    acceptMarketing,
  );

  @override
  String toString() {
    return 'RegisterRequest(email: $email, firstName: $firstName, lastName: $lastName, role: ${role.displayName})';
  }
}
