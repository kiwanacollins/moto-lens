import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Proactive connectivity monitoring for offline support.
///
/// Wraps `connectivity_plus` and exposes a simple [isOnline] getter
/// plus a broadcast [onStatusChange] stream so the rest of the app
/// can react to network transitions without polling.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  bool _isOnline = true;
  bool _initialized = false;

  final _controller = StreamController<bool>.broadcast();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Whether the device currently has a network connection.
  bool get isOnline => _isOnline;

  /// Stream that fires whenever connectivity flips between online/offline.
  Stream<bool> get onStatusChange => _controller.stream;

  /// Initialise the service; call once at app startup.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Check current state
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    // Listen to changes
    _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  /// Perform a one-off connectivity check and update internal state.
  Future<bool> checkNow() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);
    return _isOnline;
  }

  /// Clean up resources.
  void dispose() {
    _controller.close();
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  void _updateStatus(List<ConnectivityResult> results) {
    final online =
        results.isNotEmpty &&
        !results.every((r) => r == ConnectivityResult.none);

    if (online != _isOnline) {
      _isOnline = online;
      _controller.add(_isOnline);
      debugPrint(
        '[ConnectivityService] status → ${_isOnline ? "ONLINE" : "OFFLINE"}',
      );
    }
  }
}
