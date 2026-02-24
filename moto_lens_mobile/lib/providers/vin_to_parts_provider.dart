import 'package:flutter/foundation.dart';
import '../services/tecdoc_service.dart';
import '../services/api_service.dart';

/// Represents a vehicle variant returned by TecDoc
class TecDocVehicle {
  final int vehicleId;
  final String manufacturerName;
  final String modelName;
  final String typeEngineName;

  TecDocVehicle({
    required this.vehicleId,
    required this.manufacturerName,
    required this.modelName,
    required this.typeEngineName,
  });

  factory TecDocVehicle.fromJson(Map<String, dynamic> json) {
    return TecDocVehicle(
      vehicleId: json['vehicleId'] as int,
      manufacturerName: (json['manufacturerName'] ?? '') as String,
      modelName: (json['modelName'] ?? '') as String,
      typeEngineName: (json['typeEngineName'] ?? '') as String,
    );
  }
}

/// Represents a parts category (e.g. "Air Filter") with its OEM numbers
class TecDocPartCategory {
  final String productName;
  final int count;
  final List<String> oemNumbers;

  TecDocPartCategory({
    required this.productName,
    required this.count,
    required this.oemNumbers,
  });

  factory TecDocPartCategory.fromJson(Map<String, dynamic> json) {
    return TecDocPartCategory(
      productName: (json['productName'] ?? 'Unknown') as String,
      count: (json['count'] ?? 0) as int,
      oemNumbers: List<String>.from(json['oemNumbers'] ?? []),
    );
  }
}

/// The different stages of the VIN-to-Parts flow
enum VinToPartsStep { input, loading, vehicleSelect, partsResult, error }

/// Provider for VIN-to-Parts feature state
class VinToPartsProvider extends ChangeNotifier {
  final TecDocService _service = TecDocService();

  VinToPartsStep _step = VinToPartsStep.input;
  VinToPartsStep get step => _step;

  String _vin = '';
  String get vin => _vin;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _loadingMessage = 'Decoding VIN...';
  String get loadingMessage => _loadingMessage;

  // Step 1 results
  String _manufacturer = '';
  String get manufacturer => _manufacturer;

  String _modelName = '';
  String get modelName => _modelName;

  // Step 2 results
  List<TecDocVehicle> _vehicles = [];
  List<TecDocVehicle> get vehicles => _vehicles;

  TecDocVehicle? _selectedVehicle;
  TecDocVehicle? get selectedVehicle => _selectedVehicle;

  // Step 3 results
  List<TecDocPartCategory> _partCategories = [];
  List<TecDocPartCategory> get partCategories => _partCategories;

  int _totalParts = 0;
  int get totalParts => _totalParts;

  // Search/filter for parts list
  String _partsSearchQuery = '';
  String get partsSearchQuery => _partsSearchQuery;

  List<TecDocPartCategory> get filteredCategories {
    if (_partsSearchQuery.isEmpty) return _partCategories;
    final q = _partsSearchQuery.toLowerCase();
    return _partCategories
        .where(
          (c) =>
              c.productName.toLowerCase().contains(q) ||
              c.oemNumbers.any((n) => n.toLowerCase().contains(q)),
        )
        .toList();
  }

  void setPartsSearchQuery(String query) {
    _partsSearchQuery = query;
    notifyListeners();
  }

  /// Run the full VIN-to-Parts flow with auto-selected vehicle
  Future<void> lookupVin(String vin) async {
    _vin = vin.toUpperCase().trim();
    _step = VinToPartsStep.loading;
    _loadingMessage = 'Decoding VIN...';
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _service.vinToParts(_vin);

      if (result['success'] != true) {
        _errorMessage = result['message'] ?? 'Lookup failed';
        _step = VinToPartsStep.error;
        notifyListeners();
        return;
      }

      _manufacturer = (result['manufacturer'] ?? '') as String;
      _modelName = (result['modelName'] ?? '') as String;

      // Parse selected vehicle
      final sv = result['selectedVehicle'] as Map<String, dynamic>?;
      _selectedVehicle = sv != null ? TecDocVehicle.fromJson(sv) : null;

      // Parse available vehicles
      final avList = result['availableVehicles'] as List<dynamic>? ?? [];
      _vehicles = avList
          .map((v) => TecDocVehicle.fromJson(v as Map<String, dynamic>))
          .toList();

      // Parse parts
      final partsData = result['parts'] as Map<String, dynamic>? ?? {};
      _totalParts = (partsData['totalParts'] ?? 0) as int;
      final cats = partsData['categories'] as List<dynamic>? ?? [];
      _partCategories = cats
          .map((c) => TecDocPartCategory.fromJson(c as Map<String, dynamic>))
          .toList();

      _step = VinToPartsStep.partsResult;
      notifyListeners();
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _step = VinToPartsStep.error;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _step = VinToPartsStep.error;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      _step = VinToPartsStep.error;
      notifyListeners();
    }
  }

  /// Fetch parts for a different vehicle variant
  Future<void> selectVehicle(TecDocVehicle vehicle) async {
    _selectedVehicle = vehicle;
    _step = VinToPartsStep.loading;
    _loadingMessage = 'Loading parts for ${vehicle.typeEngineName}...';
    _partsSearchQuery = '';
    notifyListeners();

    try {
      final result = await _service.getVehicleParts(vehicle.vehicleId);

      if (result['success'] != true) {
        _errorMessage = result['message'] ?? 'Failed to load parts';
        _step = VinToPartsStep.error;
        notifyListeners();
        return;
      }

      _totalParts = (result['totalParts'] ?? 0) as int;
      final cats = result['categories'] as List<dynamic>? ?? [];
      _partCategories = cats
          .map((c) => TecDocPartCategory.fromJson(c as Map<String, dynamic>))
          .toList();

      _step = VinToPartsStep.partsResult;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load parts: $e';
      _step = VinToPartsStep.error;
      notifyListeners();
    }
  }

  /// Show vehicle selection list
  void showVehicleSelection() {
    _step = VinToPartsStep.vehicleSelect;
    notifyListeners();
  }

  // ── Part category images ──────────────────────────────────

  /// Maps productName → thumbnail URL (loaded lazily)
  final Map<String, String?> _categoryImages = {};

  /// null = not fetched, empty string = failed/no image
  String? getCategoryImage(String productName) => _categoryImages[productName];

  /// Whether an image fetch is in progress for this category
  final Set<String> _imageLoading = {};
  bool isCategoryImageLoading(String productName) =>
      _imageLoading.contains(productName);

  /// Lazily load an image for a single part category via SerpAPI
  Future<void> loadCategoryImage(String productName) async {
    if (_categoryImages.containsKey(productName))
      return; // already fetched or fetching
    _imageLoading.add(productName);
    _categoryImages[productName] = null; // mark as in-flight
    notifyListeners();

    final url = await _service.getPartImage(
      partName: productName,
      make: _manufacturer.isNotEmpty ? _manufacturer : null,
      model: _selectedVehicle?.modelName,
    );

    _categoryImages[productName] = url ?? '';
    _imageLoading.remove(productName);
    notifyListeners();
  }

  /// Reset back to VIN input
  void reset() {
    _step = VinToPartsStep.input;
    _vin = '';
    _errorMessage = '';
    _manufacturer = '';
    _modelName = '';
    _vehicles = [];
    _selectedVehicle = null;
    _partCategories = [];
    _totalParts = 0;
    _partsSearchQuery = '';
    _categoryImages.clear();
    _imageLoading.clear();
    notifyListeners();
  }
}
