/// Environment configuration for German Car Medic Mobile App
///
/// Manages environment-specific settings like API URLs for development,
/// staging, and production environments.

class Environment {
  /// Current environment mode
  static const EnvironmentMode mode = EnvironmentMode.development;

  /// Get API base URL for current environment
  static String get apiUrl {
    switch (mode) {
      case EnvironmentMode.development:
        // OPTION 1: Android Emulator (default)
        // return 'http://10.0.2.2:3001';

        // OPTION 2: iOS Simulator
        // return 'http://localhost:3001';

        // OPTION 3: Real device or if 10.0.2.2 doesn't work
        // Use your computer's IP address (find with: ifconfig | grep "inet ")
        return 'http://192.168.1.146:3001'; // Your computer's local IP

      // OPTION 4: If nothing works, try IPv4 localhost
      // return 'http://127.0.0.1:3001';

      case EnvironmentMode.staging:
        return 'https://staging-api.germancarmedic.com';

      case EnvironmentMode.production:
        return 'https://api.germancarmedic.com';
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
