import 'dart:convert';
import 'api_service.dart';

/// Service for TecDoc VIN-to-Parts API calls
class TecDocService {
  static final TecDocService _instance = TecDocService._internal();
  factory TecDocService() => _instance;
  TecDocService._internal();

  final ApiService _api = ApiService();

  /// Full VIN-to-Parts chain: resolves VIN → model → vehicle → parts
  Future<Map<String, dynamic>> vinToParts(String vin) async {
    final response = await _api.get('/tecdoc/vin-to-parts/$vin');
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

  /// Step 3: Get parts for a given vehicleId
  Future<Map<String, dynamic>> getVehicleParts(int vehicleId) async {
    final response = await _api.get('/tecdoc/vehicle-parts/$vehicleId');
    return json.decode(response.body);
  }
}
