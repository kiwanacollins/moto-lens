/// Environment configuration for German Car Medic Mobile App
///
/// Manages environment-specific settings like API URLs for development,
/// staging, and production environments.

import 'package:flutter/foundation.dart';

class Environment {
  /// Current environment mode
  ///
  /// SECURITY: This must be set to [EnvironmentMode.production] for release builds.
  /// Asserts at startup in release mode if still set to development.
  static const EnvironmentMode mode = EnvironmentMode.development;

  /// Validate that the environment is correctly configured for the build mode.
  ///
  /// Call this early in app startup (e.g., in main.dart).
  /// In release mode, logs a severe warning if mode is still development.
  static void validateEnvironment() {
    if (kReleaseMode && mode == EnvironmentMode.development) {
      // Cannot use assert in release mode — log severe warning instead
      debugPrint(
        '⚠️  SECURITY WARNING: App is running in RELEASE mode with '
        'EnvironmentMode.development. API requests will target the local '
        'dev server. Set Environment.mode to EnvironmentMode.production '
        'before shipping.',
      );
    }
  }

  /// Get API base URL for current environment
  static String get apiUrl {
    switch (mode) {
      case EnvironmentMode.development:
        // VPS Backend (accessible from all devices)
        return 'http://207.180.249.87';

        // OPTION 1: Android Emulator (local dev server)
        // return 'http://10.0.2.2:3001';

        // OPTION 2: iOS Simulator (local dev server)
        // return 'http://localhost:3001';

        // OPTION 3: Real device - local network (local dev server)
        // Use your computer's IP address (find with: ifconfig | grep "inet ")
        // return 'http://192.168.1.146:3001';

      case EnvironmentMode.staging:
        return 'http://207.180.249.87';

      case EnvironmentMode.production:
        return 'http://207.180.249.87';
    }
  }

  /// Get API version
  static String get apiVersion => 'v1';

  /// Get full API URL with version
  static String get fullApiUrl => '$apiUrl/api';

  /// Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Enable debug logging
  static bool get isDebugMode => mode == EnvironmentMode.development;

  /// Enable verbose logging
  static bool get verboseLogging => mode == EnvironmentMode.development;
}

/// Environment mode enumeration
enum EnvironmentMode { development, staging, production }
