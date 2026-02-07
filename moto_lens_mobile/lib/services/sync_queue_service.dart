import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';

/// Queues failed write-operations for automatic retry when connectivity returns.
///
/// Persists the queue in [SharedPreferences] so pending operations survive
/// app restarts. Listens to [ConnectivityService.onStatusChange] and
/// flushes the queue as soon as the device comes back online.
class SyncQueueService {
  static final SyncQueueService _instance = SyncQueueService._internal();
  factory SyncQueueService() => _instance;
  SyncQueueService._internal();

  static const String _queueKey = 'gcm_sync_queue';

  final ConnectivityService _connectivity = ConnectivityService();
  StreamSubscription<bool>? _connectivitySub;
  bool _isFlushing = false;

  /// Callback table: callers register a handler for each operation type.
  final Map<String, Future<bool> Function(Map<String, dynamic> payload)>
  _handlers = {};

  /// Number of pending operations.
  int _pendingCount = 0;
  int get pendingCount => _pendingCount;

  final _pendingController = StreamController<int>.broadcast();

  /// Stream that emits the current pending-operation count.
  Stream<int> get onPendingCountChange => _pendingController.stream;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Initialise: load persisted queue length and subscribe to connectivity.
  Future<void> initialize() async {
    final queue = await _loadQueue();
    _pendingCount = queue.length;
    _pendingController.add(_pendingCount);

    _connectivitySub = _connectivity.onStatusChange.listen((online) {
      if (online) flush();
    });
  }

  /// Register a handler for an operation type (e.g. `'vin_decode'`).
  ///
  /// The handler receives the queued payload and must return `true` if the
  /// server accepted the operation, or `false` / throw to leave it queued.
  void registerHandler(
    String operationType,
    Future<bool> Function(Map<String, dynamic> payload) handler,
  ) {
    _handlers[operationType] = handler;
  }

  /// Clean up resources.
  void dispose() {
    _connectivitySub?.cancel();
    _pendingController.close();
  }

  // ---------------------------------------------------------------------------
  // Enqueue
  // ---------------------------------------------------------------------------

  /// Add an operation to the queue. It will be retried when online.
  Future<void> enqueue({
    required String operationType,
    required Map<String, dynamic> payload,
  }) async {
    final queue = await _loadQueue();
    queue.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': operationType,
      'payload': payload,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _saveQueue(queue);
    _pendingCount = queue.length;
    _pendingController.add(_pendingCount);
    debugPrint(
      '[SyncQueueService] enqueued $operationType (${queue.length} pending)',
    );
  }

  // ---------------------------------------------------------------------------
  // Flush
  // ---------------------------------------------------------------------------

  /// Attempt to process all queued operations.
  ///
  /// Returns the number of operations that were successfully processed.
  Future<int> flush() async {
    if (_isFlushing) return 0;
    if (!_connectivity.isOnline) return 0;

    _isFlushing = true;
    int processed = 0;

    try {
      final queue = await _loadQueue();
      if (queue.isEmpty) return 0;

      debugPrint(
        '[SyncQueueService] flushing ${queue.length} pending operations…',
      );
      final remaining = <Map<String, dynamic>>[];

      for (final item in queue) {
        final type = item['type'] as String;
        final payload = item['payload'] as Map<String, dynamic>;
        final handler = _handlers[type];

        if (handler == null) {
          debugPrint('[SyncQueueService] no handler for "$type", skipping');
          remaining.add(item);
          continue;
        }

        try {
          final ok = await handler(payload);
          if (ok) {
            processed++;
          } else {
            remaining.add(item);
          }
        } catch (e) {
          debugPrint('[SyncQueueService] handler for "$type" threw: $e');
          remaining.add(item);
        }
      }

      await _saveQueue(remaining);
      _pendingCount = remaining.length;
      _pendingController.add(_pendingCount);

      debugPrint(
        '[SyncQueueService] flush done — processed $processed, '
        '${remaining.length} remaining',
      );
    } finally {
      _isFlushing = false;
    }

    return processed;
  }

  /// Clear the entire queue (e.g. on logout).
  Future<void> clearQueue() async {
    await _saveQueue([]);
    _pendingCount = 0;
    _pendingController.add(0);
  }

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> _loadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_queueKey);
      if (raw == null) return [];
      final list = json.decode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[SyncQueueService] _loadQueue failed: $e');
      return [];
    }
  }

  Future<void> _saveQueue(List<Map<String, dynamic>> queue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_queueKey, json.encode(queue));
    } catch (e) {
      debugPrint('[SyncQueueService] _saveQueue failed: $e');
    }
  }
}
