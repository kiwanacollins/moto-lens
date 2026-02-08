import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle/vin_scan_entry.dart';
import '../models/vehicle/vin_decode_result.dart';
import 'connectivity_service.dart';
import 'offline_cache_service.dart';
import 'sync_queue_service.dart';

/// VIN History Service for German Car Medic
///
/// Manages local scan history with offline caching support.
/// Stores recent VIN scans in SharedPreferences for quick re-access.
/// Integrates with [SyncQueueService] to queue offline VIN decodes.
class VinHistoryService {
  static const String _historyKey = 'gcm_vin_scan_history';
  static const int _maxHistoryEntries = 50;

  final ConnectivityService _connectivity = ConnectivityService();
  final OfflineCacheService _offlineCache = OfflineCacheService();
  final SyncQueueService _syncQueue = SyncQueueService();

  /// Get all scan history entries, newest first
  Future<List<VinScanEntry>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      if (historyJson == null) return [];

      final List<dynamic> decoded = json.decode(historyJson);
      final entries = decoded
          .map((e) => VinScanEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      // Sort newest first
      entries.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
      return entries;
    } catch (e) {
      return [];
    }
  }

  /// Add a scan entry to history
  Future<void> addEntry(VinScanEntry entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entries = await getHistory();

      // Remove duplicate VINs (keep newest)
      entries.removeWhere((e) => e.vin == entry.vin);

      // Add new entry at the beginning
      entries.insert(0, entry);

      // Trim to max entries
      final trimmed = entries.take(_maxHistoryEntries).toList();

      await prefs.setString(
        _historyKey,
        json.encode(trimmed.map((e) => e.toJson()).toList()),
      );
    } catch (_) {
      // Silently fail - history is non-critical
    }
  }

  /// Add a decode result to history
  Future<void> addDecodeResult(VinDecodeResult result) async {
    try {
      final entry = VinScanEntry(
        vin: result.vin,
        manufacturer: result.manufacturer,
        model: result.model,
        year: result.year,
        scannedAt: DateTime.now(),
        isSynced: _connectivity.isOnline,
      );
      await addEntry(entry);

      // Also persist in offline cache for richer data access
      await _offlineCache.cacheVehicleData(result.vin, result.toJson());
    } catch (_) {
      // Silently fail - history is non-critical
    }
  }

  /// Add a VIN scan that happened while offline (not yet decoded).
  ///
  /// Queues the VIN for server-side decode when connectivity returns.
  Future<void> addOfflineScan(String vin) async {
    final entry = VinScanEntry(
      vin: vin,
      scannedAt: DateTime.now(),
      isSynced: false,
    );
    await addEntry(entry);

    // Queue for server sync
    await _syncQueue.enqueue(
      operationType: 'vin_decode',
      payload: {'vin': vin},
    );
  }

  /// Mark a VIN entry as synced (called after successful server decode).
  Future<void> markSynced(String vin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entries = await getHistory();

      final idx = entries.indexWhere((e) => e.vin == vin);
      if (idx == -1) return;

      final old = entries[idx];
      entries[idx] = VinScanEntry(
        vin: old.vin,
        manufacturer: old.manufacturer,
        model: old.model,
        year: old.year,
        scannedAt: old.scannedAt,
        isSynced: true,
      );

      await prefs.setString(
        _historyKey,
        json.encode(entries.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  /// Get unsynced entries (for display / badge count).
  Future<List<VinScanEntry>> getUnsyncedEntries() async {
    final entries = await getHistory();
    return entries.where((e) => !e.isSynced).toList();
  }

  /// Remove a specific entry from history
  Future<void> removeEntry(String vin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entries = await getHistory();
      entries.removeWhere((e) => e.vin == vin);

      await prefs.setString(
        _historyKey,
        json.encode(entries.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  /// Clear all history
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (_) {}
  }

  /// Get cached decode result for a VIN (if available)
  ///
  /// Checks both the per-VIN SharedPreferences cache and the
  /// [OfflineCacheService] for richer cached data.
  Future<VinDecodeResult?> getCachedResult(String vin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'gcm_vin_cache_$vin';
      final cachedJson = prefs.getString(cacheKey);
      if (cachedJson != null) {
        return VinDecodeResult.fromCache(
          json.decode(cachedJson) as Map<String, dynamic>,
        );
      }

      // Fallback to offline cache
      final offlineData = _connectivity.isOnline
          ? await _offlineCache.getCachedVehicleData(vin)
          : await _offlineCache.getStaleCachedVehicleData(vin);
      if (offlineData != null) {
        return VinDecodeResult.fromCache(offlineData);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cache a decode result locally (both legacy key and offline cache).
  Future<void> cacheResult(VinDecodeResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'gcm_vin_cache_${result.vin}';
      await prefs.setString(cacheKey, json.encode(result.toJson()));

      // Also cache in offline cache with TTL
      await _offlineCache.cacheVehicleData(result.vin, result.toJson());
    } catch (_) {}
  }
}
