/// VIN Decode Result model for German Car Medic
///
/// Represents the decoded vehicle information returned from
/// the backend `/api/vehicle/decode` endpoint.
class VinDecodeResult {
  final String vin;
  final String? manufacturer;
  final String? model;
  final String? year;
  final String? bodyStyle;
  final String? engineType;
  final String? transmission;
  final String? driveType;
  final String? fuelType;
  final String? displacement;
  final String? power;
  final String? countryOfOrigin;
  final String? plantCity;
  final String? series;
  final String? trim;
  final Map<String, dynamic>? rawData;
  final DateTime decodedAt;

  const VinDecodeResult({
    required this.vin,
    this.manufacturer,
    this.model,
    this.year,
    this.bodyStyle,
    this.engineType,
    this.transmission,
    this.driveType,
    this.fuelType,
    this.displacement,
    this.power,
    this.countryOfOrigin,
    this.plantCity,
    this.series,
    this.trim,
    this.rawData,
    required this.decodedAt,
  });

  /// Create from backend JSON response
  factory VinDecodeResult.fromJson(Map<String, dynamic> json) {
    final vehicle = json['vehicle'] as Map<String, dynamic>? ?? json;

    return VinDecodeResult(
      vin: (vehicle['vin'] ?? json['vin'] ?? '') as String,
      manufacturer:
          vehicle['manufacturer'] as String? ?? vehicle['make'] as String?,
      model: vehicle['model'] as String?,
      year: vehicle['year']?.toString(),
      bodyStyle:
          vehicle['bodyStyle'] as String? ?? vehicle['bodyClass'] as String?,
      engineType:
          vehicle['engineType'] as String? ?? vehicle['engineModel'] as String?,
      transmission:
          vehicle['transmission'] as String? ??
          vehicle['transmissionStyle'] as String?,
      driveType: vehicle['driveType'] as String?,
      fuelType:
          vehicle['fuelType'] as String? ??
          vehicle['fuelTypePrimary'] as String?,
      displacement:
          vehicle['displacement'] as String? ??
          vehicle['displacementL']?.toString(),
      power: vehicle['power'] as String? ?? vehicle['engineHP']?.toString(),
      countryOfOrigin:
          vehicle['countryOfOrigin'] as String? ??
          vehicle['plantCountry'] as String?,
      plantCity: vehicle['plantCity'] as String?,
      series: vehicle['series'] as String?,
      trim: vehicle['trim'] as String?,
      rawData: vehicle,
      decodedAt: DateTime.now(),
    );
  }

  /// Convert to JSON for local storage caching
  Map<String, dynamic> toJson() => {
    'vin': vin,
    'manufacturer': manufacturer,
    'model': model,
    'year': year,
    'bodyStyle': bodyStyle,
    'engineType': engineType,
    'transmission': transmission,
    'driveType': driveType,
    'fuelType': fuelType,
    'displacement': displacement,
    'power': power,
    'countryOfOrigin': countryOfOrigin,
    'plantCity': plantCity,
    'series': series,
    'trim': trim,
    'decodedAt': decodedAt.toIso8601String(),
  };

  /// Create from locally cached JSON
  factory VinDecodeResult.fromCache(Map<String, dynamic> json) {
    return VinDecodeResult(
      vin: json['vin'] as String,
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
      year: json['year'] as String?,
      bodyStyle: json['bodyStyle'] as String?,
      engineType: json['engineType'] as String?,
      transmission: json['transmission'] as String?,
      driveType: json['driveType'] as String?,
      fuelType: json['fuelType'] as String?,
      displacement: json['displacement'] as String?,
      power: json['power'] as String?,
      countryOfOrigin: json['countryOfOrigin'] as String?,
      plantCity: json['plantCity'] as String?,
      series: json['series'] as String?,
      trim: json['trim'] as String?,
      decodedAt:
          DateTime.tryParse(json['decodedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Display name for the vehicle (e.g. "BMW 3 Series 2020")
  String get displayName {
    final parts = <String>[];
    if (manufacturer != null) parts.add(manufacturer!);
    if (model != null) parts.add(model!);
    if (year != null) parts.add(year!);
    return parts.isNotEmpty ? parts.join(' ') : vin;
  }

  /// Short display (e.g. "BMW 3 Series")
  String get shortName {
    final parts = <String>[];
    if (manufacturer != null) parts.add(manufacturer!);
    if (model != null) parts.add(model!);
    return parts.isNotEmpty ? parts.join(' ') : vin;
  }
}
