import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'package:moto_lens_mobile/utils/error_handler.dart';
import 'package:moto_lens_mobile/services/api_service.dart';

void main() {
  // ===========================================================================
  // getUserFriendlyMessage
  // ===========================================================================

  group('ErrorHandler.getUserFriendlyMessage', () {
    test('handles NetworkException', () {
      const error = NetworkException('Connection failed');
      final msg = ErrorHandler.getUserFriendlyMessage(error);
      expect(msg.toLowerCase(), contains('network'));
    });

    test('handles AuthenticationException', () {
      const error = AuthenticationException('Invalid email or password');
      final msg = ErrorHandler.getUserFriendlyMessage(error);
      expect(msg, isNotEmpty);
    });

    test('handles ValidationException (returns original message)', () {
      const error = ValidationException('Email already registered');
      final msg = ErrorHandler.getUserFriendlyMessage(error);
      expect(msg, 'Email already registered');
    });

    test('handles RateLimitException', () {
      const error = RateLimitException('Too many requests');
      final msg = ErrorHandler.getUserFriendlyMessage(error);
      expect(msg.toLowerCase(), contains('too many'));
    });

    test('handles TimeoutException', () {
      final error = TimeoutException('timed out');
      final msg = ErrorHandler.getUserFriendlyMessage(error);
      expect(msg.toLowerCase(), contains('timeout'));
    });

    test('handles SocketException (no internet)', () {
      final error = SocketException(
        'Connection refused',
        osError: const OSError('Network is unreachable', 7),
      );
      final msg = ErrorHandler.getUserFriendlyMessage(error);
      expect(
        msg.toLowerCase(),
        anyOf(
          contains('internet'),
          contains('network'),
          contains('connection'),
        ),
      );
    });

    test('handles SocketException (connection refused)', () {
      final error = SocketException(
        'Connection refused',
        osError: const OSError('Connection refused', 61),
      );
      final msg = ErrorHandler.getUserFriendlyMessage(error);
      expect(
        msg.toLowerCase(),
        anyOf(contains('server'), contains('connection')),
      );
    });

    test('handles SocketException (timeout)', () {
      final error = SocketException(
        'Operation timed out',
        osError: const OSError('Operation timed out', 60),
      );
      final msg = ErrorHandler.getUserFriendlyMessage(error);
      expect(msg.toLowerCase(), contains('timeout'));
    });

    test('handles HandshakeException (TLS errors)', () {
      final error = HandshakeException('TLSV1_ALERT_PROTOCOL_VERSION');
      final msg = ErrorHandler.getUserFriendlyMessage(error);
      expect(msg.toLowerCase(), contains('secure connection'));
    });

    test('handles FormatException', () {
      final msg = ErrorHandler.getUserFriendlyMessage(
        const FormatException('bad json'),
      );
      expect(msg.toLowerCase(), contains('process'));
    });

    test('handles generic ApiException with status code', () {
      const error = ApiException('HTTP 500: Internal server failure');
      final msg = ErrorHandler.getUserFriendlyMessage(error);
      expect(msg.toLowerCase(), anyOf(contains('server'), contains('request')));
    });

    test('handles string error with socket info', () {
      final msg = ErrorHandler.getUserFriendlyMessage(
        'SocketException: OS Error: Connection refused',
      );
      expect(msg.toLowerCase(), contains('connection'));
    });

    test('handles string error with TLS info', () {
      final msg = ErrorHandler.getUserFriendlyMessage(
        'HandshakeException: TLSV1_ALERT_PROTOCOL_VERSION',
      );
      expect(msg.toLowerCase(), contains('secure connection'));
    });

    test('returns generic fallback message for unknown error', () {
      final msg = ErrorHandler.getUserFriendlyMessage(42);
      expect(msg, contains('Something went wrong'));
    });
  });

  // ===========================================================================
  // isNetworkError
  // ===========================================================================

  group('ErrorHandler.isNetworkError', () {
    test('returns true for SocketException', () {
      expect(
        ErrorHandler.isNetworkError(const SocketException('fail')),
        isTrue,
      );
    });

    test('returns true for TimeoutException', () {
      expect(ErrorHandler.isNetworkError(TimeoutException('timeout')), isTrue);
    });

    test('returns true for string containing "network"', () {
      expect(
        ErrorHandler.isNetworkError('NetworkException: no internet'),
        isTrue,
      );
    });

    test('returns false for AuthenticationException', () {
      expect(
        ErrorHandler.isNetworkError(const AuthenticationException('bad creds')),
        isFalse,
      );
    });
  });

  // ===========================================================================
  // isAuthError
  // ===========================================================================

  group('ErrorHandler.isAuthError', () {
    test('returns true for AuthenticationException', () {
      expect(
        ErrorHandler.isAuthError(
          const AuthenticationException('Invalid token'),
        ),
        isTrue,
      );
    });

    test('returns true for string containing "unauthorized"', () {
      expect(ErrorHandler.isAuthError('401 Unauthorized'), isTrue);
    });

    test('returns false for NetworkException', () {
      expect(
        ErrorHandler.isAuthError(const NetworkException('no internet')),
        isFalse,
      );
    });
  });

  // ===========================================================================
  // shouldRetry
  // ===========================================================================

  group('ErrorHandler.shouldRetry', () {
    test('returns true for network errors', () {
      expect(ErrorHandler.shouldRetry(const SocketException('fail')), isTrue);
    });

    test('returns true for TimeoutException', () {
      expect(ErrorHandler.shouldRetry(TimeoutException('timeout')), isTrue);
    });

    test('returns true for server 500 ApiException', () {
      expect(
        ErrorHandler.shouldRetry(const ApiException('HTTP 500: server error')),
        isTrue,
      );
    });

    test('returns true for 503 ApiException', () {
      expect(
        ErrorHandler.shouldRetry(
          const ApiException('HTTP 503: service unavailable'),
        ),
        isTrue,
      );
    });

    test('returns false for AuthenticationException', () {
      expect(
        ErrorHandler.shouldRetry(
          const AuthenticationException('invalid token'),
        ),
        isFalse,
      );
    });

    test('returns false for ValidationException', () {
      expect(
        ErrorHandler.shouldRetry(const ValidationException('email taken')),
        isFalse,
      );
    });
  });

  // ===========================================================================
  // getSuggestion
  // ===========================================================================

  group('ErrorHandler.getSuggestion', () {
    test('returns network-related suggestion for SocketException', () {
      final suggestion = ErrorHandler.getSuggestion(
        const SocketException('fail'),
      );
      expect(suggestion, isNotNull);
      expect(suggestion!, contains('internet'));
    });

    test('returns auth suggestion for AuthenticationException', () {
      final suggestion = ErrorHandler.getSuggestion(
        const AuthenticationException('bad creds'),
      );
      expect(suggestion, isNotNull);
      expect(suggestion!, contains('email'));
    });

    test('returns rate limit suggestion for RateLimitException', () {
      final suggestion = ErrorHandler.getSuggestion(
        const RateLimitException('too many'),
      );
      expect(suggestion, isNotNull);
      expect(suggestion!, contains('wait'));
    });

    test('returns null for unknown error types', () {
      final suggestion = ErrorHandler.getSuggestion(42);
      expect(suggestion, isNull);
    });
  });
}
