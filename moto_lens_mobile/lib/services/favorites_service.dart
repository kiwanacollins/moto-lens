import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle/vin_decode_result.dart';

/// Service for managing favorite/bookmarked vehicles
///
/// Stores favorite VINs and their basic information locally
/// for quick access and offline availability.
class FavoritesService {
  static const String _favoritesKey = 'favorite_vehicles';
  static const String _favoriteVinsKey = 'favorite_vins';

  final SharedPreferences _prefs;

  FavoritesService(this._prefs);

  /// Check if a VIN is favorited
  Future<bool> isFavorite(String vin) async {
    final favoriteVins = _prefs.getStringList(_favoriteVinsKey) ?? [];
    return favoriteVins.contains(vin);
  }

  /// Add a vehicle to favorites
  Future<void> addFavorite(VinDecodeResult vehicle) async {
    try {
      // Add to favorite VINs list
      final favoriteVins = _prefs.getStringList(_favoriteVinsKey) ?? [];
      if (!favoriteVins.contains(vehicle.vin)) {
        favoriteVins.add(vehicle.vin);
        await _prefs.setStringList(_favoriteVinsKey, favoriteVins);
      }

      // Cache the vehicle data
      final favoritesJson = _prefs.getString(_favoritesKey);
      final favorites = <String, dynamic>{};

      if (favoritesJson != null && favoritesJson.isNotEmpty) {
        // Parse existing favorites (stored as JSON string)
        try {
          // Simple key-value storage: VIN -> vehicle JSON
          final List<String> favoritesList = _prefs.getStringList('${_favoritesKey}_list') ?? [];
          for (final vin in favoritesList) {
            final vehicleJson = _prefs.getString('${_favoritesKey}_$vin');
            if (vehicleJson != null) {
              favorites[vin] = vehicleJson;
            }
          }
        } catch (_) {
          // Ignore parse errors
        }
      }

      // Store the new favorite
      await _prefs.setString(
        '${_favoritesKey}_${vehicle.vin}',
        _vehicleToJsonString(vehicle),
      );

      // Update the list
      final favoritesList = _prefs.getStringList('${_favoritesKey}_list') ?? [];
      if (!favoritesList.contains(vehicle.vin)) {
        favoritesList.add(vehicle.vin);
        await _prefs.setStringList('${_favoritesKey}_list', favoritesList);
      }
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  /// Remove a vehicle from favorites
  Future<void> removeFavorite(String vin) async {
    try {
      // Remove from favorite VINs list
      final favoriteVins = _prefs.getStringList(_favoriteVinsKey) ?? [];
      favoriteVins.remove(vin);
      await _prefs.setStringList(_favoriteVinsKey, favoriteVins);

      // Remove cached vehicle data
      await _prefs.remove('${_favoritesKey}_$vin');

      // Update the list
      final favoritesList = _prefs.getStringList('${_favoritesKey}_list') ?? [];
      favoritesList.remove(vin);
      await _prefs.setStringList('${_favoritesKey}_list', favoritesList);
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  /// Get all favorite vehicles
  Future<List<VinDecodeResult>> getFavorites() async {
    final favorites = <VinDecodeResult>[];
    final favoritesList = _prefs.getStringList('${_favoritesKey}_list') ?? [];

    for (final vin in favoritesList) {
      final vehicleJson = _prefs.getString('${_favoritesKey}_$vin');
      if (vehicleJson != null) {
        try {
          final vehicle = _vehicleFromJsonString(vehicleJson);
          favorites.add(vehicle);
        } catch (e) {
          // Skip invalid entries
          continue;
        }
      }
    }

    // Sort by most recently added (last in list is most recent)
    return favorites.reversed.toList();
  }

  /// Get favorite count
  Future<int> getFavoritesCount() async {
    final favoriteVins = _prefs.getStringList(_favoriteVinsKey) ?? [];
    return favoriteVins.length;
  }

  /// Clear all favorites
  Future<void> clearAllFavorites() async {
    final favoritesList = _prefs.getStringList('${_favoritesKey}_list') ?? [];

    // Remove all individual vehicle entries
    for (final vin in favoritesList) {
      await _prefs.remove('${_favoritesKey}_$vin');
    }

    // Clear the lists
    await _prefs.remove(_favoriteVinsKey);
    await _prefs.remove('${_favoritesKey}_list');
  }

  /// Convert vehicle to JSON string for storage
  String _vehicleToJsonString(VinDecodeResult vehicle) {
    final json = vehicle.toJson();
    // Simple string representation
    return '${json['vin']}|${json['manufacturer']}|${json['model']}|${json['year']}|'
        '${json['bodyStyle']}|${json['engineType']}|${json['transmission']}|'
        '${json['driveType']}|${json['fuelType']}|${json['displacement']}|'
        '${json['power']}|${json['countryOfOrigin']}|${json['plantCity']}|'
        '${json['series']}|${json['trim']}|${json['decodedAt']}';
  }

  /// Parse vehicle from JSON string
  VinDecodeResult _vehicleFromJsonString(String jsonString) {
    final parts = jsonString.split('|');

    return VinDecodeResult(
      vin: parts[0],
      manufacturer: parts[1].isNotEmpty ? parts[1] : null,
      model: parts[2].isNotEmpty ? parts[2] : null,
      year: parts[3].isNotEmpty ? parts[3] : null,
      bodyStyle: parts[4].isNotEmpty ? parts[4] : null,
      engineType: parts[5].isNotEmpty ? parts[5] : null,
      transmission: parts[6].isNotEmpty ? parts[6] : null,
      driveType: parts[7].isNotEmpty ? parts[7] : null,
      fuelType: parts[8].isNotEmpty ? parts[8] : null,
      displacement: parts[9].isNotEmpty ? parts[9] : null,
      power: parts[10].isNotEmpty ? parts[10] : null,
      countryOfOrigin: parts[11].isNotEmpty ? parts[11] : null,
      plantCity: parts[12].isNotEmpty ? parts[12] : null,
      series: parts[13].isNotEmpty ? parts[13] : null,
      trim: parts[14].isNotEmpty ? parts[14] : null,
      decodedAt: DateTime.tryParse(parts[15]) ?? DateTime.now(),
    );
  }
}
