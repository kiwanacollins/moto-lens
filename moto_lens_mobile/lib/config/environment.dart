/// Environment configuration for MotoLens Mobile App
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
        // For Android Emulator, use 10.0.2.2 to access host machine's localhost
        // For iOS Simulator, localhost works fine
        // For real devices, use your computer's IP address (e.g., http://192.168.1.100:3001)
        return 'http://10.0.2.2:3001'; // Android emulator
        // return 'http://localhost:3001'; // iOS simulator
        // return 'http://192.168.1.100:3001'; // Real device (replace with your IP)

      case EnvironmentMode.staging:
        return 'https://staging-api.motolens.com';

      case EnvironmentMode.production:
        return 'https://api.motolens.com';
    }
  }

  /// Get API version
  static String get apiVersion => 'v1';

  /// Get full API URL with version
  static String get fullApiUrl => '$apiUrl/api/$apiVersion';

  /// Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Enable debug logging
  static bool get isDebugMode => mode == EnvironmentMode.development;

  /// Enable verbose logging
  static bool get verboseLogging => mode == EnvironmentMode.development;
}

/// Environment mode enumeration
enum EnvironmentMode {
  development,
  staging,
  production,
}
