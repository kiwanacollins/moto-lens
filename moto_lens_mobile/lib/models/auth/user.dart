import 'user_role.dart';
import 'subscription_tier.dart';

/// Core user model for MotoLens application
///
/// Represents authenticated users with all essential profile data,
/// subscription status, and role-based permissions.
class User {
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.subscriptionTier,
    required this.emailVerified,
    required this.createdAt,
    required this.updatedAt,
    this.username,
    this.garageName,
    this.phoneNumber,
    this.profileImageUrl,
  });

  final String id;
  final String email;
  final String? username;
  final String firstName;
  final String lastName;
  final String? garageName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final UserRole role;
  final SubscriptionTier subscriptionTier;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Get user's full display name
  String get fullName => '$firstName $lastName';

  /// Get user's display name for UI (garage name or full name)
  String get displayName =>
      garageName?.isNotEmpty == true ? garageName! : fullName;

  /// Get user's initials for avatar fallback
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  /// Check if user profile is complete
  bool get isProfileComplete {
    return email.isNotEmpty &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        emailVerified;
  }

  /// Create User from JSON
  ///
  /// Handles partial user objects from login/register responses
  /// where some fields (createdAt, updatedAt, subscriptionTier) may be missing.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      garageName: json['garageName'] as String?,
      phoneNumber: json['phoneNumber'] as String? ?? json['phone'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      role: UserRole.fromString(json['role'] as String),
      subscriptionTier: json['subscriptionTier'] != null
          ? SubscriptionTier.fromString(json['subscriptionTier'] as String)
          : SubscriptionTier.free,
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'garageName': garageName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'role': role.value,
      'subscriptionTier': subscriptionTier.value,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create copy with updated fields
  User copyWith({
    String? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? garageName,
    String? phoneNumber,
    String? profileImageUrl,
    UserRole? role,
    SubscriptionTier? subscriptionTier,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      garageName: garageName ?? this.garageName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  /// Validate phone number format (optional field)
  static bool isValidPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return true;
    // Support international formats
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phoneNumber);
  }

  /// Validate name (first/last name)
  static bool isValidName(String name) {
    return name.trim().isNotEmpty && name.trim().length >= 2;
  }

  /// Validate garage name (optional field)
  static bool isValidGarageName(String? garageName) {
    if (garageName == null || garageName.isEmpty) return true;
    return garageName.trim().length >= 2;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          username == other.username &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          garageName == other.garageName &&
          phoneNumber == other.phoneNumber &&
          profileImageUrl == other.profileImageUrl &&
          role == other.role &&
          subscriptionTier == other.subscriptionTier &&
          emailVerified == other.emailVerified &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    email,
    username,
    firstName,
    lastName,
    garageName,
    phoneNumber,
    profileImageUrl,
    role,
    subscriptionTier,
    emailVerified,
    createdAt,
    updatedAt,
  );

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, role: ${role.displayName}, tier: ${subscriptionTier.displayName})';
  }
}
