import 'package:flutter_test/flutter_test.dart';

import 'package:moto_lens_mobile/models/auth/user.dart';
import 'package:moto_lens_mobile/models/auth/user_role.dart';
import 'package:moto_lens_mobile/models/auth/subscription_tier.dart';
import 'package:moto_lens_mobile/models/auth/auth_response.dart';
import 'package:moto_lens_mobile/models/auth/login_request.dart';
import 'package:moto_lens_mobile/models/auth/register_request.dart';
import 'package:moto_lens_mobile/providers/authentication_state.dart';

import '../../helpers/test_helpers.dart';

void main() {
  // ===========================================================================
  // User Model
  // ===========================================================================

  group('User Model', () {
    test('fromJson creates user with all fields', () {
      final json = TestData.userJson();
      final user = User.fromJson(json);

      expect(user.id, 'user_123');
      expect(user.email, 'mechanic@germancarmedic.com');
      expect(user.firstName, 'Max');
      expect(user.lastName, 'Mueller');
      expect(user.role, UserRole.mechanic);
      expect(user.subscriptionTier, SubscriptionTier.professional);
      expect(user.emailVerified, isTrue);
    });

    test('toJson produces valid JSON round-trip', () {
      final original = TestData.createUser();
      final json = original.toJson();
      final restored = User.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.email, original.email);
      expect(restored.firstName, original.firstName);
      expect(restored.lastName, original.lastName);
      expect(restored.role, original.role);
      expect(restored.subscriptionTier, original.subscriptionTier);
    });

    test('fullName concatenates first and last name', () {
      final user = TestData.createUser(firstName: 'Max', lastName: 'Mueller');
      expect(user.fullName, 'Max Mueller');
    });

    test('displayName uses garageName when available', () {
      final user = TestData.createUser(garageName: 'AutoFix Berlin');
      expect(user.displayName, 'AutoFix Berlin');
    });

    test('displayName falls back to fullName', () {
      final user = TestData.createUser();
      expect(user.displayName, 'Max Mueller');
    });

    test('initials returns first letter of each name', () {
      final user = TestData.createUser(firstName: 'Max', lastName: 'Mueller');
      expect(user.initials, 'MM');
    });

    test('isProfileComplete checks required fields', () {
      final complete = TestData.createUser(emailVerified: true);
      expect(complete.isProfileComplete, isTrue);

      final incomplete = TestData.createUser(emailVerified: false);
      expect(incomplete.isProfileComplete, isFalse);
    });

    test('copyWith creates updated copy', () {
      final original = TestData.createUser();
      final updated = original.copyWith(firstName: 'Updated');

      expect(updated.firstName, 'Updated');
      expect(updated.email, original.email); // unchanged
    });

    group('Validation', () {
      test('isValidEmail accepts correct emails', () {
        expect(User.isValidEmail('test@example.com'), isTrue);
        expect(User.isValidEmail('mechanic@garage.de'), isTrue);
        expect(User.isValidEmail('a.b+c@domain.co.uk'), isTrue);
      });

      test('isValidEmail rejects invalid emails', () {
        expect(User.isValidEmail(''), isFalse);
        expect(User.isValidEmail('notanemail'), isFalse);
        expect(User.isValidEmail('@missing.com'), isFalse);
        expect(User.isValidEmail('missing@'), isFalse);
      });

      test('isValidPassword enforces strength rules', () {
        expect(User.isValidPassword('SecurePw1'), isTrue);
        expect(User.isValidPassword('A1bcdefg'), isTrue);

        expect(User.isValidPassword('short1A'), isFalse); // too short
        expect(User.isValidPassword('nouppercase1'), isFalse);
        expect(User.isValidPassword('NOLOWERCASE1'), isFalse);
        expect(User.isValidPassword('NoNumbers'), isFalse);
      });

      test('isValidName requires at least 2 chars', () {
        expect(User.isValidName('Ma'), isTrue);
        expect(User.isValidName('A'), isFalse);
        expect(User.isValidName(''), isFalse);
      });

      test('isValidPhoneNumber accepts valid formats', () {
        expect(User.isValidPhoneNumber(null), isTrue); // optional
        expect(User.isValidPhoneNumber(''), isTrue);
        expect(User.isValidPhoneNumber('+49 170 1234567'), isTrue);
        expect(User.isValidPhoneNumber('(555) 123-4567'), isTrue);
      });
    });

    test('equality works correctly', () {
      final a = TestData.createUser();
      final b = TestData.createUser();
      expect(a, equals(b));

      final c = TestData.createUser(id: 'different_id');
      expect(a, isNot(equals(c)));
    });
  });

  // ===========================================================================
  // UserRole
  // ===========================================================================

  group('UserRole', () {
    test('fromString maps known strings', () {
      expect(UserRole.fromString('mechanic'), UserRole.mechanic);
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('customer'), UserRole.customer);
    });

    test('fromString maps backend-specific roles', () {
      expect(UserRole.fromString('shop_owner'), UserRole.mechanic);
      expect(UserRole.fromString('support'), UserRole.admin);
    });

    test('fromString defaults to mechanic for unknown', () {
      expect(UserRole.fromString('unknown_role'), UserRole.mechanic);
    });

    test('displayName returns readable names', () {
      expect(UserRole.mechanic.displayName, 'Mechanic');
      expect(UserRole.admin.displayName, 'Administrator');
      expect(UserRole.customer.displayName, 'Customer');
    });

    test('isAdmin identifies admin only', () {
      expect(UserRole.admin.isAdmin, isTrue);
      expect(UserRole.mechanic.isAdmin, isFalse);
    });

    test('isProfessional identifies mechanic and admin', () {
      expect(UserRole.mechanic.isProfessional, isTrue);
      expect(UserRole.admin.isProfessional, isTrue);
      expect(UserRole.customer.isProfessional, isFalse);
    });
  });

  // ===========================================================================
  // SubscriptionTier
  // ===========================================================================

  group('SubscriptionTier', () {
    test('fromString maps known strings', () {
      expect(SubscriptionTier.fromString('free'), SubscriptionTier.free);
      expect(
        SubscriptionTier.fromString('professional'),
        SubscriptionTier.professional,
      );
      expect(
        SubscriptionTier.fromString('enterprise'),
        SubscriptionTier.enterprise,
      );
    });

    test('fromString maps backend aliases', () {
      expect(
        SubscriptionTier.fromString('basic'),
        SubscriptionTier.professional,
      );
      expect(SubscriptionTier.fromString('pro'), SubscriptionTier.professional);
    });

    test('fromString defaults to free for unknown', () {
      expect(SubscriptionTier.fromString('xyz'), SubscriptionTier.free);
    });

    test('hasUnlimitedLookups true for paid tiers', () {
      expect(SubscriptionTier.free.hasUnlimitedLookups, isFalse);
      expect(SubscriptionTier.professional.hasUnlimitedLookups, isTrue);
      expect(SubscriptionTier.enterprise.hasUnlimitedLookups, isTrue);
    });

    test('hasPartsAccess true for professional+', () {
      expect(SubscriptionTier.free.hasPartsAccess, isFalse);
      expect(SubscriptionTier.professional.hasPartsAccess, isTrue);
      expect(SubscriptionTier.enterprise.hasPartsAccess, isTrue);
    });

    test('hasApiAccess only for enterprise', () {
      expect(SubscriptionTier.free.hasApiAccess, isFalse);
      expect(SubscriptionTier.professional.hasApiAccess, isFalse);
      expect(SubscriptionTier.enterprise.hasApiAccess, isTrue);
    });

    test('dailyLookupLimit correct for each tier', () {
      expect(SubscriptionTier.free.dailyLookupLimit, 5);
      expect(SubscriptionTier.professional.dailyLookupLimit, -1);
      expect(SubscriptionTier.enterprise.dailyLookupLimit, -1);
    });

    test('monthlyPrice correct for each tier', () {
      expect(SubscriptionTier.free.monthlyPrice, 0.0);
      expect(SubscriptionTier.professional.monthlyPrice, 29.99);
      expect(SubscriptionTier.enterprise.monthlyPrice, 99.99);
    });
  });

  // ===========================================================================
  // AuthResponse
  // ===========================================================================

  group('AuthResponse', () {
    test('fromJson parses nested tokens format', () {
      final json = TestData.authResponseJson();
      final response = AuthResponse.fromJson(json);

      expect(response.accessToken, 'test_access_token_abc123');
      expect(response.refreshToken, 'test_refresh_token_xyz456');
      expect(response.user.email, 'mechanic@germancarmedic.com');
      expect(response.message, 'Login successful');
    });

    test('fromJson parses flat tokens format', () {
      final json = {
        'user': TestData.userJson(),
        'accessToken': 'flat_access',
        'refreshToken': 'flat_refresh',
        'expiresAt': DateTime.now()
            .add(const Duration(hours: 1))
            .toIso8601String(),
      };

      final response = AuthResponse.fromJson(json);

      expect(response.accessToken, 'flat_access');
      expect(response.refreshToken, 'flat_refresh');
    });

    test('isExpired returns true for past expiresAt', () {
      final response = TestData.createAuthResponse(
        expiresIn: const Duration(hours: -1),
      );
      expect(response.isExpired, isTrue);
    });

    test('isExpired returns false for future expiresAt', () {
      final response = TestData.createAuthResponse(
        expiresIn: const Duration(hours: 1),
      );
      expect(response.isExpired, isFalse);
    });

    test('expiresSoon returns true within 5-minute window', () {
      final response = TestData.createAuthResponse(
        expiresIn: const Duration(minutes: 3),
      );
      expect(response.expiresSoon, isTrue);
    });

    test('toJson round-trip', () {
      final original = TestData.createAuthResponse();
      final json = original.toJson();

      expect(json['accessToken'], original.accessToken);
      expect(json['refreshToken'], original.refreshToken);
    });
  });

  // ===========================================================================
  // LoginRequest
  // ===========================================================================

  group('LoginRequest', () {
    test('isValid with correct data', () {
      final request = TestData.createLoginRequest();
      expect(request.isValid, isTrue);
      expect(request.validate(), isEmpty);
    });

    test('validate rejects empty email', () {
      final request = TestData.createLoginRequest(email: '');
      expect(request.isValid, isFalse);
      expect(request.validate(), contains('Email is required'));
    });

    test('validate rejects invalid email', () {
      final request = TestData.createLoginRequest(email: 'bad');
      expect(request.isValid, isFalse);
    });

    test('validate rejects empty password', () {
      final request = TestData.createLoginRequest(password: '');
      expect(request.isValid, isFalse);
      expect(request.validate(), contains('Password is required'));
    });

    test('toJson lowercases and trims email', () {
      final request = TestData.createLoginRequest(
        email: '  Test@GermanCarMedic.com  ',
      );
      final json = request.toJson();
      expect(json['email'], 'test@germancarmedic.com');
    });
  });

  // ===========================================================================
  // RegisterRequest
  // ===========================================================================

  group('RegisterRequest', () {
    test('isValid with correct data', () {
      final request = TestData.createRegisterRequest();
      expect(request.isValid, isTrue);
    });

    test('validate rejects mismatched passwords', () {
      final request = TestData.createRegisterRequest(
        password: 'SecurePw123',
        confirmPassword: 'Different123',
      );
      expect(request.isValid, isFalse);
      expect(request.validate().any((e) => e.contains('match')), isTrue);
    });

    test('validate rejects weak password', () {
      final request = TestData.createRegisterRequest(
        password: 'weak',
        confirmPassword: 'weak',
      );
      expect(request.isValid, isFalse);
    });

    test('validate rejects short first name', () {
      final request = TestData.createRegisterRequest(firstName: 'A');
      expect(request.isValid, isFalse);
    });

    test('validate requires terms acceptance', () {
      final request = TestData.createRegisterRequest(acceptTerms: false);
      expect(request.isValid, isFalse);
      expect(request.validate().any((e) => e.contains('Terms')), isTrue);
    });

    test('toJson lowercases and trims email', () {
      final request = TestData.createRegisterRequest(
        email: '  New.User@GermanCarMedic.com  ',
      );
      final json = request.toJson();
      expect(json['email'], 'new.user@germancarmedic.com');
    });
  });

  // ===========================================================================
  // AuthenticationState
  // ===========================================================================

  group('AuthenticationState', () {
    test('initial state is not authenticated', () {
      const state = AuthenticationState.initial;
      expect(state.isAuthenticated, isFalse);
      expect(state.isInitializing, isTrue);
      expect(state.user, isNull);
    });

    test('authenticated state has user', () {
      final user = TestData.createUser();
      final state = AuthenticationState.authenticated(user);
      expect(state.isAuthenticated, isTrue);
      expect(state.user, isNotNull);
      expect(state.lastLoginAt, isNotNull);
    });

    test('unauthenticated state has no user', () {
      const state = AuthenticationState.unauthenticated;
      expect(state.isUnauthenticated, isTrue);
      expect(state.user, isNull);
    });

    test('loading state sets isLoading', () {
      final state = AuthenticationState.loading();
      expect(state.isAuthLoading, isTrue);
    });

    test('error state preserves error message', () {
      final state = AuthenticationState.withError('Something failed');
      expect(state.hasError, isTrue);
      expect(state.error, 'Something failed');
    });

    test('copyWith clears error when requested', () {
      final state = AuthenticationState.withError('Error');
      final cleared = state.copyWith(clearError: true);
      expect(cleared.hasError, isFalse);
      expect(cleared.error, isNull);
    });

    test('displayName returns Guest when no user', () {
      const state = AuthenticationState.unauthenticated;
      expect(state.displayName, 'Guest');
    });

    test('equality works for identical states', () {
      const a = AuthenticationState.unauthenticated;
      const b = AuthenticationState.unauthenticated;
      expect(a, equals(b));
    });
  });
}
