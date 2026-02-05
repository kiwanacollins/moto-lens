import 'package:flutter_test/flutter_test.dart';
import 'package:moto_lens_mobile/services/secure_storage_service.dart';
import 'package:moto_lens_mobile/models/auth/auth_response.dart';
import 'package:moto_lens_mobile/models/auth/user.dart';
import 'package:moto_lens_mobile/models/auth/user_role.dart';
import 'package:moto_lens_mobile/models/auth/subscription_tier.dart';

void main() {
  group('SecureStorageService Tests', () {
    late SecureStorageService secureStorage;

    setUp(() {
      secureStorage = SecureStorageService();
    });

    tearDown(() async {
      // Clean up after each test
      try {
        await secureStorage.deleteAllData();
      } catch (e) {
        // Ignore cleanup errors in tests
      }
    });

    group('Token Storage Tests', () {
      test('should save and retrieve auth tokens', () async {
        // Create test data
        final user = User(
          id: 'test_user_123',
          email: 'test@motolens.com',
          firstName: 'John',
          lastName: 'Doe',
          role: UserRole.mechanic,
          subscriptionTier: SubscriptionTier.professional,
          emailVerified: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final authResponse = AuthResponse(
          user: user,
          accessToken: 'test_access_token_123',
          refreshToken: 'test_refresh_token_456',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          message: 'Login successful',
        );

        // Save tokens
        await secureStorage.saveAuthTokens(authResponse);

        // Retrieve tokens
        final accessToken = await secureStorage.getAccessToken();
        final refreshToken = await secureStorage.getRefreshToken();
        final userId = await secureStorage.getUserId();
        final userEmail = await secureStorage.getUserEmail();

        expect(accessToken, equals('test_access_token_123'));
        expect(refreshToken, equals('test_refresh_token_456'));
        expect(userId, equals('test_user_123'));
        expect(userEmail, equals('test@motolens.com'));
      });

      test('should save and retrieve individual tokens', () async {
        final expiryTime = DateTime.now().add(const Duration(hours: 2));

        await secureStorage.saveTokens(
          accessToken: 'individual_access_token',
          refreshToken: 'individual_refresh_token',
          expiresAt: expiryTime,
        );

        final accessToken = await secureStorage.getAccessToken();
        final refreshToken = await secureStorage.getRefreshToken();
        final expiry = await secureStorage.getTokenExpiry();

        expect(accessToken, equals('individual_access_token'));
        expect(refreshToken, equals('individual_refresh_token'));
        expect(expiry, isNotNull);
        expect(expiry!.difference(expiryTime).inSeconds, lessThan(2));
      });

      test('should handle null tokens gracefully', () async {
        final accessToken = await secureStorage.getAccessToken();
        final refreshToken = await secureStorage.getRefreshToken();
        final hasValidTokens = await secureStorage.hasValidTokens();

        expect(accessToken, isNull);
        expect(refreshToken, isNull);
        expect(hasValidTokens, isFalse);
      });
    });

    group('Token Validation Tests', () {
      test('should correctly identify expired tokens', () async {
        final expiredTime = DateTime.now().subtract(const Duration(hours: 1));

        await secureStorage.saveTokens(
          accessToken: 'expired_token',
          refreshToken: 'expired_refresh',
          expiresAt: expiredTime,
        );

        final areExpired = await secureStorage.areTokensExpired();
        final hasValidTokens = await secureStorage.hasValidTokens();

        expect(areExpired, isTrue);
        expect(hasValidTokens, isFalse);
      });

      test('should correctly identify tokens expiring soon', () async {
        final expiringSoonTime = DateTime.now().add(const Duration(minutes: 3));

        await secureStorage.saveTokens(
          accessToken: 'expiring_soon_token',
          refreshToken: 'expiring_soon_refresh',
          expiresAt: expiringSoonTime,
        );

        final expireSoon = await secureStorage.doTokensExpireSoon();
        final hasValidTokens = await secureStorage.hasValidTokens();

        expect(expireSoon, isTrue);
        expect(
          hasValidTokens,
          isFalse,
        ); // Should be false due to 5-minute buffer
      });

      test('should correctly calculate minutes until expiry', () async {
        final expiryTime = DateTime.now().add(const Duration(minutes: 30));

        await secureStorage.saveTokens(
          accessToken: 'future_token',
          refreshToken: 'future_refresh',
          expiresAt: expiryTime,
        );

        final minutesUntilExpiry = await secureStorage.getMinutesUntilExpiry();

        expect(minutesUntilExpiry, greaterThan(25));
        expect(minutesUntilExpiry, lessThan(35));
      });

      test('should return zero minutes for expired tokens', () async {
        final expiredTime = DateTime.now().subtract(const Duration(hours: 1));

        await secureStorage.saveTokens(
          accessToken: 'past_token',
          refreshToken: 'past_refresh',
          expiresAt: expiredTime,
        );

        final minutesUntilExpiry = await secureStorage.getMinutesUntilExpiry();

        expect(minutesUntilExpiry, equals(0));
      });
    });

    group('Token Deletion Tests', () {
      test('should delete tokens correctly', () async {
        // First save some tokens
        final user = User(
          id: 'delete_test_user',
          email: 'delete@motolens.com',
          firstName: 'Jane',
          lastName: 'Smith',
          role: UserRole.customer,
          subscriptionTier: SubscriptionTier.free,
          emailVerified: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final authResponse = AuthResponse(
          user: user,
          accessToken: 'delete_me_token',
          refreshToken: 'delete_me_refresh',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        await secureStorage.saveAuthTokens(authResponse);

        // Verify tokens exist
        final tokensBefore = await secureStorage.hasValidTokens();
        expect(tokensBefore, isTrue);

        // Delete tokens
        await secureStorage.deleteTokens();

        // Verify tokens are gone
        final tokensAfter = await secureStorage.hasValidTokens();
        final accessToken = await secureStorage.getAccessToken();
        final refreshToken = await secureStorage.getRefreshToken();

        expect(tokensAfter, isFalse);
        expect(accessToken, isNull);
        expect(refreshToken, isNull);
      });
    });

    group('Biometric Settings Tests', () {
      test('should save and retrieve biometric preference', () async {
        // Test enabling biometric
        await secureStorage.setBiometricEnabled(true);
        final enabledResult = await secureStorage.isBiometricEnabled();
        expect(enabledResult, isTrue);

        // Test disabling biometric
        await secureStorage.setBiometricEnabled(false);
        final disabledResult = await secureStorage.isBiometricEnabled();
        expect(disabledResult, isFalse);
      });

      test('should return false for biometric when not set', () async {
        final result = await secureStorage.isBiometricEnabled();
        expect(result, isFalse);
      });
    });

    group('Custom Data Storage Tests', () {
      test('should store and retrieve custom secure data', () async {
        const key = 'test_custom_key';
        const value = 'test_custom_value';

        await secureStorage.storeSecureData(key, value);
        final retrievedValue = await secureStorage.getSecureData(key);

        expect(retrievedValue, equals(value));
      });

      test('should delete custom secure data', () async {
        const key = 'delete_test_key';
        const value = 'delete_test_value';

        await secureStorage.storeSecureData(key, value);
        await secureStorage.deleteSecureData(key);
        final retrievedValue = await secureStorage.getSecureData(key);

        expect(retrievedValue, isNull);
      });
    });

    group('Data Export Tests', () {
      test('should export non-sensitive data correctly', () async {
        // Save test data
        final user = User(
          id: 'export_test_user',
          email: 'export@motolens.com',
          firstName: 'Export',
          lastName: 'User',
          role: UserRole.admin,
          subscriptionTier: SubscriptionTier.enterprise,
          emailVerified: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final authResponse = AuthResponse(
          user: user,
          accessToken: 'export_access_token',
          refreshToken: 'export_refresh_token',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        await secureStorage.saveAuthTokens(authResponse);
        await secureStorage.setBiometricEnabled(true);

        // Export data
        final exportedData = await secureStorage.exportNonSensitiveData();

        expect(exportedData['userId'], equals('export_test_user'));
        expect(exportedData['userEmail'], equals('export@motolens.com'));
        expect(exportedData['biometricEnabled'], equals('true'));
        expect(exportedData['hasTokens'], equals('true'));
        expect(exportedData['tokenExpiry'], isNotNull);

        // Ensure sensitive data is not included
        expect(exportedData.keys, isNot(contains('accessToken')));
        expect(exportedData.keys, isNot(contains('refreshToken')));
      });
    });

    group('Platform Information Tests', () {
      test('should return platform storage information', () async {
        final storageInfo = secureStorage.getStorageInfo();

        expect(storageInfo, containsPair('platform', isNotNull));
        expect(storageInfo, containsPair('storageType', isNotNull));
        expect(storageInfo, containsPair('encryptionEnabled', isA<bool>()));
        expect(storageInfo, containsPair('isAndroid', isA<bool>()));
        expect(storageInfo, containsPair('isIOS', isA<bool>()));
        expect(storageInfo, containsPair('isWeb', isA<bool>()));
      });
    });

    group('Error Handling Tests', () {
      test('should handle storage errors gracefully', () async {
        // These tests would depend on mocking flutter_secure_storage
        // For now, we'll test that the service doesn't crash
        expect(() => secureStorage.isSecureStorageAvailable(), returnsNormally);
        expect(() => secureStorage.getAllKeys(), returnsNormally);
      });
    });
  });
}
