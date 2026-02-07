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
  ///
  /// Handles backend enum values (MECHANIC, SHOP_OWNER, ADMIN, SUPPORT)
  /// and lowercase variants.
  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'mechanic':
        return UserRole.mechanic;
      case 'admin':
        return UserRole.admin;
      case 'customer':
        return UserRole.customer;
      case 'shop_owner':
        return UserRole.mechanic; // Map shop owners to mechanic role in mobile
      case 'support':
        return UserRole.admin; // Map support to admin role in mobile
      default:
        return UserRole.mechanic; // Default to mechanic for unknown roles
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
