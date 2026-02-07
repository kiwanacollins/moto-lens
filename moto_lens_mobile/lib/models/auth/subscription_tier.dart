/// Subscription tier enumeration for German Car Medic application
///
/// Defines subscription levels with different feature access:
/// - free: Basic VIN decoding (limited lookups per day)
/// - professional: Unlimited lookups + parts database access
/// - enterprise: Full API access + bulk operations + analytics
enum SubscriptionTier {
  free('free'),
  professional('professional'),
  enterprise('enterprise');

  const SubscriptionTier(this.value);

  final String value;

  /// Create SubscriptionTier from string value
  ///
  /// Handles backend enum values (FREE, BASIC, PRO, ENTERPRISE)
  /// and mobile-side names.
  static SubscriptionTier fromString(String value) {
    switch (value.toLowerCase()) {
      case 'free':
        return SubscriptionTier.free;
      case 'basic':
      case 'pro':
      case 'professional':
        return SubscriptionTier.professional;
      case 'enterprise':
        return SubscriptionTier.enterprise;
      default:
        return SubscriptionTier.free; // Default to free for unknown tiers
    }
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.professional:
        return 'Professional';
      case SubscriptionTier.enterprise:
        return 'Enterprise';
    }
  }

  /// Get monthly price in USD
  double get monthlyPrice {
    switch (this) {
      case SubscriptionTier.free:
        return 0.0;
      case SubscriptionTier.professional:
        return 29.99;
      case SubscriptionTier.enterprise:
        return 99.99;
    }
  }

  /// Get daily lookup limit
  int get dailyLookupLimit {
    switch (this) {
      case SubscriptionTier.free:
        return 5;
      case SubscriptionTier.professional:
        return -1; // unlimited
      case SubscriptionTier.enterprise:
        return -1; // unlimited
    }
  }

  /// Check if tier has unlimited lookups
  bool get hasUnlimitedLookups => dailyLookupLimit == -1;

  /// Check if tier has parts database access
  bool get hasPartsAccess {
    return this == SubscriptionTier.professional ||
        this == SubscriptionTier.enterprise;
  }

  /// Check if tier has API access
  bool get hasApiAccess => this == SubscriptionTier.enterprise;

  /// Check if tier has analytics access
  bool get hasAnalytics => this == SubscriptionTier.enterprise;
}
