import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../models/auth/auth_response.dart';
import '../models/auth/login_request.dart';
import '../models/auth/register_request.dart';
import '../models/auth/user.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';

/// Authentication service for German Car Medic application
///
/// Provides comprehensive authentication functionality including login, registration,
/// password management, and security features like device fingerprinting and login
/// attempt tracking.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  final SecureStorageService _secureStorage = SecureStorageService();

  // Cached user to avoid unnecessary API calls
  User? _cachedUser;

  // Login attempt tracking
  static const int _maxLoginAttempts = 5;
  static const Duration _loginLockoutDuration = Duration(minutes: 15);
  int _failedLoginAttempts = 0;
  DateTime? _lockoutUntil;
  bool _lockoutStateLoaded = false;

  /// Load persisted lockout state from secure storage
  Future<void> _loadLockoutState() async {
    if (_lockoutStateLoaded) return;
    _lockoutStateLoaded = true;
    try {
      final attemptsStr = await _secureStorage.getSecureData(
        'failed_login_attempts',
      );
      final lockoutStr = await _secureStorage.getSecureData('lockout_until');

      if (attemptsStr != null) {
        _failedLoginAttempts = int.tryParse(attemptsStr) ?? 0;
      }
      if (lockoutStr != null) {
        _lockoutUntil = DateTime.tryParse(lockoutStr);
        // Clear expired lockout
        if (_lockoutUntil != null && DateTime.now().isAfter(_lockoutUntil!)) {
          _lockoutUntil = null;
          _failedLoginAttempts = 0;
          await _persistLockoutState();
        }
      }
    } catch (e) {
      debugPrint('Failed to load lockout state: $e');
    }
  }

  /// Persist lockout state to secure storage
  Future<void> _persistLockoutState() async {
    try {
      await _secureStorage.storeSecureData(
        'failed_login_attempts',
        _failedLoginAttempts.toString(),
      );
      if (_lockoutUntil != null) {
        await _secureStorage.storeSecureData(
          'lockout_until',
          _lockoutUntil!.toIso8601String(),
        );
      } else {
        await _secureStorage.deleteSecureData('lockout_until');
      }
    } catch (e) {
      debugPrint('Failed to persist lockout state: $e');
    }
  }

  /// ==================== CORE AUTHENTICATION METHODS ====================

  /// Login with email and password
  ///
  /// Returns [AuthResponse] containing user data and authentication tokens.
  /// Throws [AuthException] on failure.
  Future<AuthResponse> login(String email, String password) async {
    // Load persisted lockout state before checking
    await _loadLockoutState();

    // Check if login is locked out
    if (_isLockedOut()) {
      final minutesRemaining = _lockoutUntil!
          .difference(DateTime.now())
          .inMinutes;
      throw AuthLockoutException(
        'Too many failed login attempts. Please try again in $minutesRemaining minutes.',
      );
    }

    try {
      // Get device fingerprint for security tracking
      final deviceInfo = await _getDeviceFingerprint();

      // Create login request
      final loginRequest = LoginRequest(email: email, password: password);

      // Attempt login through API service (device info sent in headers/body by API layer)
      final authResponse = await _apiService.login(loginRequest);

      // Reset failed attempts on successful login
      _failedLoginAttempts = 0;
      _lockoutUntil = null;
      await _persistLockoutState();

      // Cache user data
      _cachedUser = authResponse.user;

      // Store device fingerprint
      await _storeDeviceFingerprint(deviceInfo);

      return authResponse;
    } on AuthenticationException catch (e) {
      // Track failed login attempts
      _failedLoginAttempts++;

      // Implement progressive lockout
      if (_failedLoginAttempts >= _maxLoginAttempts) {
        _lockoutUntil = DateTime.now().add(_loginLockoutDuration);
        await _persistLockoutState();
        throw AuthLockoutException(
          'Too many failed login attempts. Account locked for ${_loginLockoutDuration.inMinutes} minutes.',
        );
      }

      // Re-throw with remaining attempts information
      final attemptsRemaining = _maxLoginAttempts - _failedLoginAttempts;
      await _persistLockoutState();
      throw AuthenticationException(
        '${e.message}\nAttempts remaining: $attemptsRemaining',
      );
    } catch (e) {
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  /// Register new user account
  ///
  /// Returns [AuthResponse] containing newly created user data and tokens.
  /// Throws [AuthException] on failure.
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      // Get device fingerprint for initial registration
      final deviceInfo = await _getDeviceFingerprint();

      // Register through API service (device info sent in headers by API layer)
      final authResponse = await _apiService.register(request);

      // Cache user data
      _cachedUser = authResponse.user;

      // Store device fingerprint
      await _storeDeviceFingerprint(deviceInfo);

      return authResponse;
    } on ValidationException catch (e) {
      throw AuthValidationException(e.message);
    } catch (e) {
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  /// Logout current user and clear all stored tokens
  ///
  /// Notifies backend to invalidate session and clears local storage.
  Future<void> logout() async {
    try {
      // Notify backend about logout
      await _apiService.logout();

      // Clear cached user
      _cachedUser = null;

      // Reset login attempt tracking
      _failedLoginAttempts = 0;
      _lockoutUntil = null;
    } catch (e) {
      // Even if API call fails, clear local data
      _cachedUser = null;
      throw AuthException('Logout failed: ${e.toString()}');
    }
  }

  /// Logout from all devices
  ///
  /// Invalidates all active sessions across all devices.
  Future<void> logoutFromAllDevices() async {
    try {
      // Call API endpoint to invalidate all sessions
      await _apiService.post('/auth/logout-all');

      // Clear local tokens and cached user
      await _secureStorage.deleteTokens();
      _cachedUser = null;

      // Reset login attempt tracking
      _failedLoginAttempts = 0;
      _lockoutUntil = null;
    } catch (e) {
      throw AuthException('Failed to logout from all devices: ${e.toString()}');
    }
  }

  /// Refresh access token using refresh token
  ///
  /// Returns true if token refresh was successful.
  /// Automatically called by API service on 401 errors.
  Future<bool> refreshToken() async {
    try {
      final authResponse = await _apiService.refreshToken();

      // Update cached user with potentially updated data
      _cachedUser = authResponse.user;

      return true;
    } on AuthenticationException catch (_) {
      // Refresh token expired or invalid - clear user data
      _cachedUser = null;
      await _secureStorage.deleteTokens();
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get current authenticated user
  ///
  /// Returns cached user if available, otherwise fetches from API.
  /// Returns null if user is not authenticated.
  Future<User?> getCurrentUser() async {
    // Return cached user if available
    if (_cachedUser != null) {
      return _cachedUser;
    }

    // Check if we have valid tokens
    final hasValidTokens = await _secureStorage.hasValidTokens();
    if (!hasValidTokens) {
      return null;
    }

    try {
      // Fetch user profile from API
      final response = await _apiService.getCurrentUser();
      final user = User.fromJson(response);

      // Cache the user
      _cachedUser = user;

      return user;
    } on AuthenticationException catch (_) {
      // Token is invalid - clear storage
      await _secureStorage.deleteTokens();
      return null;
    } catch (e) {
      // Network or other error - return null but don't clear tokens
      return null;
    }
  }

  /// Check if user is currently authenticated
  ///
  /// Performs quick check of token validity without API call.
  Future<bool> isAuthenticated() async {
    return await _secureStorage.hasValidTokens();
  }

  /// ==================== PASSWORD MANAGEMENT ====================

  /// Request password reset email
  ///
  /// Sends password reset email to the specified address.
  Future<void> forgotPassword(String email) async {
    try {
      await _apiService.requestPasswordReset(email);
    } on ValidationException catch (e) {
      throw AuthValidationException(e.message);
    } on RateLimitException catch (e) {
      throw AuthRateLimitException(e.message);
    } catch (e) {
      throw AuthException('Password reset request failed: ${e.toString()}');
    }
  }

  /// Reset password using OTP code
  ///
  /// Returns true if password was successfully reset.
  Future<bool> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    // Validate password before sending to API
    if (!User.isValidPassword(newPassword)) {
      throw AuthValidationException(
        'Password must be at least 8 characters with uppercase, lowercase, and number',
      );
    }

    try {
      final response = await _apiService.postPublic(
        '/auth/reset-password',
        body: {'email': email, 'otp': otp, 'newPassword': newPassword},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        // Parse error message from response
        try {
          final jsonResponse = jsonDecode(response.body);
          final errorMessage = jsonResponse['message'] ?? 
                              jsonResponse['error'] ?? 
                              'Password reset failed';
          
          // Check for specific password reuse error
          if (errorMessage.contains('Password has been used recently')) {
            throw AuthValidationException(
              'This password was used recently. Please choose a different password.',
            );
          }
          
          throw AuthException(errorMessage);
        } catch (e) {
          if (e is AuthValidationException || e is AuthException) {
            rethrow;
          }
          throw AuthException('Password reset failed: Invalid response');
        }
      }
    } catch (e) {
      // Re-throw our custom exceptions
      if (e is AuthValidationException || e is AuthException) {
        rethrow;
      }
      
      // Try to extract error from exception message
      final errorStr = e.toString();
      if (errorStr.contains('Password has been used recently')) {
        throw AuthValidationException(
          'This password was used recently. Please choose a different password.',
        );
      }
      
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  /// Change password for authenticated user
  ///
  /// Returns true if password was successfully changed.
  /// User must be authenticated.
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    // Validate new password
    if (!User.isValidPassword(newPassword)) {
      throw AuthValidationException(
        'Password must be at least 8 characters with uppercase, lowercase, and number',
      );
    }

    try {
      final response = await _apiService.put(
        '/auth/change-password',
        body: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthValidationException('Current password is incorrect');
      } else {
        return false;
      }
    } on AuthenticationException catch (_) {
      throw AuthValidationException('Current password is incorrect');
    } catch (e) {
      throw AuthException('Password change failed: ${e.toString()}');
    }
  }

  /// ==================== DEVICE FINGERPRINTING ====================

  /// Get device fingerprint for security tracking
  ///
  /// Returns map containing device identification information.
  Future<Map<String, String>> _getDeviceFingerprint() async {
    final deviceInfo = <String, String>{};

    try {
      // Platform information
      deviceInfo['platform'] = Platform.operatingSystem;
      deviceInfo['osVersion'] = Platform.operatingSystemVersion;

      // Device name (user-friendly)
      String deviceName = 'Unknown Device';
      if (Platform.isAndroid) {
        deviceName = 'Android ${Platform.operatingSystemVersion}';
      } else if (Platform.isIOS) {
        deviceName = 'iOS ${Platform.operatingSystemVersion}';
      } else if (Platform.isMacOS) {
        deviceName = 'macOS ${Platform.operatingSystemVersion}';
      } else if (Platform.isWindows) {
        deviceName = 'Windows ${Platform.operatingSystemVersion}';
      } else if (Platform.isLinux) {
        deviceName = 'Linux ${Platform.operatingSystemVersion}';
      }

      deviceInfo['deviceName'] = deviceName;

      // Generate unique device ID (stored in secure storage)
      String? deviceId = await _secureStorage.getSecureData('device_id');
      if (deviceId == null) {
        // Generate new device ID
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final randomData =
            '$timestamp-${Platform.operatingSystem}-${Platform.localHostname}';
        final bytes = utf8.encode(randomData);
        final digest = sha256.convert(bytes);
        deviceId = digest.toString();
      }

      deviceInfo['deviceId'] = deviceId;

      return deviceInfo;
    } catch (e) {
      // Return basic info if detailed fingerprinting fails
      return {
        'platform': 'unknown',
        'osVersion': 'unknown',
        'deviceName': 'Unknown Device',
        'deviceId': 'unknown',
      };
    }
  }

  /// Store device fingerprint in secure storage
  Future<void> _storeDeviceFingerprint(Map<String, String> deviceInfo) async {
    try {
      await _secureStorage.storeSecureData(
        'device_id',
        deviceInfo['deviceId']!,
      );
      await _secureStorage.storeSecureData(
        'device_name',
        deviceInfo['deviceName']!,
      );
      await _secureStorage.storeSecureData(
        'device_platform',
        deviceInfo['platform']!,
      );
    } catch (e) {
      // Non-critical error - log but don't throw
      debugPrint('Failed to store device fingerprint: $e');
    }
  }

  /// Get stored device fingerprint
  Future<Map<String, String?>> getDeviceFingerprint() async {
    return {
      'deviceId': await _secureStorage.getSecureData('device_id'),
      'deviceName': await _secureStorage.getSecureData('device_name'),
      'platform': await _secureStorage.getSecureData('device_platform'),
    };
  }

  /// ==================== LOGIN ATTEMPT TRACKING ====================

  /// Check if login is currently locked out
  bool _isLockedOut() {
    if (_lockoutUntil == null) return false;
    if (DateTime.now().isAfter(_lockoutUntil!)) {
      // Lockout period has expired
      _lockoutUntil = null;
      _failedLoginAttempts = 0;
      return false;
    }
    return true;
  }

  /// Get number of failed login attempts
  int get failedLoginAttempts => _failedLoginAttempts;

  /// Get lockout expiration time
  DateTime? get lockoutUntil => _lockoutUntil;

  /// Reset login attempt tracking
  ///
  /// Only exposed for testing purposes. Production code must not call this.
  @visibleForTesting
  Future<void> resetLoginAttempts() async {
    _failedLoginAttempts = 0;
    _lockoutUntil = null;
    await _persistLockoutState();
  }

  /// ==================== UTILITY METHODS ====================

  /// Clear cached user data
  void clearCache() {
    _cachedUser = null;
  }

  /// Get authentication status information
  Future<Map<String, dynamic>> getAuthStatus() async {
    final hasTokens = await _secureStorage.hasValidTokens();
    final tokenExpiry = await _secureStorage.getTokenExpiry();
    final userId = await _secureStorage.getUserId();
    final userEmail = await _secureStorage.getUserEmail();

    return {
      'isAuthenticated': hasTokens,
      'hasUser': _cachedUser != null,
      'userId': userId,
      'userEmail': userEmail,
      'tokenExpiry': tokenExpiry?.toIso8601String(),
      'minutesUntilExpiry': tokenExpiry?.difference(DateTime.now()).inMinutes,
      'failedLoginAttempts': _failedLoginAttempts,
      'isLockedOut': _isLockedOut(),
      'lockoutUntil': _lockoutUntil?.toIso8601String(),
    };
  }
}

/// ==================== CUSTOM EXCEPTIONS ====================

/// Base authentication exception
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

/// Authentication validation exception
class AuthValidationException extends AuthException {
  const AuthValidationException(super.message);

  @override
  String toString() => 'AuthValidationException: $message';
}

/// Authentication lockout exception
class AuthLockoutException extends AuthException {
  const AuthLockoutException(super.message);

  @override
  String toString() => 'AuthLockoutException: $message';
}

/// Authentication rate limit exception
class AuthRateLimitException extends AuthException {
  const AuthRateLimitException(super.message);

  @override
  String toString() => 'AuthRateLimitException: $message';
}
