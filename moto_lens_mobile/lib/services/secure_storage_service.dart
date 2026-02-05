import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth/auth_response.dart';

/// Secure storage service for managing JWT tokens and sensitive user data
///
/// Provides encrypted storage for authentication tokens using platform-specific
/// secure storage mechanisms (Android Keystore, iOS Keychain).
class SecureStorageService {
  static const String _accessTokenKey = 'moto_lens_access_token';
  static const String _refreshTokenKey = 'moto_lens_refresh_token';
  static const String _tokenExpiryKey = 'moto_lens_token_expiry';
  static const String _userIdKey = 'moto_lens_user_id';
  static const String _userEmailKey = 'moto_lens_user_email';
  static const String _biometricEnabledKey = 'moto_lens_biometric_enabled';

  /// Platform-specific secure storage configuration
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
    keyCipherAlgorithm:
        KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
    storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
  );

  static const IOSOptions _iosOptions = IOSOptions(
    groupId: 'group.com.motolens.app',
    accountName: 'MotoLens',
    accessibility: KeychainAccessibility.first_unlock_this_device,
    synchronizable: false,
  );

  static const LinuxOptions _linuxOptions = LinuxOptions();

  static const WindowsOptions _windowsOptions = WindowsOptions(
    useBackwardCompatibility: false,
  );

  static const WebOptions _webOptions = WebOptions(
    dbName: 'MotoLensSecureStorage',
    publicKey: 'MotoLensPublicKey',
  );

  static final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: _androidOptions,
    iOptions: _iosOptions,
    lOptions: _linuxOptions,
    wOptions: _windowsOptions,
    webOptions: _webOptions,
  );

  /// Save authentication tokens from AuthResponse
  Future<void> saveAuthTokens(AuthResponse authResponse) async {
    try {
      await Future.wait([
        _storage.write(key: _accessTokenKey, value: authResponse.accessToken),
        _storage.write(key: _refreshTokenKey, value: authResponse.refreshToken),
        _storage.write(
          key: _tokenExpiryKey,
          value: authResponse.expiresAt.toIso8601String(),
        ),
        _storage.write(key: _userIdKey, value: authResponse.user.id),
        _storage.write(key: _userEmailKey, value: authResponse.user.email),
      ]);
    } catch (e) {
      throw SecureStorageException('Failed to save authentication tokens: $e');
    }
  }

  /// Save individual tokens (for refresh scenarios)
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _accessTokenKey, value: accessToken),
        _storage.write(key: _refreshTokenKey, value: refreshToken),
        _storage.write(
          key: _tokenExpiryKey,
          value: expiresAt.toIso8601String(),
        ),
      ]);
    } catch (e) {
      throw SecureStorageException('Failed to save tokens: $e');
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      throw SecureStorageException('Failed to retrieve access token: $e');
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      throw SecureStorageException('Failed to retrieve refresh token: $e');
    }
  }

  /// Get token expiry date
  Future<DateTime?> getTokenExpiry() async {
    try {
      final expiryString = await _storage.read(key: _tokenExpiryKey);
      if (expiryString == null) return null;
      return DateTime.parse(expiryString);
    } catch (e) {
      throw SecureStorageException('Failed to retrieve token expiry: $e');
    }
  }

  /// Get stored user ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      throw SecureStorageException('Failed to retrieve user ID: $e');
    }
  }

  /// Get stored user email
  Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _userEmailKey);
    } catch (e) {
      throw SecureStorageException('Failed to retrieve user email: $e');
    }
  }

  /// Check if valid tokens are stored
  Future<bool> hasValidTokens() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      final expiry = await getTokenExpiry();

      if (accessToken == null || refreshToken == null || expiry == null) {
        return false;
      }

      // Check if token is not expired (with 5-minute buffer)
      final now = DateTime.now();
      final bufferTime = now.add(const Duration(minutes: 5));

      return expiry.isAfter(bufferTime);
    } catch (e) {
      return false;
    }
  }

  /// Check if tokens are expired or about to expire
  Future<bool> areTokensExpired() async {
    try {
      final expiry = await getTokenExpiry();
      if (expiry == null) return true;

      final now = DateTime.now();
      return expiry.isBefore(now);
    } catch (e) {
      return true;
    }
  }

  /// Check if tokens expire soon (within 5 minutes)
  Future<bool> doTokensExpireSoon() async {
    try {
      final expiry = await getTokenExpiry();
      if (expiry == null) return true;

      final now = DateTime.now();
      final bufferTime = now.add(const Duration(minutes: 5));

      return expiry.isBefore(bufferTime) && expiry.isAfter(now);
    } catch (e) {
      return true;
    }
  }

  /// Get time until token expiry in minutes
  Future<int> getMinutesUntilExpiry() async {
    try {
      final expiry = await getTokenExpiry();
      if (expiry == null) return 0;

      final now = DateTime.now();
      final difference = expiry.difference(now);

      return difference.inMinutes.clamp(0, double.infinity).toInt();
    } catch (e) {
      return 0;
    }
  }

  /// Delete tokens (logout)
  Future<void> deleteTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _tokenExpiryKey),
        _storage.delete(key: _userIdKey),
        _storage.delete(key: _userEmailKey),
      ]);
    } catch (e) {
      throw SecureStorageException('Failed to delete tokens: $e');
    }
  }

  /// Delete all stored data (complete logout)
  Future<void> deleteAllData() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw SecureStorageException('Failed to delete all data: $e');
    }
  }

  /// Save biometric authentication preference
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(
        key: _biometricEnabledKey,
        value: enabled.toString(),
      );
    } catch (e) {
      throw SecureStorageException('Failed to save biometric preference: $e');
    }
  }

  /// Get biometric authentication preference
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _storage.read(key: _biometricEnabledKey);
      return value?.toLowerCase() == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Store custom secure data
  Future<void> storeSecureData(String key, String value) async {
    try {
      await _storage.write(key: 'moto_lens_$key', value: value);
    } catch (e) {
      throw SecureStorageException('Failed to store secure data: $e');
    }
  }

  /// Retrieve custom secure data
  Future<String?> getSecureData(String key) async {
    try {
      return await _storage.read(key: 'moto_lens_$key');
    } catch (e) {
      throw SecureStorageException('Failed to retrieve secure data: $e');
    }
  }

  /// Delete custom secure data
  Future<void> deleteSecureData(String key) async {
    try {
      await _storage.delete(key: 'moto_lens_$key');
    } catch (e) {
      throw SecureStorageException('Failed to delete secure data: $e');
    }
  }

  /// Check if secure storage is available on the current platform
  Future<bool> isSecureStorageAvailable() async {
    try {
      // Test by writing and reading a temporary value
      const testKey = 'moto_lens_test_key';
      const testValue = 'test';

      await _storage.write(key: testKey, value: testValue);
      final result = await _storage.read(key: testKey);
      await _storage.delete(key: testKey);

      return result == testValue;
    } catch (e) {
      return false;
    }
  }

  /// Get all stored keys (for debugging purposes)
  Future<List<String>> getAllKeys() async {
    try {
      final allData = await _storage.readAll();
      return allData.keys.where((key) => key.startsWith('moto_lens_')).toList();
    } catch (e) {
      throw SecureStorageException('Failed to retrieve all keys: $e');
    }
  }

  /// Export user data for migration or backup (sensitive data excluded)
  Future<Map<String, String?>> exportNonSensitiveData() async {
    try {
      return {
        'userId': await getUserId(),
        'userEmail': await getUserEmail(),
        'biometricEnabled': (await isBiometricEnabled()).toString(),
        'hasTokens': (await hasValidTokens()).toString(),
        'tokenExpiry': (await getTokenExpiry())?.toIso8601String(),
      };
    } catch (e) {
      throw SecureStorageException('Failed to export data: $e');
    }
  }

  /// Platform-specific storage information
  Map<String, dynamic> getStorageInfo() {
    return {
      'platform': Platform.operatingSystem,
      'isAndroid': Platform.isAndroid,
      'isIOS': Platform.isIOS,
      'isWeb': kIsWeb,
      'storageType': Platform.isAndroid
          ? 'Android Keystore'
          : Platform.isIOS
              ? 'iOS Keychain'
              : kIsWeb
                  ? 'Web IndexedDB'
                  : 'Platform Keystore',
      'encryptionEnabled': Platform.isAndroid || Platform.isLinux,
    };
  }
}

/// Custom exception for secure storage errors
class SecureStorageException implements Exception {
  final String message;

  const SecureStorageException(this.message);

  @override
  String toString() => 'SecureStorageException: $message';
}
