/// User role enumeration for MotoLens application
///
/// Defines the different roles a user can have in the system:
/// - mechanic: Professional mechanics (primary target users)
/// - admin: System administrators with full access
/// - customer: End customers who need vehicle information
enum UserRole {
  mechanic('mechanic'),
  admin('admin'),
  customer('customer');

  const UserRole(this.value);

  final String value;

  /// Create UserRole from string value
  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'mechanic':
        return UserRole.mechanic;
      case 'admin':
        return UserRole.admin;
      case 'customer':
        return UserRole.customer;
      default:
        throw ArgumentError('Invalid user role: $value');
    }
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case UserRole.mechanic:
        return 'Mechanic';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.customer:
        return 'Customer';
    }
  }

  /// Check if role has administrative privileges
  bool get isAdmin => this == UserRole.admin;

  /// Check if role is professional mechanic
  bool get isProfessional =>
      this == UserRole.mechanic || this == UserRole.admin;
}
