/// Models for the 360° Vehicle Viewer & Interactive Parts feature.
///
/// Mirrors the PWA's `VehicleImage`, `UniversalPart`, and `PartDetailsResponse`
/// types so the mobile app works identically with the SerpAPI-backed endpoints.
library;

// =============================================================================
// Vehicle Image (from SerpAPI web search)
// =============================================================================

/// A single vehicle image returned from `GET /api/vehicle/images/:vin`.
class VehicleImage {
  final String angle;
  final String imageUrl;
  final String? thumbnail;
  final String? title;
  final String? source;
  final String? searchEngine;
  final int? width;
  final int? height;
  final bool success;
  final String? error;
  final String model;
  final bool isBase64;

  const VehicleImage({
    required this.angle,
    required this.imageUrl,
    this.thumbnail,
    this.title,
    this.source,
    this.searchEngine,
    this.width,
    this.height,
    this.success = true,
    this.error,
    this.model = '',
    this.isBase64 = false,
  });

  factory VehicleImage.fromJson(Map<String, dynamic> json) {
    return VehicleImage(
      angle: json['angle'] as String? ?? 'front',
      imageUrl: (json['imageUrl'] ?? json['url'] ?? '') as String,
      thumbnail: json['thumbnail'] as String?,
      title: json['title'] as String?,
      source: json['source'] as String?,
      searchEngine: json['searchEngine'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      success: json['success'] as bool? ?? true,
      error: json['error'] as String?,
      model: json['model'] as String? ?? '',
      isBase64: json['isBase64'] as bool? ?? false,
    );
  }
}

// =============================================================================
// Universal automotive part (for the Parts Grid)
// =============================================================================

/// One of the 42 universal parts shown in the parts grid below the viewer.
class UniversalPart {
  final String id;
  final String name;
  final String category;
  final String description;
  final String iconName; // mapped to Flutter IconData at the widget level

  const UniversalPart({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.iconName = 'build',
  });
}

/// Full details returned from `POST /api/parts/details`.
class PartDetailsResponse {
  final String partId;
  final String partName;
  final String? description;
  final String? function;
  final List<String> symptoms;
  final String? partNumber;
  final PartImage? image;
  final Map<String, dynamic>? vehicle;
  final String? imageSource;
  final String? descriptionSource;
  final String generatedAt;

  const PartDetailsResponse({
    required this.partId,
    required this.partName,
    this.description,
    this.function,
    this.symptoms = const [],
    this.partNumber,
    this.image,
    this.vehicle,
    this.imageSource,
    this.descriptionSource,
    this.generatedAt = '',
  });

  String get vehicleLabel {
    if (vehicle == null) return '';
    final parts = <String>[];
    if (vehicle!['year'] != null) parts.add(vehicle!['year'].toString());
    if (vehicle!['make'] != null) parts.add(vehicle!['make'].toString());
    if (vehicle!['model'] != null) parts.add(vehicle!['model'].toString());
    return parts.join(' ');
  }

  factory PartDetailsResponse.fromJson(Map<String, dynamic> json) {
    PartImage? img;
    final rawImage = json['image'];
    if (rawImage is Map<String, dynamic>) {
      img = PartImage.fromJson(rawImage);
    }

    return PartDetailsResponse(
      partId: json['partId'] as String? ?? '',
      partName: json['partName'] as String? ?? 'Unknown Part',
      description: json['description'] as String?,
      function: json['function'] as String?,
      symptoms:
          (json['symptoms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      partNumber: json['partNumber'] as String?,
      image: img,
      vehicle: json['vehicle'] as Map<String, dynamic>?,
      imageSource: json['imageSource'] as String?,
      descriptionSource: json['descriptionSource'] as String?,
      generatedAt: json['generatedAt'] as String? ?? '',
    );
  }
}

/// Part image metadata from SerpAPI.
class PartImage {
  final String url;
  final String? title;
  final String? source;

  const PartImage({required this.url, this.title, this.source});

  factory PartImage.fromJson(Map<String, dynamic> json) {
    return PartImage(
      url: json['url'] as String? ?? '',
      title: json['title'] as String?,
      source: json['source'] as String?,
    );
  }
}

// =============================================================================
// Universal parts data – mirrors PWA's universalPartsData (42 items)
// =============================================================================

const List<UniversalPart> universalPartsData = [
  // Engine & Powertrain
  UniversalPart(
    id: 'engine',
    name: 'Engine Block',
    category: 'Engine',
    description: 'Main engine assembly',
    iconName: 'car',
  ),
  UniversalPart(
    id: 'transmission',
    name: 'Transmission',
    category: 'Powertrain',
    description: 'Gear transmission system',
    iconName: 'settings',
  ),
  UniversalPart(
    id: 'oil-pan',
    name: 'Oil Pan',
    category: 'Engine',
    description: 'Engine oil reservoir',
    iconName: 'oil',
  ),
  UniversalPart(
    id: 'air-filter',
    name: 'Air Filter',
    category: 'Engine',
    description: 'Air intake filtration',
    iconName: 'air',
  ),
  UniversalPart(
    id: 'spark-plugs',
    name: 'Spark Plugs',
    category: 'Engine',
    description: 'Ignition components',
    iconName: 'bolt',
  ),
  UniversalPart(
    id: 'fuel-pump',
    name: 'Fuel Pump',
    category: 'Fuel System',
    description: 'Fuel delivery system',
    iconName: 'oil',
  ),
  // Brakes
  UniversalPart(
    id: 'brake-pads',
    name: 'Brake Pads',
    category: 'Brakes',
    description: 'Brake friction material',
    iconName: 'disc',
  ),
  UniversalPart(
    id: 'brake-rotors',
    name: 'Brake Rotors',
    category: 'Brakes',
    description: 'Brake disc rotors',
    iconName: 'circle',
  ),
  UniversalPart(
    id: 'brake-calipers',
    name: 'Brake Calipers',
    category: 'Brakes',
    description: 'Brake clamping mechanism',
    iconName: 'build',
  ),
  // Electrical
  UniversalPart(
    id: 'battery',
    name: 'Battery',
    category: 'Electrical',
    description: '12V automotive battery',
    iconName: 'battery',
  ),
  UniversalPart(
    id: 'alternator',
    name: 'Alternator',
    category: 'Electrical',
    description: 'Charging system generator',
    iconName: 'bolt',
  ),
  UniversalPart(
    id: 'starter',
    name: 'Starter Motor',
    category: 'Electrical',
    description: 'Engine starting motor',
    iconName: 'settings',
  ),
  UniversalPart(
    id: 'headlights',
    name: 'Headlights',
    category: 'Lighting',
    description: 'Front lighting assembly',
    iconName: 'bolt',
  ),
  UniversalPart(
    id: 'tail-lights',
    name: 'Tail Lights',
    category: 'Lighting',
    description: 'Rear lighting assembly',
    iconName: 'bolt',
  ),
  // Cooling
  UniversalPart(
    id: 'radiator',
    name: 'Radiator',
    category: 'Cooling',
    description: 'Engine cooling radiator',
    iconName: 'thermostat',
  ),
  UniversalPart(
    id: 'water-pump',
    name: 'Water Pump',
    category: 'Cooling',
    description: 'Coolant circulation pump',
    iconName: 'thermostat',
  ),
  UniversalPart(
    id: 'thermostat',
    name: 'Thermostat',
    category: 'Cooling',
    description: 'Temperature control valve',
    iconName: 'thermostat',
  ),
  UniversalPart(
    id: 'radiator-hoses',
    name: 'Radiator Hoses',
    category: 'Cooling',
    description: 'Coolant system hoses',
    iconName: 'thermostat',
  ),
  // Suspension & Steering
  UniversalPart(
    id: 'shock-absorbers',
    name: 'Shock Absorbers',
    category: 'Suspension',
    description: 'Suspension dampers',
    iconName: 'circle',
  ),
  UniversalPart(
    id: 'struts',
    name: 'Struts',
    category: 'Suspension',
    description: 'Suspension struts',
    iconName: 'circle',
  ),
  UniversalPart(
    id: 'control-arms',
    name: 'Control Arms',
    category: 'Suspension',
    description: 'Suspension linkage',
    iconName: 'build',
  ),
  UniversalPart(
    id: 'tie-rods',
    name: 'Tie Rods',
    category: 'Steering',
    description: 'Steering linkage',
    iconName: 'build',
  ),
  UniversalPart(
    id: 'power-steering-pump',
    name: 'Power Steering Pump',
    category: 'Steering',
    description: 'Steering assist pump',
    iconName: 'settings',
  ),
  // Wheels
  UniversalPart(
    id: 'tires',
    name: 'Tires',
    category: 'Wheels',
    description: 'Rubber tires',
    iconName: 'circle',
  ),
  UniversalPart(
    id: 'wheels',
    name: 'Wheels',
    category: 'Wheels',
    description: 'Wheel rims',
    iconName: 'circle',
  ),
  UniversalPart(
    id: 'wheel-bearings',
    name: 'Wheel Bearings',
    category: 'Wheels',
    description: 'Wheel rotation bearings',
    iconName: 'circle',
  ),
  // Exhaust
  UniversalPart(
    id: 'exhaust-manifold',
    name: 'Exhaust Manifold',
    category: 'Exhaust',
    description: 'Exhaust gas collector',
    iconName: 'air',
  ),
  UniversalPart(
    id: 'catalytic-converter',
    name: 'Catalytic Converter',
    category: 'Exhaust',
    description: 'Emissions control device',
    iconName: 'air',
  ),
  UniversalPart(
    id: 'muffler',
    name: 'Muffler',
    category: 'Exhaust',
    description: 'Exhaust sound dampener',
    iconName: 'air',
  ),
  // Filters
  UniversalPart(
    id: 'oil-filter',
    name: 'Oil Filter',
    category: 'Filters',
    description: 'Engine oil filtration',
    iconName: 'filter',
  ),
  UniversalPart(
    id: 'fuel-filter',
    name: 'Fuel Filter',
    category: 'Filters',
    description: 'Fuel system filtration',
    iconName: 'filter',
  ),
  UniversalPart(
    id: 'cabin-filter',
    name: 'Cabin Air Filter',
    category: 'Filters',
    description: 'Interior air filtration',
    iconName: 'filter',
  ),
  // Belts
  UniversalPart(
    id: 'timing-belt',
    name: 'Timing Belt',
    category: 'Engine',
    description: 'Engine timing belt',
    iconName: 'build',
  ),
  UniversalPart(
    id: 'serpentine-belt',
    name: 'Serpentine Belt',
    category: 'Engine',
    description: 'Accessory drive belt',
    iconName: 'build',
  ),
  // Electronics
  UniversalPart(
    id: 'ecu',
    name: 'Engine Control Unit',
    category: 'Electronics',
    description: 'Engine management computer',
    iconName: 'cpu',
  ),
  UniversalPart(
    id: 'sensors',
    name: 'Sensors',
    category: 'Electronics',
    description: 'Various engine sensors',
    iconName: 'cpu',
  ),
  UniversalPart(
    id: 'ignition-coils',
    name: 'Ignition Coils',
    category: 'Electronics',
    description: 'Spark generation coils',
    iconName: 'bolt',
  ),
  // Body
  UniversalPart(
    id: 'side-mirrors',
    name: 'Side Mirrors',
    category: 'Body',
    description: 'Exterior mirrors',
    iconName: 'car',
  ),
  UniversalPart(
    id: 'windshield-wipers',
    name: 'Windshield Wipers',
    category: 'Body',
    description: 'Wiper blade assemblies',
    iconName: 'car',
  ),
  UniversalPart(
    id: 'door-handles',
    name: 'Door Handles',
    category: 'Body',
    description: 'Exterior door handles',
    iconName: 'car',
  ),
  // HVAC
  UniversalPart(
    id: 'ac-compressor',
    name: 'A/C Compressor',
    category: 'HVAC',
    description: 'Air conditioning compressor',
    iconName: 'air',
  ),
  UniversalPart(
    id: 'blower-motor',
    name: 'Blower Motor',
    category: 'HVAC',
    description: 'HVAC blower fan motor',
    iconName: 'air',
  ),
];
