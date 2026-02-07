import 'dart:convert';
import 'api_service.dart';
import '../models/vehicle_viewer.dart';

/// Service for fetching vehicle images and part details from the backend.
///
/// Mirrors the PWA's `vehicleService.getVehicleImages` and
/// `partsService.getPartDetails` calls. Uses the same SerpAPI-backed
/// endpoints so both clients share identical data.
class VehicleViewerService {
  static final VehicleViewerService _instance =
      VehicleViewerService._internal();
  factory VehicleViewerService() => _instance;
  VehicleViewerService._internal();

  final ApiService _api = ApiService();

  // ---------------------------------------------------------------------------
  // Vehicle images  (GET /api/vehicle/images/:vin)
  // ---------------------------------------------------------------------------

  /// Fetch web-searched vehicle images for a given VIN.
  ///
  /// Returns a list of [VehicleImage] objects (typically 5) with angle labels
  /// assigned sequentially by the backend from its Google Images results.
  Future<List<VehicleImage>> getVehicleImages(String vin) async {
    final response = await _api.get('/vehicle/images/$vin');
    final data = json.decode(response.body) as Map<String, dynamic>;

    if (data['success'] == true && data['images'] != null) {
      return (data['images'] as List<dynamic>)
          .map((e) => VehicleImage.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw VehicleViewerException(
      data['message'] as String? ?? 'Failed to load vehicle images',
    );
  }

  /// Fetch images using vehicle data instead of VIN.
  ///
  /// Calls `POST /api/vehicle/images` with `{ vehicleData: {...} }`.
  Future<List<VehicleImage>> getVehicleImagesByData({
    required String make,
    required String model,
    required String year,
  }) async {
    final response = await _api.post(
      '/vehicle/images',
      body: {
        'vehicleData': {'make': make, 'model': model, 'year': year},
      },
    );
    final data = json.decode(response.body) as Map<String, dynamic>;

    if (data['success'] == true && data['images'] != null) {
      return (data['images'] as List<dynamic>)
          .map((e) => VehicleImage.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw VehicleViewerException(
      data['message'] as String? ?? 'Failed to load vehicle images',
    );
  }

  // ---------------------------------------------------------------------------
  // Part details  (POST /api/parts/details)
  // ---------------------------------------------------------------------------

  /// Fetch AI-generated description + SerpAPI image for a part.
  Future<PartDetailsResponse> getPartDetails(
    String partName, {
    Map<String, dynamic>? vehicleData,
  }) async {
    final body = <String, dynamic>{'partName': partName};
    if (vehicleData != null) body['vehicleData'] = vehicleData;

    final response = await _api.post('/parts/details', body: body);
    final data = json.decode(response.body) as Map<String, dynamic>;

    if (data['success'] == true) {
      return PartDetailsResponse.fromJson(data);
    }

    throw VehicleViewerException(
      data['message'] as String? ?? 'Failed to load part details',
    );
  }
}

/// Exception for vehicle viewer service errors.
class VehicleViewerException implements Exception {
  final String message;
  const VehicleViewerException(this.message);

  @override
  String toString() => 'VehicleViewerException: $message';
}
