/// VIN Decode Result model for German Car Medic
///
/// Represents the decoded vehicle information returned from
/// the backend `/api/vin/decode` endpoint.
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
  final String? plantCountry;
  final String? series;
  final String? trim;
  final String? productType;
  final String? doors;
  final String? seats;
  final String? cylinders;
  final String? engineCode;
  final String? powerKw;
  final String? displacementCcm;
  final String? engineHead;
  final String? engineValves;
  final String? torque;
  final String? length;
  final String? width;
  final String? height;
  final String? wheelbase;
  final String? weight;
  final String? maxWeight;
  final String? wheelSize;
  final String? maxSpeed;
  final String? co2Emission;
  final String? emissionStandard;
  final String? manufacturerAddress;
  final String? productionStarted;
  final String? productionStopped;
  final String? vehicleType;
  final String? airConditioning;
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
    this.plantCountry,
    this.series,
    this.trim,
    this.productType,
    this.doors,
    this.seats,
    this.cylinders,
    this.engineCode,
    this.powerKw,
    this.displacementCcm,
    this.engineHead,
    this.engineValves,
    this.torque,
    this.length,
    this.width,
    this.height,
    this.wheelbase,
    this.weight,
    this.maxWeight,
    this.wheelSize,
    this.maxSpeed,
    this.co2Emission,
    this.emissionStandard,
    this.manufacturerAddress,
    this.productionStarted,
    this.productionStopped,
    this.vehicleType,
    this.airConditioning,
    this.rawData,
    required this.decodedAt,
  });

  /// Safely convert a dynamic value to String? (handles numbers, booleans, etc.)
  static String? _toStr(dynamic value) => value?.toString();

  /// Create from backend JSON response
  factory VinDecodeResult.fromJson(Map<String, dynamic> json) {
    final vehicle = json['vehicle'] as Map<String, dynamic>? ?? json;

    return VinDecodeResult(
      vin: (vehicle['vin'] ?? json['vin'] ?? '').toString(),
      manufacturer: _toStr(vehicle['manufacturer']) ?? _toStr(vehicle['make']),
      model: _toStr(vehicle['model']),
      year: _toStr(vehicle['year']),
      bodyStyle:
          _toStr(vehicle['bodyStyle']) ??
          _toStr(vehicle['bodyType']) ??
          _toStr(vehicle['bodyClass']),
      engineType:
          _toStr(vehicle['engineType']) ??
          _toStr(vehicle['engine']) ??
          _toStr(vehicle['engineModel']),
      transmission:
          _toStr(vehicle['transmission']) ??
          _toStr(vehicle['transmissionStyle']),
      driveType: _toStr(vehicle['driveType']) ?? _toStr(vehicle['drivetrain']),
      fuelType:
          _toStr(vehicle['fuelType']) ?? _toStr(vehicle['fuelTypePrimary']),
      displacement:
          _toStr(vehicle['displacement']) ?? _toStr(vehicle['displacementL']),
      power:
          _toStr(vehicle['power']) ??
          _toStr(vehicle['horsepower']) ??
          _toStr(vehicle['engineHP']),
      countryOfOrigin:
          _toStr(vehicle['countryOfOrigin']) ??
          _toStr(vehicle['origin']) ??
          _toStr(vehicle['plantCountry']),
      plantCity: _toStr(vehicle['plantCity']),
      plantCountry: _toStr(vehicle['plantCountry']),
      series: _toStr(vehicle['series']) ?? _toStr(vehicle['style']),
      trim: _toStr(vehicle['trim']),
      productType: _toStr(vehicle['productType']),
      doors: _toStr(vehicle['doors']),
      seats: _toStr(vehicle['seats']),
      cylinders: _toStr(vehicle['cylinders']),
      engineCode: _toStr(vehicle['engineCode']),
      powerKw: _toStr(vehicle['powerKw']) ?? _toStr(vehicle['kilowatts']),
      displacementCcm: _toStr(vehicle['displacementCcm']),
      engineHead: _toStr(vehicle['engineHead']),
      engineValves: _toStr(vehicle['engineValves']),
      torque: _toStr(vehicle['torque']),
      length: _toStr(vehicle['length']),
      width: _toStr(vehicle['width']),
      height: _toStr(vehicle['height']),
      wheelbase: _toStr(vehicle['wheelbase']),
      weight: _toStr(vehicle['weight']),
      maxWeight: _toStr(vehicle['maxWeight']),
      wheelSize: _toStr(vehicle['wheelSize']),
      maxSpeed: _toStr(vehicle['maxSpeed']),
      co2Emission: _toStr(vehicle['co2Emission']),
      emissionStandard: _toStr(vehicle['emissionStandard']),
      manufacturerAddress: _toStr(vehicle['manufacturerAddress']),
      productionStarted: _toStr(vehicle['productionStarted']),
      productionStopped: _toStr(vehicle['productionStopped']),
      vehicleType: _toStr(vehicle['vehicleType']),
      airConditioning: _toStr(vehicle['airConditioning']),
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
    'plantCountry': plantCountry,
    'series': series,
    'trim': trim,
    'productType': productType,
    'doors': doors,
    'seats': seats,
    'cylinders': cylinders,
    'engineCode': engineCode,
    'powerKw': powerKw,
    'displacementCcm': displacementCcm,
    'engineHead': engineHead,
    'engineValves': engineValves,
    'torque': torque,
    'length': length,
    'width': width,
    'height': height,
    'wheelbase': wheelbase,
    'weight': weight,
    'maxWeight': maxWeight,
    'wheelSize': wheelSize,
    'maxSpeed': maxSpeed,
    'co2Emission': co2Emission,
    'emissionStandard': emissionStandard,
    'manufacturerAddress': manufacturerAddress,
    'productionStarted': productionStarted,
    'productionStopped': productionStopped,
    'vehicleType': vehicleType,
    'airConditioning': airConditioning,
    'decodedAt': decodedAt.toIso8601String(),
  };

  /// Create from locally cached JSON
  factory VinDecodeResult.fromCache(Map<String, dynamic> json) {
    return VinDecodeResult(
      vin: (json['vin'] ?? '').toString(),
      manufacturer: _toStr(json['manufacturer']),
      model: _toStr(json['model']),
      year: _toStr(json['year']),
      bodyStyle: _toStr(json['bodyStyle']),
      engineType: _toStr(json['engineType']),
      transmission: _toStr(json['transmission']),
      driveType: _toStr(json['driveType']),
      fuelType: _toStr(json['fuelType']),
      displacement: _toStr(json['displacement']),
      power: _toStr(json['power']),
      countryOfOrigin: _toStr(json['countryOfOrigin']),
      plantCity: _toStr(json['plantCity']),
      plantCountry: _toStr(json['plantCountry']),
      series: _toStr(json['series']),
      trim: _toStr(json['trim']),
      productType: _toStr(json['productType']),
      doors: _toStr(json['doors']),
      seats: _toStr(json['seats']),
      cylinders: _toStr(json['cylinders']),
      engineCode: _toStr(json['engineCode']),
      powerKw: _toStr(json['powerKw']),
      displacementCcm: _toStr(json['displacementCcm']),
      engineHead: _toStr(json['engineHead']),
      engineValves: _toStr(json['engineValves']),
      torque: _toStr(json['torque']),
      length: _toStr(json['length']),
      width: _toStr(json['width']),
      height: _toStr(json['height']),
      wheelbase: _toStr(json['wheelbase']),
      weight: _toStr(json['weight']),
      maxWeight: _toStr(json['maxWeight']),
      wheelSize: _toStr(json['wheelSize']),
      maxSpeed: _toStr(json['maxSpeed']),
      co2Emission: _toStr(json['co2Emission']),
      emissionStandard: _toStr(json['emissionStandard']),
      manufacturerAddress: _toStr(json['manufacturerAddress']),
      productionStarted: _toStr(json['productionStarted']),
      productionStopped: _toStr(json['productionStopped']),
      vehicleType: _toStr(json['vehicleType']),
      airConditioning: _toStr(json['airConditioning']),
      decodedAt:
          DateTime.tryParse(_toStr(json['decodedAt']) ?? '') ?? DateTime.now(),
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

  /// Whether the VIN decoded to meaningful vehicle data.
  ///
  /// Returns false when key fields are all null or "Unknown",
  /// which happens when the user enters an invalid VIN.
  bool get isValidDecode {
    bool _isKnown(String? value) =>
        value != null &&
        value.isNotEmpty &&
        value.toLowerCase() != 'unknown' &&
        value.toLowerCase() != 'n/a';

    return _isKnown(manufacturer) || _isKnown(model) || _isKnown(year);
  }
}
