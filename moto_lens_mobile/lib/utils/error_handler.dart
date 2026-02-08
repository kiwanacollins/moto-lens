import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

/// User-friendly error handler for German Car Medic
///
/// Translates technical errors into clear, actionable messages
/// that users can understand and respond to.
class ErrorHandler {
  /// Convert any exception to a user-friendly message
  static String getUserFriendlyMessage(dynamic error) {
    // Handle specific exception types
    if (error is SocketException) {
      return _handleSocketException(error);
    }

    if (error is HttpException) {
      return _handleHttpException(error);
    }

    if (error is TimeoutException) {
      return 'Connection timeout. Please check your internet connection and try again.';
    }

    if (error is HandshakeException) {
      return _handleHandshakeException(error);
    }

    if (error is FormatException) {
      return 'Unable to process server response. Please try again or contact support if the problem persists.';
    }

    if (error is http.ClientException) {
      return 'Connection failed. Please check your internet connection and try again.';
    }

    // Handle custom API exceptions
    if (error is AuthenticationException) {
      return _handleAuthenticationException(error);
    }

    if (error is ValidationException) {
      return error.message;
    }

    if (error is RateLimitException) {
      return 'Too many requests. Please wait a moment and try again.';
    }

    if (error is NetworkException) {
      return 'Network error. Please check your internet connection and try again.';
    }

    if (error is ApiException) {
      return _handleApiException(error);
    }

    // Handle TypeError (e.g. unexpected type in JSON parsing)
    if (error is TypeError) {
      return 'Unable to process vehicle data. Please try again.';
    }

    // Handle error strings
    if (error is String) {
      return _handleErrorString(error);
    }

    // Fallback for unknown errors
    return 'Something went wrong. Please try again.';
  }

  /// Handle socket exceptions (network connectivity issues)
  static String _handleSocketException(SocketException error) {
    if (error.osError != null) {
      final errorCode = error.osError!.errorCode;
      final errorMessage = error.osError!.message.toLowerCase();

      // Network unreachable
      if (errorMessage.contains('network is unreachable') || errorCode == 7) {
        return 'No internet connection. Please check your network settings and try again.';
      }

      // Connection refused
      if (errorMessage.contains('connection refused') || errorCode == 61) {
        return 'Cannot reach server. Please try again in a few moments.';
      }

      // Host not found
      if (errorMessage.contains('nodename nor servname provided') ||
          errorMessage.contains('no address associated')) {
        return 'Cannot find server. Please check your internet connection.';
      }

      // Operation timed out
      if (errorMessage.contains('operation timed out') || errorCode == 60) {
        return 'Connection timeout. Please check your internet connection and try again.';
      }
    }

    // Generic socket error
    return 'Connection error. Please check your internet connection and try again.';
  }

  /// Handle HTTP exceptions
  static String _handleHttpException(HttpException error) {
    final message = error.message.toLowerCase();

    if (message.contains('connection closed')) {
      return 'Connection was lost. Please try again.';
    }

    if (message.contains('connection terminated')) {
      return 'Connection was interrupted. Please try again.';
    }

    return 'Network error occurred. Please try again.';
  }

  /// Handle SSL/TLS handshake exceptions
  static String _handleHandshakeException(HandshakeException error) {
    final message = error.message.toLowerCase();

    // Common SSL/TLS errors
    if (message.contains('certificate') || message.contains('cert')) {
      return 'Secure connection error. Please check your internet connection or try again later.';
    }

    if (message.contains('tlsv1') ||
        message.contains('tls') ||
        message.contains('ssl')) {
      return 'Could not establish secure connection. Please check your network settings and try again.';
    }

    if (message.contains('handshake')) {
      return 'Connection security check failed. Please try again or check your network settings.';
    }

    return 'Could not establish secure connection. Please check your internet connection.';
  }

  /// Handle authentication exceptions
  static String _handleAuthenticationException(AuthenticationException error) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid') && message.contains('password')) {
      return 'Incorrect email or password. Please try again.';
    }

    if (message.contains('expired')) {
      return 'Your session has expired. Please login again.';
    }

    if (message.contains('not found') || message.contains('404')) {
      return 'Account not found. Please check your email address.';
    }

    // Return the original message if it's already user-friendly
    return error.message;
  }

  /// Handle API exceptions
  static String _handleApiException(ApiException error) {
    final message = error.message.toLowerCase();

    // Extract user-friendly parts from technical messages
    if (message.contains('failed:') || message.contains('error:')) {
      // Try to extract the actual error after the colon
      final parts = message.split(':');
      if (parts.length > 1) {
        final actualError = parts.last.trim();
        return getUserFriendlyMessage(actualError);
      }
    }

    // Check for specific error patterns
    if (message.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (message.contains('connection')) {
      return 'Connection error. Please check your internet connection.';
    }

    if (message.contains('404')) {
      return 'The requested information was not found.';
    }

    if (message.contains('500') || message.contains('server error')) {
      return 'Server error. Please try again in a few moments.';
    }

    if (message.contains('503')) {
      return 'Service temporarily unavailable. Please try again shortly.';
    }

    // Return simplified message
    return 'Unable to complete request. Please try again.';
  }

  /// Handle error strings
  static String _handleErrorString(String error) {
    final message = error.toLowerCase();

    // Network-related errors
    if (message.contains('socketexception') ||
        message.contains('socket exception')) {
      return 'Connection error. Please check your internet connection.';
    }

    if (message.contains('handshakeexception') ||
        message.contains('handshake exception') ||
        message.contains('tlsv1') ||
        message.contains('tls_record') ||
        message.contains('ssl')) {
      return 'Could not establish secure connection. Please check your internet connection and try again.';
    }

    if (message.contains('timeoutexception') ||
        message.contains('timeout exception') ||
        message.contains('timed out')) {
      return 'Connection timeout. Please try again.';
    }

    if (message.contains('formatexception') ||
        message.contains('format exception')) {
      return 'Unable to process response. Please try again.';
    }

    // Authentication errors
    if (message.contains('unauthorized') || message.contains('401')) {
      return 'Authentication failed. Please login again.';
    }

    if (message.contains('forbidden') || message.contains('403')) {
      return 'You don\'t have permission to access this resource.';
    }

    // If the message looks technical, provide generic message
    if (message.contains('exception') ||
        message.contains('error:') ||
        message.contains('failed:')) {
      return 'Something went wrong. Please try again.';
    }

    // If it looks like a clean message already, return it
    return error;
  }

  /// Get a helpful suggestion based on the error type
  static String? getSuggestion(dynamic error) {
    if (error is SocketException ||
        error is HandshakeException ||
        error is TimeoutException) {
      return 'Try:\n• Checking your internet connection\n• Switching between WiFi and mobile data\n• Restarting the app';
    }

    if (error is AuthenticationException) {
      return 'Try:\n• Checking your email and password\n• Resetting your password if needed\n• Contacting support if the problem persists';
    }

    if (error is RateLimitException) {
      return 'Please wait a few minutes before trying again.';
    }

    return null;
  }

  /// Check if error is network-related
  static bool isNetworkError(dynamic error) {
    return error is SocketException ||
        error is HttpException ||
        error is TimeoutException ||
        error is HandshakeException ||
        error is http.ClientException ||
        (error is String &&
            (error.toLowerCase().contains('socket') ||
                error.toLowerCase().contains('network') ||
                error.toLowerCase().contains('timeout') ||
                error.toLowerCase().contains('handshake') ||
                error.toLowerCase().contains('connection')));
  }

  /// Check if error is authentication-related
  static bool isAuthError(dynamic error) {
    return error is AuthenticationException ||
        (error is String &&
            (error.toLowerCase().contains('unauthorized') ||
                error.toLowerCase().contains('authentication') ||
                error.toLowerCase().contains('expired') ||
                error.toLowerCase().contains('401')));
  }

  /// Check if error requires retry
  static bool shouldRetry(dynamic error) {
    return isNetworkError(error) ||
        error is TimeoutException ||
        (error is ApiException &&
            (error.message.contains('500') ||
                error.message.contains('503') ||
                error.message.contains('timeout')));
  }
}
