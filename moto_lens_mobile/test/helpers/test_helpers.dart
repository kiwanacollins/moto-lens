import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:moto_lens_mobile/models/auth/auth.dart';
import 'package:moto_lens_mobile/models/auth/auth_response.dart';
import 'package:moto_lens_mobile/models/auth/login_request.dart';
import 'package:moto_lens_mobile/models/auth/register_request.dart';
import 'package:moto_lens_mobile/models/auth/user.dart';
import 'package:moto_lens_mobile/models/auth/user_role.dart';
import 'package:moto_lens_mobile/models/auth/subscription_tier.dart';
import 'package:moto_lens_mobile/models/vehicle/vin_scan_entry.dart';
import 'package:moto_lens_mobile/models/vehicle/vin_decode_result.dart';
import 'package:moto_lens_mobile/models/part_scan_entry.dart';
import 'package:moto_lens_mobile/services/api_service.dart';
import 'package:moto_lens_mobile/services/secure_storage_service.dart';
import 'package:moto_lens_mobile/providers/authentication_provider.dart';
import 'package:moto_lens_mobile/providers/connectivity_provider.dart';

// =============================================================================
// Mock Classes
// =============================================================================

/// Mock for [SecureStorageService] — injected into [AuthenticationProvider].
class MockSecureStorageService extends Mock implements SecureStorageService {}

/// Mock for [ApiService] — injected into [AuthenticationProvider].
class MockApiService extends Mock implements ApiService {}

/// Mock for [ConnectivityProvider] — used in widget tests.
class MockConnectivityProvider extends Mock implements ConnectivityProvider {}

// =============================================================================
// Fallback Values (required by mocktail for non-primitive types)
// =============================================================================

void registerFallbackValues() {
  registerFallbackValue(const LoginRequest(email: '', password: ''));
  registerFallbackValue(
    const RegisterRequest(
      email: '',
      password: '',
      confirmPassword: '',
      firstName: '',
      lastName: '',
    ),
  );
}

// =============================================================================
// Test Data Factories
// =============================================================================

class TestData {
  TestData._();

  static final DateTime _fixedNow = DateTime(2025, 1, 15, 12, 0, 0);

  /// Create a test [User] with sensible defaults.
  static User createUser({
    String id = 'user_123',
    String email = 'mechanic@germancarmedic.com',
    String firstName = 'Max',
    String lastName = 'Mueller',
    UserRole role = UserRole.mechanic,
    SubscriptionTier tier = SubscriptionTier.professional,
    bool emailVerified = true,
    String? garageName,
    String? phoneNumber,
  }) {
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
      subscriptionTier: tier,
      emailVerified: emailVerified,
      garageName: garageName,
      phoneNumber: phoneNumber,
      createdAt: _fixedNow,
      updatedAt: _fixedNow,
    );
  }

  /// Create a test [AuthResponse].
  static AuthResponse createAuthResponse({
    User? user,
    String accessToken = 'test_access_token_abc123',
    String refreshToken = 'test_refresh_token_xyz456',
    Duration expiresIn = const Duration(hours: 1),
    String? message,
  }) {
    return AuthResponse(
      user: user ?? createUser(),
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.now().add(expiresIn),
      message: message ?? 'Login successful',
    );
  }

  /// Create a test [LoginRequest].
  static LoginRequest createLoginRequest({
    String email = 'mechanic@germancarmedic.com',
    String password = 'SecurePw123',
    bool rememberMe = false,
  }) {
    return LoginRequest(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
  }

  /// Create a test [RegisterRequest].
  static RegisterRequest createRegisterRequest({
    String email = 'new.user@germancarmedic.com',
    String password = 'SecurePw123',
    String confirmPassword = 'SecurePw123',
    String firstName = 'Anna',
    String lastName = 'Schmidt',
    UserRole role = UserRole.mechanic,
    bool acceptTerms = true,
  }) {
    return RegisterRequest(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      firstName: firstName,
      lastName: lastName,
      role: role,
      acceptTerms: acceptTerms,
    );
  }

  /// Create a test [VinScanEntry].
  static VinScanEntry createVinScanEntry({
    String vin = 'WBADT63452CK12345',
    String? manufacturer = 'BMW',
    String? model = '3 Series',
    String? year = '2020',
    bool isSynced = true,
  }) {
    return VinScanEntry(
      vin: vin,
      manufacturer: manufacturer,
      model: model,
      year: year,
      scannedAt: _fixedNow,
      isSynced: isSynced,
    );
  }

  /// Create a test [VinDecodeResult].
  static VinDecodeResult createVinDecodeResult({
    String vin = 'WBADT63452CK12345',
    String? manufacturer = 'BMW',
    String? model = '3 Series',
    String? year = '2020',
    String? bodyStyle = 'Sedan',
    String? engineType = 'B58',
    String? transmission = 'Automatic',
    String? fuelType = 'Gasoline',
  }) {
    return VinDecodeResult(
      vin: vin,
      manufacturer: manufacturer,
      model: model,
      year: year,
      bodyStyle: bodyStyle,
      engineType: engineType,
      transmission: transmission,
      fuelType: fuelType,
      decodedAt: _fixedNow,
    );
  }

  /// Create a test [PartScanEntry].
  static PartScanEntry createPartScanEntry({
    String id = 'part_1',
    String scannedValue = '11-42-7-566-327',
    String? partName = 'Oil Filter',
    String? partNumber = '11427566327',
    String? description = 'OEM Oil Filter for BMW N55',
    bool isResolved = true,
  }) {
    return PartScanEntry(
      id: id,
      scannedValue: scannedValue,
      scannedAt: _fixedNow,
      partName: partName,
      partNumber: partNumber,
      description: description,
      isResolved: isResolved,
    );
  }

  /// Create a test [PartDetails].
  static PartDetails createPartDetails({
    String partId = 'part_123',
    String partName = 'Oil Filter',
    String? description = 'OEM Oil Filter for BMW N55 engine',
    String? partNumber = '11-42-7-566-327',
    List<String> symptoms = const [
      'Oil pressure warning',
      'Reduced engine performance',
    ],
  }) {
    return PartDetails(
      partId: partId,
      partName: partName,
      description: description,
      partNumber: partNumber,
      symptoms: symptoms,
    );
  }

  /// Valid JSON payload for a User (as returned by the backend).
  static Map<String, dynamic> userJson({
    String id = 'user_123',
    String email = 'mechanic@germancarmedic.com',
  }) {
    return {
      'id': id,
      'email': email,
      'firstName': 'Max',
      'lastName': 'Mueller',
      'role': 'mechanic',
      'subscriptionTier': 'professional',
      'emailVerified': true,
      'createdAt': _fixedNow.toIso8601String(),
      'updatedAt': _fixedNow.toIso8601String(),
    };
  }

  /// Valid JSON payload for an AuthResponse.
  static Map<String, dynamic> authResponseJson() {
    return {
      'user': userJson(),
      'tokens': {
        'accessToken': 'test_access_token_abc123',
        'refreshToken': 'test_refresh_token_xyz456',
      },
      'expiresAt': DateTime.now()
          .add(const Duration(hours: 1))
          .toIso8601String(),
      'message': 'Login successful',
    };
  }

  /// Valid JSON payload for a VinDecodeResult (as returned by the backend).
  static Map<String, dynamic> vinDecodeResultJson() {
    return {
      'vehicle': {
        'vin': 'WBADT63452CK12345',
        'manufacturer': 'BMW',
        'model': '3 Series',
        'year': '2020',
        'bodyStyle': 'Sedan',
        'engineType': 'B58',
        'transmission': 'Automatic',
        'fuelType': 'Gasoline',
        'displacement': '3.0L',
        'power': '382',
      },
    };
  }

  /// Valid JSON for a PartDetails response.
  static Map<String, dynamic> partDetailsJson() {
    return {
      'success': true,
      'partId': 'part_123',
      'partName': 'Oil Filter',
      'description': 'OEM Oil Filter for BMW N55 engine',
      'partNumber': '11-42-7-566-327',
      'symptoms': ['Oil pressure warning', 'Reduced engine performance'],
      'vehicle': {'year': '2020', 'make': 'BMW', 'model': '3 Series'},
      'generatedAt': '2025-01-15T12:00:00.000Z',
    };
  }
}

// =============================================================================
// Widget Test Helpers
// =============================================================================

/// Wrap a widget in a [MaterialApp] for testing.
Widget buildTestableWidget(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

/// Wrap a widget in [MaterialApp] with a [ConnectivityProvider].
Widget buildWithConnectivityProvider(
  Widget child, {
  required ConnectivityProvider provider,
}) {
  return MaterialApp(
    home: ChangeNotifierProvider<ConnectivityProvider>.value(
      value: provider,
      child: Scaffold(body: child),
    ),
  );
}

/// Wrap a widget in [MaterialApp] with custom [MediaQueryData] for
/// responsive / device-size testing.
Widget buildWithMediaQuery(
  Widget child, {
  required Size screenSize,
  double devicePixelRatio = 1.0,
  double textScaleFactor = 1.0,
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: screenSize,
        devicePixelRatio: devicePixelRatio,
        textScaler: TextScaler.linear(textScaleFactor),
      ),
      child: Scaffold(body: child),
    ),
  );
}
