import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'secure_storage_service.dart';

/// Biometric authentication service for German Car Medic
///
/// Provides fingerprint/face authentication as a convenience login layer.
/// Tokens are stored behind biometric-gated secure storage after the user
/// opts in following a successful email/password login.
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final SecureStorageService _storageService = SecureStorageService();

  /// Check if the device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  /// Check if biometrics are enrolled on the device (fingerprint registered, etc.)
  Future<bool> hasBiometricsEnrolled() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;

      final available = await _localAuth.getAvailableBiometrics();
      return available.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  /// Check if biometric login is fully available:
  /// device supports it, biometrics enrolled, AND user has opted in
  Future<bool> isBiometricLoginAvailable() async {
    try {
      final deviceSupported = await isDeviceSupported();
      if (!deviceSupported) return false;

      final enrolled = await hasBiometricsEnrolled();
      if (!enrolled) return false;

      final enabled = await _storageService.isBiometricEnabled();
      return enabled;
    } catch (_) {
      return false;
    }
  }

  /// Check if the device can support biometric (for showing opt-in prompt)
  /// Does NOT check if user has opted in
  Future<bool> canOfferBiometric() async {
    try {
      final deviceSupported = await isDeviceSupported();
      if (!deviceSupported) return false;

      return await hasBiometricsEnrolled();
    } catch (_) {
      return false;
    }
  }

  /// Prompt the user for biometric authentication
  ///
  /// Returns true if authentication succeeded, false otherwise.
  Future<bool> authenticate({
    String reason = 'Verify your identity to sign in',
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Biometric Authentication',
            cancelButton: 'Cancel',
          ),
        ],
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      // Handle specific platform exceptions
      if (e.code == 'NotAvailable' || e.code == 'NotEnrolled') {
        throw Exception(
          'Biometric authentication not available on this device',
        );
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Enable biometric login after a successful email/password login.
  /// Stores the preference flag so the app knows to offer biometric next time.
  Future<void> enableBiometric() async {
    await _storageService.setBiometricEnabled(true);
  }

  /// Disable biometric login (user opts out or logs out)
  Future<void> disableBiometric() async {
    await _storageService.setBiometricEnabled(false);
  }

  /// Check if biometric is currently enabled (preference only)
  Future<bool> isBiometricEnabled() async {
    return await _storageService.isBiometricEnabled();
  }

  /// Get the types of biometrics available on this device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Get a human-readable label for the primary biometric type
  Future<String> getBiometricLabel() async {
    final types = await getAvailableBiometrics();

    if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (types.contains(BiometricType.strong)) {
      return 'Biometric';
    }
    return 'Biometric';
  }
}
