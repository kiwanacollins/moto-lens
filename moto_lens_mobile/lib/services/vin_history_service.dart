import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle/vin_scan_entry.dart';
import '../models/vehicle/vin_decode_result.dart';

/// VIN History Service for German Car Medic
///
/// Manages local scan history with offline caching support.
/// Stores recent VIN scans in SharedPreferences for quick re-access.
class VinHistoryService {
  static const String _historyKey = 'gcm_vin_scan_history';
  static const int _maxHistoryEntries = 50;

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
    final entry = VinScanEntry(
      vin: result.vin,
      manufacturer: result.manufacturer,
      model: result.model,
      year: result.year,
      scannedAt: DateTime.now(),
      isSynced: true,
    );
    await addEntry(entry);
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
  Future<VinDecodeResult?> getCachedResult(String vin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'gcm_vin_cache_$vin';
      final cachedJson = prefs.getString(cacheKey);
      if (cachedJson == null) return null;

      return VinDecodeResult.fromCache(
        json.decode(cachedJson) as Map<String, dynamic>,
      );
    } catch (e) {
      return null;
    }
  }

  /// Cache a decode result locally
  Future<void> cacheResult(VinDecodeResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'gcm_vin_cache_${result.vin}';
      await prefs.setString(cacheKey, json.encode(result.toJson()));
    } catch (_) {}
  }
}
