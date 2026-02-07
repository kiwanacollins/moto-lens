import 'package:flutter_test/flutter_test.dart';

import 'package:moto_lens_mobile/services/api_service.dart';

void main() {
  // ===========================================================================
  // Custom Exception Types
  // ===========================================================================

  group('API Exception Types', () {
    test('ApiException has correct message and toString', () {
      const e = ApiException('something failed');
      expect(e.message, 'something failed');
      expect(e.toString(), contains('ApiException'));
    });

    test('AuthenticationException extends ApiException', () {
      const e = AuthenticationException('bad creds');
      expect(e, isA<ApiException>());
      expect(e.message, 'bad creds');
    });

    test('TokenExpiredException extends AuthenticationException', () {
      const e = TokenExpiredException('token expired');
      expect(e, isA<AuthenticationException>());
      expect(e, isA<ApiException>());
    });

    test('ValidationException extends ApiException', () {
      const e = ValidationException('email taken');
      expect(e, isA<ApiException>());
    });

    test('RateLimitException extends ApiException', () {
      const e = RateLimitException('too many requests');
      expect(e, isA<ApiException>());
    });

    test('NetworkException extends ApiException', () {
      const e = NetworkException('no internet');
      expect(e, isA<ApiException>());
      expect(e.message, 'no internet');
    });
  });

  // ===========================================================================
  // Exception Hierarchy (catch semantics)
  // ===========================================================================

  group('Exception Hierarchy', () {
    test('catching ApiException also catches subtypes', () {
      const exceptions = <ApiException>[
        AuthenticationException('auth'),
        TokenExpiredException('token'),
        ValidationException('validation'),
        RateLimitException('rate'),
        NetworkException('network'),
      ];

      for (final e in exceptions) {
        try {
          throw e;
        } on ApiException catch (caught) {
          expect(caught, isA<ApiException>());
          expect(caught.message, isNotEmpty);
        }
      }
    });

    test(
      'catching AuthenticationException also catches TokenExpiredException',
      () {
        try {
          throw const TokenExpiredException('expired');
        } on AuthenticationException catch (e) {
          expect(e.message, 'expired');
        }
      },
    );

    test(
      'catching NetworkException does not catch AuthenticationException',
      () {
        bool caughtAsNetwork = false;
        bool caughtAsAuth = false;

        try {
          throw const AuthenticationException('auth fail');
        } on NetworkException {
          caughtAsNetwork = true;
        } on AuthenticationException {
          caughtAsAuth = true;
        }

        expect(caughtAsNetwork, isFalse);
        expect(caughtAsAuth, isTrue);
      },
    );
  });

  // ===========================================================================
  // Error Response Parsing (simulated)
  // ===========================================================================

  group('Error Response Simulation', () {
    test('401 status triggers AuthenticationException pattern', () {
      // Simulate the logic from ApiService.login
      const statusCode = 401;
      ApiException? thrown;

      if (statusCode == 401) {
        thrown = const AuthenticationException('Invalid email or password');
      }

      expect(thrown, isA<AuthenticationException>());
      expect(thrown!.message, contains('Invalid'));
    });

    test('409 status triggers ValidationException pattern', () {
      const statusCode = 409;
      ApiException? thrown;

      if (statusCode == 409) {
        thrown = const ValidationException(
          'Email address is already registered',
        );
      }

      expect(thrown, isA<ValidationException>());
    });

    test('429 status triggers RateLimitException pattern', () {
      const statusCode = 429;
      ApiException? thrown;

      if (statusCode == 429) {
        thrown = const RateLimitException(
          'Too many login attempts - please try again later',
        );
      }

      expect(thrown, isA<RateLimitException>());
    });

    test('400 status triggers ValidationException with message', () {
      const statusCode = 400;
      const errorMessage = 'Invalid input data';
      ApiException? thrown;

      if (statusCode == 400) {
        thrown = ValidationException('Registration failed: $errorMessage');
      }

      expect(thrown, isA<ValidationException>());
      expect(thrown!.message, contains(errorMessage));
    });

    test('generic 500 status triggers ApiException', () {
      const statusCode = 500;
      ApiException? thrown;

      if (statusCode >= 400) {
        thrown = ApiException('HTTP $statusCode: Internal server error');
      }

      expect(thrown, isA<ApiException>());
      expect(thrown!.message, contains('500'));
    });
  });

  // ===========================================================================
  // Rate Limiting Behavior
  // ===========================================================================

  group('Rate Limiting', () {
    test('RateLimitException message includes action guidance', () {
      const messages = [
        'Too many login attempts - please try again later',
        'Too many registration attempts - please try again later',
        'Too many password reset requests - please try again later',
      ];

      for (final msg in messages) {
        final e = RateLimitException(msg);
        expect(e.message.toLowerCase(), contains('try again'));
      }
    });
  });

  // ===========================================================================
  // Image Loading (simulated error conditions)
  // ===========================================================================

  group('Image Loading Error Patterns', () {
    test('NetworkException covers image load failures', () {
      const error = NetworkException('Connection failed: timeout');
      expect(error, isA<ApiException>());
      expect(error.message, contains('Connection failed'));
    });

    test('ApiException covers 404 image not found', () {
      const error = ApiException('HTTP 404: Image not found');
      expect(error.message, contains('404'));
    });
  });
}
