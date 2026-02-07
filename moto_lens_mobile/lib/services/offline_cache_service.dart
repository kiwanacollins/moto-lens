import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized offline cache layer with TTL (time-to-live) support.
///
/// Wraps [SharedPreferences] with a consistent key-prefix scheme and
/// automatic expiry. Used for vehicle data, part details, and other
/// API responses that should survive network outages.
class OfflineCacheService {
  static final OfflineCacheService _instance = OfflineCacheService._internal();
  factory OfflineCacheService() => _instance;
  OfflineCacheService._internal();

  /// All cache keys start with this prefix so they can be listed/cleared.
  static const String _prefix = 'gcm_offline_';

  /// Default TTL: 7 days.
  static const Duration defaultTtl = Duration(days: 7);

  // ---------------------------------------------------------------------------
  // Generic cache operations
  // ---------------------------------------------------------------------------

  /// Store a JSON-serializable [value] under [key] with an optional [ttl].
  Future<void> put(
    String key,
    Map<String, dynamic> value, {
    Duration ttl = defaultTtl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wrapper = {
        'data': value,
        'cachedAt': DateTime.now().toIso8601String(),
        'expiresAt': DateTime.now().add(ttl).toIso8601String(),
      };
      await prefs.setString('$_prefix$key', json.encode(wrapper));
    } catch (e) {
      debugPrint('[OfflineCacheService] put($key) failed: $e');
    }
  }

  /// Retrieve a cached value, or `null` if missing / expired.
  Future<Map<String, dynamic>?> get(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefix$key');
      if (raw == null) return null;

      final wrapper = json.decode(raw) as Map<String, dynamic>;
      final expiresAt = DateTime.parse(wrapper['expiresAt'] as String);

      if (DateTime.now().isAfter(expiresAt)) {
        // Expired — remove silently
        await prefs.remove('$_prefix$key');
        return null;
      }

      return wrapper['data'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[OfflineCacheService] get($key) failed: $e');
      return null;
    }
  }

  /// Retrieve a cached value even if expired (useful in offline mode).
  Future<Map<String, dynamic>?> getStale(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefix$key');
      if (raw == null) return null;

      final wrapper = json.decode(raw) as Map<String, dynamic>;
      return wrapper['data'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[OfflineCacheService] getStale($key) failed: $e');
      return null;
    }
  }

  /// Remove a specific cached entry.
  Future<void> remove(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefix$key');
    } catch (e) {
      debugPrint('[OfflineCacheService] remove($key) failed: $e');
    }
  }

  /// Clear all entries managed by this service.
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
      for (final k in keys) {
        await prefs.remove(k);
      }
      debugPrint('[OfflineCacheService] cleared ${keys.length} cached entries');
    } catch (e) {
      debugPrint('[OfflineCacheService] clearAll failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Domain-specific convenience methods
  // ---------------------------------------------------------------------------

  /// Cache a part detail response.
  Future<void> cachePartDetails(
    String partKey,
    Map<String, dynamic> details,
  ) async {
    await put('part_$partKey', details);
  }

  /// Retrieve a cached part detail response.
  Future<Map<String, dynamic>?> getCachedPartDetails(String partKey) async {
    return get('part_$partKey');
  }

  /// Retrieve a cached part detail response even if expired (offline mode).
  Future<Map<String, dynamic>?> getStaleCachedPartDetails(
    String partKey,
  ) async {
    return getStale('part_$partKey');
  }

  /// Cache a vehicle decode response.
  Future<void> cacheVehicleData(String vin, Map<String, dynamic> data) async {
    await put('vehicle_$vin', data, ttl: const Duration(days: 30));
  }

  /// Retrieve cached vehicle decode response.
  Future<Map<String, dynamic>?> getCachedVehicleData(String vin) async {
    return get('vehicle_$vin');
  }

  /// Retrieve cached vehicle data even if expired (offline mode).
  Future<Map<String, dynamic>?> getStaleCachedVehicleData(String vin) async {
    return getStale('vehicle_$vin');
  }
}
