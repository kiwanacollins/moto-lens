/// Model for a scanned part (from QR code or manual entry).
///
/// Tracks the scanned value, resolved part details, and timestamps
/// for history and offline caching.
library;

/// A single QR / part-number scan entry.
class PartScanEntry {
  final String id;
  final String scannedValue;
  final DateTime scannedAt;
  final String? partName;
  final String? partNumber;
  final String? description;
  final String? imageUrl;
  final Map<String, dynamic>? vehicleContext;
  final bool isResolved;

  const PartScanEntry({
    required this.id,
    required this.scannedValue,
    required this.scannedAt,
    this.partName,
    this.partNumber,
    this.description,
    this.imageUrl,
    this.vehicleContext,
    this.isResolved = false,
  });

  /// Human-readable display label.
  String get displayLabel => partName ?? scannedValue;

  /// Short timestamp for list tiles.
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(scannedAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${scannedAt.day}/${scannedAt.month}/${scannedAt.year}';
  }

  // ---------------------------------------------------------------------------
  // JSON
  // ---------------------------------------------------------------------------

  factory PartScanEntry.fromJson(Map<String, dynamic> json) {
    return PartScanEntry(
      id: json['id'] as String,
      scannedValue: json['scannedValue'] as String,
      scannedAt: DateTime.parse(json['scannedAt'] as String),
      partName: json['partName'] as String?,
      partNumber: json['partNumber'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      vehicleContext: json['vehicleContext'] as Map<String, dynamic>?,
      isResolved: json['isResolved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'scannedValue': scannedValue,
    'scannedAt': scannedAt.toIso8601String(),
    'partName': partName,
    'partNumber': partNumber,
    'description': description,
    'imageUrl': imageUrl,
    'vehicleContext': vehicleContext,
    'isResolved': isResolved,
  };

  PartScanEntry copyWith({
    String? id,
    String? scannedValue,
    DateTime? scannedAt,
    String? partName,
    String? partNumber,
    String? description,
    String? imageUrl,
    Map<String, dynamic>? vehicleContext,
    bool? isResolved,
  }) {
    return PartScanEntry(
      id: id ?? this.id,
      scannedValue: scannedValue ?? this.scannedValue,
      scannedAt: scannedAt ?? this.scannedAt,
      partName: partName ?? this.partName,
      partNumber: partNumber ?? this.partNumber,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      vehicleContext: vehicleContext ?? this.vehicleContext,
      isResolved: isResolved ?? this.isResolved,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartScanEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Full part details returned from the backend `/api/parts/details` endpoint.
class PartDetails {
  final String partId;
  final String partName;
  final String? description;
  final String? function;
  final List<String> symptoms;
  final String? partNumber;
  final String? imageUrl;
  final Map<String, dynamic>? vehicle;
  final String generatedAt;

  const PartDetails({
    required this.partId,
    required this.partName,
    this.description,
    this.function,
    this.symptoms = const [],
    this.partNumber,
    this.imageUrl,
    this.vehicle,
    this.generatedAt = '',
  });

  /// Vehicle label e.g. "2020 BMW 3 Series".
  String get vehicleLabel {
    if (vehicle == null) return '';
    final parts = <String>[];
    if (vehicle!['year'] != null) parts.add(vehicle!['year'].toString());
    if (vehicle!['make'] != null) parts.add(vehicle!['make'].toString());
    if (vehicle!['model'] != null) parts.add(vehicle!['model'].toString());
    return parts.join(' ');
  }

  factory PartDetails.fromJson(Map<String, dynamic> json) {
    final image = json['image'];
    String? imgUrl;
    if (image is Map<String, dynamic>) {
      imgUrl = image['url'] as String?;
    } else if (image is String) {
      imgUrl = image;
    }

    return PartDetails(
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
      imageUrl: imgUrl,
      vehicle: json['vehicle'] as Map<String, dynamic>?,
      generatedAt: json['generatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'partId': partId,
    'partName': partName,
    'description': description,
    'function': function,
    'symptoms': symptoms,
    'partNumber': partNumber,
    'image': imageUrl,
    'vehicle': vehicle,
    'generatedAt': generatedAt,
  };
}
