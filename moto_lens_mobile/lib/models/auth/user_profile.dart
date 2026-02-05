import '../auth/user.dart';

/// Extended user profile model for detailed user information
///
/// Contains additional profile data, preferences, and usage statistics
/// that are loaded separately from the core User model.
class UserProfile {
  const UserProfile({
    required this.userId,
    required this.user,
    required this.vineSearchCount,
    required this.partsSearchCount,
    required this.lastLoginAt,
    this.bio,
    this.companyWebsite,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.timezone,
    this.language = 'en',
    this.currency = 'USD',
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.marketingEmails = false,
    this.darkMode = false,
    this.autoLogout = true,
  });

  final String userId;
  final User user;
  final String? bio;
  final String? companyWebsite;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final String? timezone;
  final String language;
  final String currency;
  final int vineSearchCount;
  final int partsSearchCount;
  final DateTime lastLoginAt;
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool marketingEmails;
  final bool darkMode;
  final bool autoLogout;

  /// Get formatted full address
  String get fullAddress {
    final parts = [
      address,
      city,
      state,
      zipCode,
      country,
    ].where((part) => part?.isNotEmpty == true).toList();
    return parts.join(', ');
  }

  /// Check if location is complete
  bool get hasCompleteLocation {
    return address?.isNotEmpty == true &&
        city?.isNotEmpty == true &&
        country?.isNotEmpty == true;
  }

  /// Check if profile is fully completed
  bool get isComplete {
    return user.isProfileComplete && hasCompleteLocation;
  }

  /// Get total searches performed
  int get totalSearches => vineSearchCount + partsSearchCount;

  /// Calculate searches remaining for free tier
  int get searchesRemainingToday {
    if (user.subscriptionTier.hasUnlimitedLookups) return -1;

    // In a real app, this would check today's usage from API
    // For now, assume vineSearchCount is daily count
    return (user.subscriptionTier.dailyLookupLimit - vineSearchCount).clamp(
      0,
      user.subscriptionTier.dailyLookupLimit,
    );
  }

  /// Check if user has reached daily limit
  bool get hasReachedDailyLimit {
    if (user.subscriptionTier.hasUnlimitedLookups) return false;
    return searchesRemainingToday == 0;
  }

  /// Create UserProfile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      bio: json['bio'] as String?,
      companyWebsite: json['companyWebsite'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
      country: json['country'] as String?,
      timezone: json['timezone'] as String?,
      language: json['language'] as String? ?? 'en',
      currency: json['currency'] as String? ?? 'USD',
      vineSearchCount: json['vineSearchCount'] as int? ?? 0,
      partsSearchCount: json['partsSearchCount'] as int? ?? 0,
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      marketingEmails: json['marketingEmails'] as bool? ?? false,
      darkMode: json['darkMode'] as bool? ?? false,
      autoLogout: json['autoLogout'] as bool? ?? true,
    );
  }

  /// Convert UserProfile to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'user': user.toJson(),
      'bio': bio,
      'companyWebsite': companyWebsite,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'timezone': timezone,
      'language': language,
      'currency': currency,
      'vineSearchCount': vineSearchCount,
      'partsSearchCount': partsSearchCount,
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'marketingEmails': marketingEmails,
      'darkMode': darkMode,
      'autoLogout': autoLogout,
    };
  }

  /// Create copy with updated fields
  UserProfile copyWith({
    String? userId,
    User? user,
    String? bio,
    String? companyWebsite,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? timezone,
    String? language,
    String? currency,
    int? vineSearchCount,
    int? partsSearchCount,
    DateTime? lastLoginAt,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? marketingEmails,
    bool? darkMode,
    bool? autoLogout,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      user: user ?? this.user,
      bio: bio ?? this.bio,
      companyWebsite: companyWebsite ?? this.companyWebsite,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      vineSearchCount: vineSearchCount ?? this.vineSearchCount,
      partsSearchCount: partsSearchCount ?? this.partsSearchCount,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      marketingEmails: marketingEmails ?? this.marketingEmails,
      darkMode: darkMode ?? this.darkMode,
      autoLogout: autoLogout ?? this.autoLogout,
    );
  }

  /// Validate website URL format
  static bool isValidWebsite(String? website) {
    if (website == null || website.isEmpty) return true;
    return RegExp(r'^https?:\/\/.+\..+').hasMatch(website);
  }

  /// Validate timezone string
  static bool isValidTimezone(String? timezone) {
    if (timezone == null || timezone.isEmpty) return true;
    // Basic timezone format validation
    return RegExp(r'^[A-Z][a-z]+\/[A-Z][a-z]+$').hasMatch(timezone);
  }

  /// Validate language code (ISO 639-1)
  static bool isValidLanguageCode(String language) {
    const validCodes = [
      'en',
      'de',
      'fr',
      'es',
      'it',
      'pt',
      'nl',
      'sv',
      'no',
      'da',
      'fi',
    ];
    return validCodes.contains(language.toLowerCase());
  }

  /// Validate currency code (ISO 4217)
  static bool isValidCurrencyCode(String currency) {
    const validCodes = [
      'USD',
      'EUR',
      'GBP',
      'CAD',
      'AUD',
      'JPY',
      'CHF',
      'NOK',
      'SEK',
      'DKK',
    ];
    return validCodes.contains(currency.toUpperCase());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          user == other.user &&
          bio == other.bio &&
          companyWebsite == other.companyWebsite &&
          address == other.address &&
          city == other.city &&
          state == other.state &&
          zipCode == other.zipCode &&
          country == other.country &&
          timezone == other.timezone &&
          language == other.language &&
          currency == other.currency &&
          vineSearchCount == other.vineSearchCount &&
          partsSearchCount == other.partsSearchCount &&
          lastLoginAt == other.lastLoginAt &&
          notificationsEnabled == other.notificationsEnabled &&
          emailNotifications == other.emailNotifications &&
          marketingEmails == other.marketingEmails &&
          darkMode == other.darkMode &&
          autoLogout == other.autoLogout;

  @override
  int get hashCode => Object.hashAll([
    userId,
    user,
    bio,
    companyWebsite,
    address,
    city,
    state,
    zipCode,
    country,
    timezone,
    language,
    currency,
    vineSearchCount,
    partsSearchCount,
    lastLoginAt,
    notificationsEnabled,
    emailNotifications,
    marketingEmails,
    darkMode,
    autoLogout,
  ]);

  @override
  String toString() {
    return 'UserProfile(userId: $userId, searches: $totalSearches, complete: $isComplete, lastLogin: $lastLoginAt)';
  }
}
