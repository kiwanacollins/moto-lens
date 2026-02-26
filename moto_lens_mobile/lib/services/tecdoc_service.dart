import 'dart:convert';
import 'api_service.dart';

/// Longer timeout for TecDoc catalog calls (backend waits up to 45s for TecDoc API)
const _tecdocTimeout = Duration(seconds: 60);

/// Service for TecDoc VIN-to-Parts API calls
class TecDocService {
  static final TecDocService _instance = TecDocService._internal();
  factory TecDocService() => _instance;
  TecDocService._internal();

  final ApiService _api = ApiService();

  /// Full VIN-to-Parts chain: resolves VIN → model → vehicle → parts
  Future<Map<String, dynamic>> vinToParts(String vin) async {
    final response = await _api.get(
      '/tecdoc/vin-to-parts/$vin',
      customTimeout: _tecdocTimeout,
    );
    return json.decode(response.body);
  }

  /// Step 1: Decode VIN via TecDoc to get modelId
  Future<Map<String, dynamic>> decodeVin(String vin) async {
    final response = await _api.get('/tecdoc/vin/decode/$vin');
    return json.decode(response.body);
  }

  /// Step 2: Get model types for a given modelId
  Future<Map<String, dynamic>> getModelTypes(int modelId) async {
    final response = await _api.get('/tecdoc/model-types/$modelId');
    return json.decode(response.body);
  }

  /// Step 3: Search parts for a given vehicleId by keyword
  Future<Map<String, dynamic>> searchVehicleParts(
    int vehicleId,
    String query,
  ) async {
    final encoded = Uri.encodeQueryComponent(query);
    final response = await _api.get(
      '/tecdoc/vehicle-parts/$vehicleId?q=$encoded',
      customTimeout: _tecdocTimeout,
    );
    return json.decode(response.body);
  }

  /// Fetch a brief AI-generated description for a part category
  Future<String?> getPartDescription({
    required String partName,
    String? make,
    String? model,
    String? year,
  }) async {
    try {
      final params = <String, String>{
        'partName': partName,
        if (make != null) 'make': make,
        if (model != null) 'model': model,
        if (year != null) 'year': year,
      };
      final query = params.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');
      final response = await _api.get('/tecdoc/part-description?$query');
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['description'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Fetch a part image via SerpAPI (uses existing /parts/images endpoint)
  Future<String?> getPartImage({
    required String partName,
    String? make,
    String? model,
    String? year,
  }) async {
    try {
      final params = <String, String>{
        'partName': partName,
        if (make != null) 'make': make,
        if (model != null) 'model': model,
        if (year != null) 'year': year,
      };
      final query = params.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');
      final response = await _api.get('/parts/images?$query');
      final data = json.decode(response.body);
      final images = data['images'] as List<dynamic>?;
      if (images != null && images.isNotEmpty) {
        return (images[0]['thumbnail'] ?? images[0]['imageUrl']) as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
