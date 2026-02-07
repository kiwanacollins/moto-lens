import 'dart:convert';
import 'api_service.dart';
import '../models/part_scan_entry.dart';

/// Service that communicates with the backend parts endpoints.
///
/// Singleton, wraps [ApiService]. Exposes part identification and
/// detail lookups triggered by QR code or manual part-number entry.
class PartsService {
  static final PartsService _instance = PartsService._internal();
  factory PartsService() => _instance;
  PartsService._internal();

  final ApiService _api = ApiService();

  /// Fetch full details for a part by name/number.
  ///
  /// Calls `POST /api/parts/details` with optional [vehicleData].
  Future<PartDetails> getPartDetails(
    String partName, {
    Map<String, dynamic>? vehicleData,
  }) async {
    final body = <String, dynamic>{'partName': partName};
    if (vehicleData != null) body['vehicleData'] = vehicleData;

    final response = await _api.post('/parts/details', body: body);
    final data = json.decode(response.body) as Map<String, dynamic>;

    if (data['success'] == true) {
      return PartDetails.fromJson(data);
    }

    throw PartsServiceException(
      data['message'] as String? ?? 'Failed to fetch part details',
    );
  }

  /// Identify a part by name and get brief information.
  ///
  /// Calls `POST /api/parts/identify`.
  Future<Map<String, dynamic>> identifyPart(
    String partName, {
    Map<String, dynamic>? vehicleData,
  }) async {
    final body = <String, dynamic>{'partName': partName};
    if (vehicleData != null) body['vehicleData'] = vehicleData;

    final response = await _api.post('/parts/identify', body: body);
    final data = json.decode(response.body) as Map<String, dynamic>;

    if (data['success'] == true) {
      return data;
    }

    throw PartsServiceException(
      data['message'] as String? ?? 'Failed to identify part',
    );
  }
}

/// Exception thrown when a parts API call fails.
class PartsServiceException implements Exception {
  final String message;
  const PartsServiceException(this.message);

  @override
  String toString() => 'PartsServiceException: $message';
}
