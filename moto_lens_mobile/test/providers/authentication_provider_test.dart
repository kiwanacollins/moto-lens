import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:moto_lens_mobile/providers/authentication_provider.dart';
import 'package:moto_lens_mobile/providers/authentication_state.dart';
import 'package:moto_lens_mobile/models/auth/auth.dart';
import 'package:moto_lens_mobile/services/api_service.dart';
import 'package:moto_lens_mobile/services/secure_storage_service.dart';

import '../helpers/test_helpers.dart';

void main() {
  late MockSecureStorageService mockStorage;
  late MockApiService mockApi;
  late AuthenticationProvider provider;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockStorage = MockSecureStorageService();
    mockApi = MockApiService();

    // Default stubs for initialization flow
    when(() => mockStorage.hasValidTokens()).thenAnswer((_) async => false);
    when(() => mockStorage.doTokensExpireSoon()).thenAnswer((_) async => false);
    when(() => mockStorage.deleteTokens()).thenAnswer((_) async {});
    when(() => mockApi.dispose()).thenReturn(null);
  });

  tearDown(() {
    provider.dispose();
  });

  /// Helper: create provider and let its async `_initialize` settle.
  Future<AuthenticationProvider> createProvider() async {
    final p = AuthenticationProvider(
      secureStorageService: mockStorage,
      apiService: mockApi,
    );
    // Allow microtasks from _initialize to flush.
    await Future.delayed(Duration.zero);
    return p;
  }

  // ===========================================================================
  // Initialization
  // ===========================================================================

  group('Initialization', () {
    test('starts unauthenticated when no stored tokens', () async {
      provider = await createProvider();

      expect(provider.isAuthenticated, isFalse);
      expect(provider.isUnauthenticated, isTrue);
      expect(provider.currentUser, isNull);
    });

    test('restores authenticated state when valid tokens exist', () async {
      when(() => mockStorage.hasValidTokens()).thenAnswer((_) async => true);
      when(
        () => mockApi.getCurrentUser(),
      ).thenAnswer((_) async => TestData.userJson());

      provider = await createProvider();

      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser, isNotNull);
      expect(provider.currentUser!.email, 'mechanic@motolens.com');
    });

    test(
      'falls back to unauthenticated when stored tokens are invalid (401)',
      () async {
        when(() => mockStorage.hasValidTokens()).thenAnswer((_) async => true);
        when(
          () => mockApi.getCurrentUser(),
        ).thenThrow(const AuthenticationException('Token invalid'));

        provider = await createProvider();

        expect(provider.isAuthenticated, isFalse);
        verify(() => mockStorage.deleteTokens()).called(1);
      },
    );

    test('sets error state on unexpected initialization failure', () async {
      when(
        () => mockStorage.hasValidTokens(),
      ).thenThrow(Exception('disk full'));

      provider = await createProvider();

      expect(provider.hasError, isTrue);
      expect(provider.error, isNotNull);
    });
  });

  // ===========================================================================
  // Login
  // ===========================================================================

  group('Login', () {
    test('successful login updates state to authenticated', () async {
      final authResponse = TestData.createAuthResponse();
      when(() => mockApi.login(any())).thenAnswer((_) async => authResponse);

      provider = await createProvider();

      final result = await provider.login(
        email: 'mechanic@motolens.com',
        password: 'SecurePw123',
      );

      expect(result, isTrue);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser!.email, 'mechanic@motolens.com');
      expect(provider.hasError, isFalse);
    });

    test('login with invalid email fails with validation error', () async {
      provider = await createProvider();

      final result = await provider.login(
        email: 'not-an-email',
        password: 'SecurePw123',
      );

      expect(result, isFalse);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.error, isNotNull);
    });

    test('login with empty password fails', () async {
      provider = await createProvider();

      final result = await provider.login(
        email: 'mechanic@motolens.com',
        password: '',
      );

      expect(result, isFalse);
      expect(provider.error, isNotNull);
    });

    test(
      'login with wrong credentials sets error (AuthenticationException)',
      () async {
        when(
          () => mockApi.login(any()),
        ).thenThrow(const AuthenticationException('Invalid email or password'));

        provider = await createProvider();

        final result = await provider.login(
          email: 'mechanic@motolens.com',
          password: 'WrongPassword1',
        );

        expect(result, isFalse);
        expect(provider.isAuthenticated, isFalse);
        expect(provider.error, isNotNull);
      },
    );

    test('login with network error produces friendly message', () async {
      when(
        () => mockApi.login(any()),
      ).thenThrow(const NetworkException('Connection failed: no internet'));

      provider = await createProvider();

      final result = await provider.login(
        email: 'mechanic@motolens.com',
        password: 'SecurePw123',
      );

      expect(result, isFalse);
      expect(provider.error, isNotNull);
      // Error should be user-friendly, not raw exception text.
      expect(provider.error, isNot(contains('NetworkException')));
    });

    test('login with rate limit exception produces friendly message', () async {
      when(
        () => mockApi.login(any()),
      ).thenThrow(const RateLimitException('Too many login attempts'));

      provider = await createProvider();

      final result = await provider.login(
        email: 'mechanic@motolens.com',
        password: 'SecurePw123',
      );

      expect(result, isFalse);
      expect(provider.error, isNotNull);
    });

    test('loading state is set during login', () async {
      final states = <bool>[];

      when(() => mockApi.login(any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 10));
        return TestData.createAuthResponse();
      });

      provider = await createProvider();
      provider.addListener(() {
        states.add(provider.isLoading);
      });

      await provider.login(
        email: 'mechanic@motolens.com',
        password: 'SecurePw123',
      );

      // Should have been true at some point, then false.
      expect(states.contains(true), isTrue);
      expect(provider.isLoading, isFalse);
    });
  });

  // ===========================================================================
  // Registration
  // ===========================================================================

  group('Registration', () {
    test('successful registration updates state to authenticated', () async {
      final authResponse = TestData.createAuthResponse(
        user: TestData.createUser(
          email: 'new.user@motolens.com',
          firstName: 'Anna',
          lastName: 'Schmidt',
        ),
      );
      when(() => mockApi.register(any())).thenAnswer((_) async => authResponse);

      provider = await createProvider();

      final result = await provider.register(
        email: 'new.user@motolens.com',
        password: 'SecurePw123',
        confirmPassword: 'SecurePw123',
        firstName: 'Anna',
        lastName: 'Schmidt',
        acceptTerms: true,
      );

      expect(result, isTrue);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser!.firstName, 'Anna');
    });

    test('registration without accepting terms fails validation', () async {
      provider = await createProvider();

      final result = await provider.register(
        email: 'new.user@motolens.com',
        password: 'SecurePw123',
        confirmPassword: 'SecurePw123',
        firstName: 'Anna',
        lastName: 'Schmidt',
        acceptTerms: false,
      );

      expect(result, isFalse);
      expect(provider.error, contains('Terms'));
    });

    test('registration with mismatched passwords fails', () async {
      provider = await createProvider();

      final result = await provider.register(
        email: 'new.user@motolens.com',
        password: 'SecurePw123',
        confirmPassword: 'DifferentPw456',
        firstName: 'Anna',
        lastName: 'Schmidt',
        acceptTerms: true,
      );

      expect(result, isFalse);
      expect(provider.error, isNotNull);
    });

    test('registration with weak password fails validation', () async {
      provider = await createProvider();

      final result = await provider.register(
        email: 'new.user@motolens.com',
        password: 'weak',
        confirmPassword: 'weak',
        firstName: 'Anna',
        lastName: 'Schmidt',
        acceptTerms: true,
      );

      expect(result, isFalse);
      expect(provider.error, isNotNull);
    });

    test(
      'registration with duplicate email throws ValidationException',
      () async {
        when(() => mockApi.register(any())).thenThrow(
          const ValidationException('Email address is already registered'),
        );

        provider = await createProvider();

        final result = await provider.register(
          email: 'existing@motolens.com',
          password: 'SecurePw123',
          confirmPassword: 'SecurePw123',
          firstName: 'Anna',
          lastName: 'Schmidt',
          acceptTerms: true,
        );

        expect(result, isFalse);
        expect(provider.error, isNotNull);
      },
    );

    test('registration with short first name fails', () async {
      provider = await createProvider();

      final result = await provider.register(
        email: 'new.user@motolens.com',
        password: 'SecurePw123',
        confirmPassword: 'SecurePw123',
        firstName: 'A',
        lastName: 'Schmidt',
        acceptTerms: true,
      );

      expect(result, isFalse);
      expect(provider.error, isNotNull);
    });
  });

  // ===========================================================================
  // Logout
  // ===========================================================================

  group('Logout', () {
    test('logout clears authenticated state', () async {
      // Start authenticated.
      when(() => mockStorage.hasValidTokens()).thenAnswer((_) async => true);
      when(
        () => mockApi.getCurrentUser(),
      ).thenAnswer((_) async => TestData.userJson());
      when(() => mockApi.logout()).thenAnswer((_) async {});

      provider = await createProvider();
      expect(provider.isAuthenticated, isTrue);

      await provider.logout();

      expect(provider.isAuthenticated, isFalse);
      expect(provider.isUnauthenticated, isTrue);
      expect(provider.currentUser, isNull);
    });

    test('logout still clears state even if API call fails', () async {
      when(() => mockStorage.hasValidTokens()).thenAnswer((_) async => true);
      when(
        () => mockApi.getCurrentUser(),
      ).thenAnswer((_) async => TestData.userJson());
      when(
        () => mockApi.logout(),
      ).thenThrow(const NetworkException('No internet'));

      provider = await createProvider();
      expect(provider.isAuthenticated, isTrue);

      await provider.logout();

      // Even though the API call failed, local state must be cleared.
      expect(provider.isAuthenticated, isFalse);
    });
  });

  // ===========================================================================
  // Password Reset
  // ===========================================================================

  group('Password Reset', () {
    test('successful password reset request returns true', () async {
      when(() => mockApi.requestPasswordReset(any())).thenAnswer((_) async {});

      provider = await createProvider();

      final result = await provider.requestPasswordReset(
        'mechanic@motolens.com',
      );

      expect(result, isTrue);
      expect(provider.hasError, isFalse);
    });

    test('password reset with invalid email fails', () async {
      provider = await createProvider();

      final result = await provider.requestPasswordReset('not-an-email');

      expect(result, isFalse);
      expect(provider.error, contains('email'));
    });

    test('password reset with rate limit error', () async {
      when(
        () => mockApi.requestPasswordReset(any()),
      ).thenThrow(const RateLimitException('Too many password reset requests'));

      provider = await createProvider();

      final result = await provider.requestPasswordReset(
        'mechanic@motolens.com',
      );

      expect(result, isFalse);
      expect(provider.error, isNotNull);
    });
  });

  // ===========================================================================
  // Token Refresh
  // ===========================================================================

  group('Token Refresh', () {
    test('successful token refresh keeps user authenticated', () async {
      final authResponse = TestData.createAuthResponse();
      when(() => mockApi.refreshToken()).thenAnswer((_) async => authResponse);

      // Start authenticated.
      when(() => mockStorage.hasValidTokens()).thenAnswer((_) async => true);
      when(
        () => mockApi.getCurrentUser(),
      ).thenAnswer((_) async => TestData.userJson());

      provider = await createProvider();
      expect(provider.isAuthenticated, isTrue);

      final result = await provider.refreshTokens();

      expect(result, isTrue);
      expect(provider.isAuthenticated, isTrue);
    });

    test('failed token refresh triggers logout', () async {
      when(
        () => mockApi.refreshToken(),
      ).thenThrow(const AuthenticationException('Refresh token expired'));
      when(() => mockApi.logout()).thenAnswer((_) async {});

      // Start authenticated.
      when(() => mockStorage.hasValidTokens()).thenAnswer((_) async => true);
      when(
        () => mockApi.getCurrentUser(),
      ).thenAnswer((_) async => TestData.userJson());

      provider = await createProvider();
      expect(provider.isAuthenticated, isTrue);

      final result = await provider.refreshTokens();

      expect(result, isFalse);
      expect(provider.isAuthenticated, isFalse);
    });
  });

  // ===========================================================================
  // Session Management
  // ===========================================================================

  group('Session Management', () {
    test('clearError removes current error', () async {
      when(
        () => mockApi.login(any()),
      ).thenThrow(const AuthenticationException('Bad credentials'));

      provider = await createProvider();
      await provider.login(
        email: 'mechanic@motolens.com',
        password: 'Wrong1234',
      );

      expect(provider.hasError, isTrue);

      provider.clearError();

      expect(provider.hasError, isFalse);
      expect(provider.error, isNull);
    });

    test('profile update changes user data', () async {
      final updatedUserJson = TestData.userJson();
      updatedUserJson['firstName'] = 'Updated';

      when(
        () => mockApi.updateProfile(any()),
      ).thenAnswer((_) async => updatedUserJson);

      // Start authenticated.
      when(() => mockStorage.hasValidTokens()).thenAnswer((_) async => true);
      when(
        () => mockApi.getCurrentUser(),
      ).thenAnswer((_) async => TestData.userJson());

      provider = await createProvider();
      expect(provider.currentUser!.firstName, 'Max');

      final result = await provider.updateProfile({'firstName': 'Updated'});

      expect(result, isTrue);
      expect(provider.currentUser!.firstName, 'Updated');
    });

    test('profile update failure sets error', () async {
      when(
        () => mockApi.updateProfile(any()),
      ).thenThrow(const NetworkException('No internet'));

      // Start authenticated.
      when(() => mockStorage.hasValidTokens()).thenAnswer((_) async => true);
      when(
        () => mockApi.getCurrentUser(),
      ).thenAnswer((_) async => TestData.userJson());

      provider = await createProvider();

      final result = await provider.updateProfile({'firstName': 'Updated'});

      expect(result, isFalse);
      expect(provider.hasError, isTrue);
    });
  });

  // ===========================================================================
  // Offline Behavior
  // ===========================================================================

  group('Offline Behavior', () {
    test('login during network outage reports friendly error', () async {
      when(
        () => mockApi.login(any()),
      ).thenThrow(const NetworkException('Connection failed: no internet'));

      provider = await createProvider();

      final result = await provider.login(
        email: 'mechanic@motolens.com',
        password: 'SecurePw123',
      );

      expect(result, isFalse);
      expect(provider.error, isNotNull);
      expect(
        provider.error!.toLowerCase(),
        anyOf(
          contains('network'),
          contains('internet'),
          contains('connection'),
          contains('something went wrong'),
        ),
      );
    });

    test(
      'password reset during network outage reports friendly error',
      () async {
        when(
          () => mockApi.requestPasswordReset(any()),
        ).thenThrow(const NetworkException('Connection failed'));

        provider = await createProvider();

        final result = await provider.requestPasswordReset(
          'mechanic@motolens.com',
        );

        expect(result, isFalse);
        expect(provider.error, isNotNull);
      },
    );
  });

  // ===========================================================================
  // Debug / Utility
  // ===========================================================================

  group('Debug Info', () {
    test('getDebugInfo returns expected keys', () async {
      provider = await createProvider();

      final debugInfo = provider.getDebugInfo();

      expect(debugInfo, containsPair('status', isA<String>()));
      expect(debugInfo, containsPair('isAuthenticated', isA<bool>()));
      expect(debugInfo, containsPair('isLoading', isA<bool>()));
      expect(debugInfo, containsPair('hasError', isA<bool>()));
    });
  });
}
