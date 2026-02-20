import 'dart:convert';
import '../models/tecdoc_models.dart';
import 'api_service.dart';

/// Service for TecDoc parts catalog API.
///
/// All calls go through the backend proxy at /api/tecdoc/*
/// which handles RapidAPI authentication and caching.
class TecDocService {
  static final TecDocService _instance = TecDocService._();
  factory TecDocService() => _instance;
  TecDocService._();

  final ApiService _api = ApiService();

  /// Decode a VIN and return TecDoc vehicle data.
  Future<TecDocVehicle> decodeVin(String vin) async {
    final response = await _api.get('/tecdoc/vin/$vin');
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (body['success'] != true) {
      throw TecDocException(body['message'] as String? ?? 'VIN decode failed');
    }

    final data = body['data'];
    if (data == null) {
      throw TecDocException('No vehicle data returned');
    }

    // API may return a single object or a list; handle both.
    if (data is List && data.isNotEmpty) {
      return TecDocVehicle.fromJson(
        (data.first as Map<String, dynamic>)..['vin'] = vin,
      );
    }
    if (data is Map<String, dynamic>) {
      return TecDocVehicle.fromJson(data..['vin'] = vin);
    }

    throw TecDocException('Unexpected VIN decode response format');
  }

  /// Get part categories for a decoded vehicle.
  Future<List<TecDocCategory>> getCategories({
    required int vehicleId,
    required int manufacturerId,
    int? langId,
    int? countryFilterId,
    int? typeId,
  }) async {
    final queryParts = <String>[];
    if (langId != null) queryParts.add('langId=$langId');
    if (countryFilterId != null) queryParts.add('countryFilterId=$countryFilterId');
    if (typeId != null) queryParts.add('typeId=$typeId');
    final qs = queryParts.isNotEmpty ? '?${queryParts.join('&')}' : '';

    final response = await _api.get('/tecdoc/categories/$vehicleId/$manufacturerId$qs');
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (body['success'] != true) {
      throw TecDocException(body['message'] as String? ?? 'Failed to load categories');
    }

    final data = body['data'];
    if (data is List) {
      return data
          .map((e) => TecDocCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      // Might be wrapped in a key
      final categories = data['categories'] ?? data['array'] ?? data.values.first;
      if (categories is List) {
        return categories
            .map((e) => TecDocCategory.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    return [];
  }

  /// Get full article (part) details + media.
  Future<TecDocArticle> getArticleDetails(int articleId, {int? langId, int? countryFilterId}) async {
    final queryParts = <String>[];
    if (langId != null) queryParts.add('langId=$langId');
    if (countryFilterId != null) queryParts.add('countryFilterId=$countryFilterId');
    final qs = queryParts.isNotEmpty ? '?${queryParts.join('&')}' : '';

    final response = await _api.get('/tecdoc/article/$articleId$qs');
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (body['success'] != true) {
      throw TecDocException(body['message'] as String? ?? 'Failed to load article');
    }

    final details = body['details'] ?? {};
    final mediaRaw = body['media'];

    List<TecDocMedia> mediaList = [];
    if (mediaRaw is List) {
      mediaList = mediaRaw
          .map((e) => TecDocMedia.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (mediaRaw is Map<String, dynamic>) {
      final arr = mediaRaw['array'] ?? mediaRaw['media'] ?? mediaRaw.values.first;
      if (arr is List) {
        mediaList = arr
            .map((e) => TecDocMedia.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    if (details is Map<String, dynamic>) {
      details['images'] = mediaList.map((m) => {'url': m.url, 'description': m.description, 'type': m.type}).toList();
      return TecDocArticle.fromJson(details);
    }
    if (details is List && details.isNotEmpty) {
      final map = details.first as Map<String, dynamic>;
      map['images'] = mediaList.map((m) => {'url': m.url, 'description': m.description, 'type': m.type}).toList();
      return TecDocArticle.fromJson(map);
    }

    throw TecDocException('Unexpected article response format');
  }

  /// Search articles by OEM / article number.
  Future<List<TecDocArticle>> searchByArticleNumber(String articleNumber, {int? langId}) async {
    final qs = langId != null ? '?langId=$langId' : '';
    final response = await _api.get('/tecdoc/search/${Uri.encodeComponent(articleNumber)}$qs');
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (body['success'] != true) {
      throw TecDocException(body['message'] as String? ?? 'Search failed');
    }

    final data = body['data'];
    if (data is List) {
      return data
          .map((e) => TecDocArticle.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}

class TecDocException implements Exception {
  final String message;
  TecDocException(this.message);

  @override
  String toString() => 'TecDocException: $message';
}
