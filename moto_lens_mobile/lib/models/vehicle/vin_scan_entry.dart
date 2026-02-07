/// VIN Scan History Entry for German Car Medic
///
/// Represents a single VIN scan in the user's history,
/// including decoded result and metadata for quick re-access.
class VinScanEntry {
  final String vin;
  final String? manufacturer;
  final String? model;
  final String? year;
  final DateTime scannedAt;
  final bool isSynced;

  const VinScanEntry({
    required this.vin,
    this.manufacturer,
    this.model,
    this.year,
    required this.scannedAt,
    this.isSynced = false,
  });

  /// Create from JSON (local storage)
  factory VinScanEntry.fromJson(Map<String, dynamic> json) {
    return VinScanEntry(
      vin: json['vin'] as String,
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
      year: json['year'] as String?,
      scannedAt: DateTime.tryParse(json['scannedAt'] as String? ?? '') ??
          DateTime.now(),
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }

  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() => {
    'vin': vin,
    'manufacturer': manufacturer,
    'model': model,
    'year': year,
    'scannedAt': scannedAt.toIso8601String(),
    'isSynced': isSynced,
  };

  /// Display name for the scan entry
  String get displayName {
    final parts = <String>[];
    if (manufacturer != null) parts.add(manufacturer!);
    if (model != null) parts.add(model!);
    if (year != null) parts.add(year!);
    return parts.isNotEmpty ? parts.join(' ') : vin;
  }

  /// Time ago string for display
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(scannedAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${scannedAt.day}/${scannedAt.month}/${scannedAt.year}';
  }
}
