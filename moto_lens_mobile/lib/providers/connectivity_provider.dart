import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/connectivity_service.dart';
import '../services/sync_queue_service.dart';

/// Exposes connectivity state and sync-queue status to the widget tree.
///
/// Wraps [ConnectivityService] and [SyncQueueService] so any widget
/// can use `context.watch<ConnectivityProvider>()` to react to
/// online/offline transitions and pending-sync counts.
class ConnectivityProvider extends ChangeNotifier {
  final ConnectivityService _connectivity = ConnectivityService();
  final SyncQueueService _syncQueue = SyncQueueService();

  StreamSubscription<bool>? _statusSub;
  StreamSubscription<int>? _pendingSub;

  bool _isOnline = true;
  int _pendingSyncCount = 0;
  bool _isSyncing = false;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// Whether the device currently has a network connection.
  bool get isOnline => _isOnline;

  /// Number of queued operations waiting to sync.
  int get pendingSyncCount => _pendingSyncCount;

  /// Whether the queue is actively flushing.
  bool get isSyncing => _isSyncing;

  /// True when offline **or** when there are pending sync items.
  bool get showBanner => !_isOnline || _isSyncing;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Call once at app startup (after ConnectivityService.initialize()).
  Future<void> initialize() async {
    _isOnline = _connectivity.isOnline;
    _pendingSyncCount = _syncQueue.pendingCount;

    _statusSub = _connectivity.onStatusChange.listen((online) {
      _isOnline = online;

      if (online && _pendingSyncCount > 0) {
        _isSyncing = true;
        notifyListeners();
        // Flush happens automatically in SyncQueueService, but we track state.
        _syncQueue.flush().then((_) {
          _isSyncing = false;
          notifyListeners();
        });
      } else {
        notifyListeners();
      }
    });

    _pendingSub = _syncQueue.onPendingCountChange.listen((count) {
      _pendingSyncCount = count;
      if (count == 0) _isSyncing = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _pendingSub?.cancel();
    super.dispose();
  }
}
