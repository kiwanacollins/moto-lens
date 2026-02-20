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

  /// Search articles by part/article number.
  Future<List<TecDocArticle>> searchByArticleNumber(
    String articleNumber, {
    int? langId,
  }) async {
    final qs = langId != null ? '?langId=$langId' : '';
    final response = await _api.get(
      '/tecdoc/search/${Uri.encodeComponent(articleNumber)}$qs',
    );
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (body['success'] != true) {
      throw TecDocException(body['message'] as String? ?? 'Search failed');
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final articles = data['articles'];
      if (articles is List) {
        return articles
            .map((e) => TecDocArticle.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    if (data is List) {
      return data
          .map((e) => TecDocArticle.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Get article details (media + category) by article ID.
  Future<TecDocArticle> getArticleDetails(
    int articleId, {
    int? langId,
  }) async {
    final qs = langId != null ? '?langId=$langId' : '';
    final response = await _api.get('/tecdoc/article/$articleId$qs');
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (body['success'] != true) {
      throw TecDocException(
        body['message'] as String? ?? 'Failed to load article',
      );
    }

    // Parse media array
    List<TecDocMedia> mediaList = [];
    final mediaRaw = body['media'];
    if (mediaRaw is List) {
      mediaList = mediaRaw
          .map((e) => TecDocMedia.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (mediaRaw is Map<String, dynamic>) {
      final arr =
          mediaRaw['array'] ?? mediaRaw['media'] ?? mediaRaw.values.first;
      if (arr is List) {
        mediaList = arr
            .map((e) => TecDocMedia.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    // Parse category info
    String? categoryName;
    final catRaw = body['category'];
    if (catRaw is Map<String, dynamic>) {
      categoryName = catRaw['categoryName'] as String? ??
          catRaw['name'] as String?;
    } else if (catRaw is List && catRaw.isNotEmpty) {
      final first = catRaw.first;
      if (first is Map<String, dynamic>) {
        categoryName = first['categoryName'] as String? ??
            first['name'] as String?;
      }
    }

    return TecDocArticle(
      articleId: articleId,
      articleNumber: '',
      articleName: categoryName,
      images: mediaList,
      raw: body,
    );
  }
}

class TecDocException implements Exception {
  final String message;
  TecDocException(this.message);

  @override
  String toString() => 'TecDocException: $message';
}
