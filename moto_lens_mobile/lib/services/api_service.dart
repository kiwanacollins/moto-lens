import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/auth/auth_response.dart';
import '../models/auth/login_request.dart';
import '../models/auth/register_request.dart';
import 'secure_storage_service.dart';

/// HTTP API service for MotoLens backend communication
///
/// Handles all API requests with automatic token management,
/// request/response serialization, and error handling.
class ApiService {
  static const String baseUrl = 'https://api.motolens.com';
  static const String apiVersion = 'v1';
  static const Duration timeout = Duration(seconds: 30);

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final SecureStorageService _secureStorage = SecureStorageService();
  final http.Client _client = http.Client();

  /// Get full API URL
  String get apiUrl => '$baseUrl/api/$apiVersion';

  /// Common headers for all requests
  Map<String, String> get _baseHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'MotoLens-Mobile/1.0.0',
    'X-Client-Platform': Platform.operatingSystem,
  };

  /// Get headers with authentication token
  Future<Map<String, String>> _getAuthHeaders() async {
    final headers = Map<String, String>.from(_baseHeaders);

    final accessToken = await _secureStorage.getAccessToken();
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    return headers;
  }

  /// Make authenticated GET request
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$apiUrl$endpoint');
    final headers = await _getAuthHeaders();

    try {
      final response = await _client
          .get(url, headers: headers)
          .timeout(timeout);

      return await _handleResponse(response);
    } catch (e) {
      throw ApiException('GET request failed: $e');
    }
  }

  /// Make authenticated POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$apiUrl$endpoint');
    final headers = await _getAuthHeaders();

    try {
      final response = await _client
          .post(
            url,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);

      return await _handleResponse(response);
    } catch (e) {
      throw ApiException('POST request failed: $e');
    }
  }

  /// Make authenticated PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$apiUrl$endpoint');
    final headers = await _getAuthHeaders();

    try {
      final response = await _client
          .put(
            url,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);

      return await _handleResponse(response);
    } catch (e) {
      throw ApiException('PUT request failed: $e');
    }
  }

  /// Make authenticated DELETE request
  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$apiUrl$endpoint');
    final headers = await _getAuthHeaders();

    try {
      final response = await _client
          .delete(url, headers: headers)
          .timeout(timeout);

      return await _handleResponse(response);
    } catch (e) {
      throw ApiException('DELETE request failed: $e');
    }
  }

  /// Make unauthenticated POST request (login, register)
  Future<http.Response> postPublic(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$apiUrl$endpoint');

    try {
      final response = await _client
          .post(
            url,
            headers: _baseHeaders,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);

      return response;
    } catch (e) {
      throw ApiException('Public POST request failed: $e');
    }
  }

  /// Handle response and automatic token refresh
  Future<http.Response> _handleResponse(http.Response response) async {
    // Handle unauthorized - attempt token refresh
    if (response.statusCode == 401) {
      final refreshed = await _attemptTokenRefresh();
      if (!refreshed) {
        // Clear invalid tokens and throw auth exception
        await _secureStorage.deleteTokens();
        throw AuthenticationException(
          'Authentication failed - please login again',
        );
      }

      // Retry the original request would require complex logic here
      // For now, throw exception and let the caller retry
      throw TokenExpiredException('Token expired - request retry needed');
    }

    // Handle other HTTP errors
    if (response.statusCode >= 400) {
      final errorMessage = _extractErrorMessage(response);
      throw ApiException('HTTP ${response.statusCode}: $errorMessage');
    }

    return response;
  }

  /// Extract error message from response body
  String _extractErrorMessage(http.Response response) {
    try {
      final body = json.decode(response.body);
      return body['message'] ?? body['error'] ?? 'Unknown error occurred';
    } catch (e) {
      return 'Request failed with status ${response.statusCode}';
    }
  }

  /// Attempt to refresh access token
  Future<bool> _attemptTokenRefresh() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await postPublic(
        '/auth/refresh',
        body: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        await _secureStorage.saveAuthTokens(authResponse);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// ==================== AUTHENTICATION ENDPOINTS ====================

  /// Login with email and password
  Future<AuthResponse> login(LoginRequest loginRequest) async {
    try {
      final response = await postPublic(
        '/auth/login',
        body: loginRequest.toJson(),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        await _secureStorage.saveAuthTokens(authResponse);
        return authResponse;
      } else if (response.statusCode == 401) {
        throw AuthenticationException('Invalid email or password');
      } else if (response.statusCode == 429) {
        throw RateLimitException(
          'Too many login attempts - please try again later',
        );
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw AuthenticationException('Login failed: $errorMessage');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Login request failed: $e');
    }
  }

  /// Register new user account
  Future<AuthResponse> register(RegisterRequest registerRequest) async {
    try {
      final response = await postPublic(
        '/auth/register',
        body: registerRequest.toJson(),
      );

      if (response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        await _secureStorage.saveAuthTokens(authResponse);
        return authResponse;
      } else if (response.statusCode == 409) {
        throw ValidationException('Email address is already registered');
      } else if (response.statusCode == 400) {
        final errorMessage = _extractErrorMessage(response);
        throw ValidationException('Registration failed: $errorMessage');
      } else if (response.statusCode == 429) {
        throw RateLimitException(
          'Too many registration attempts - please try again later',
        );
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw AuthenticationException('Registration failed: $errorMessage');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Registration request failed: $e');
    }
  }

  /// Logout user and invalidate tokens
  Future<void> logout() async {
    try {
      // Attempt to notify server about logout
      await post('/auth/logout').catchError((_) {
        // Ignore logout API errors - clear local tokens anyway
      });

      // Clear local tokens regardless of API response
      await _secureStorage.deleteTokens();
    } catch (e) {
      // Always clear local tokens even if API call fails
      await _secureStorage.deleteTokens();
      throw ApiException('Logout failed: $e');
    }
  }

  /// Request password reset
  Future<void> requestPasswordReset(String email) async {
    try {
      final response = await postPublic(
        '/auth/forgot-password',
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        return; // Success
      } else if (response.statusCode == 404) {
        throw ValidationException('Email address not found');
      } else if (response.statusCode == 429) {
        throw RateLimitException(
          'Too many password reset requests - please try again later',
        );
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw ApiException('Password reset failed: $errorMessage');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Password reset request failed: $e');
    }
  }

  /// Refresh access token
  Future<AuthResponse> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        throw AuthenticationException('No refresh token available');
      }

      final response = await postPublic(
        '/auth/refresh',
        body: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        await _secureStorage.saveAuthTokens(authResponse);
        return authResponse;
      } else if (response.statusCode == 401) {
        await _secureStorage.deleteTokens();
        throw AuthenticationException(
          'Refresh token expired - please login again',
        );
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw AuthenticationException('Token refresh failed: $errorMessage');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Token refresh failed: $e');
    }
  }

  /// ==================== USER PROFILE ENDPOINTS ====================

  /// Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await get('/user/profile');
      return json.decode(response.body);
    } catch (e) {
      throw ApiException('Failed to get user profile: $e');
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await put('/user/profile', body: profileData);
      return json.decode(response.body);
    } catch (e) {
      throw ApiException('Failed to update profile: $e');
    }
  }

  /// ==================== VIN DECODING ENDPOINTS ====================

  /// Decode VIN number
  Future<Map<String, dynamic>> decodeVin(String vin) async {
    try {
      final response = await post('/vehicle/decode', body: {'vin': vin});
      return json.decode(response.body);
    } catch (e) {
      throw ApiException('Failed to decode VIN: $e');
    }
  }

  /// Search vehicle parts
  Future<Map<String, dynamic>> searchParts({
    required String vin,
    String? partName,
    String? partNumber,
  }) async {
    try {
      final response = await post(
        '/vehicle/parts/search',
        body: {
          'vin': vin,
          if (partName != null) 'partName': partName,
          if (partNumber != null) 'partNumber': partNumber,
        },
      );
      return json.decode(response.body);
    } catch (e) {
      throw ApiException('Failed to search parts: $e');
    }
  }

  /// ==================== UTILITY METHODS ====================

  /// Check API health
  Future<bool> isApiHealthy() async {
    try {
      final url = Uri.parse('$baseUrl/health');
      final response = await _client
          .get(url, headers: _baseHeaders)
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get API version information
  Future<Map<String, dynamic>?> getApiVersion() async {
    try {
      final url = Uri.parse('$baseUrl/version');
      final response = await _client
          .get(url, headers: _baseHeaders)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clean up resources
  void dispose() {
    _client.close();
  }
}

/// ==================== CUSTOM EXCEPTIONS ====================

/// Base API exception
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

/// Authentication-related exceptions
class AuthenticationException extends ApiException {
  const AuthenticationException(super.message);
}

/// Token expired exception
class TokenExpiredException extends AuthenticationException {
  const TokenExpiredException(super.message);
}

/// Validation error exception
class ValidationException extends ApiException {
  const ValidationException(super.message);
}

/// Rate limiting exception
class RateLimitException extends ApiException {
  const RateLimitException(super.message);
}

/// Network connectivity exception
class NetworkException extends ApiException {
  const NetworkException(super.message);
}
