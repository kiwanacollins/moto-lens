import 'package:flutter/foundation.dart';
import '../models/vehicle_viewer.dart';
import '../services/vehicle_viewer_service.dart';

/// State management for the 360° Vehicle Viewer & Parts Grid.
///
/// Loads vehicle images via SerpAPI, manages the current rotation index,
/// and handles part-detail lookups for the interactive parts grid.
class VehicleViewerProvider extends ChangeNotifier {
  final VehicleViewerService _service = VehicleViewerService();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  List<VehicleImage> _images = [];
  int _currentIndex = 0;
  bool _isLoadingImages = false;
  String? _imageError;

  PartDetailsResponse? _selectedPartDetails;
  bool _isLoadingPart = false;
  String? _partError;

  String? _activeCategory;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  List<VehicleImage> get images => _images;

  /// Only images that loaded successfully.
  List<VehicleImage> get validImages =>
      _images.where((img) => img.success && img.imageUrl.isNotEmpty).toList();

  int get currentIndex => _currentIndex;
  bool get isLoadingImages => _isLoadingImages;
  String? get imageError => _imageError;

  VehicleImage? get currentImage =>
      validImages.isNotEmpty ? validImages[_currentIndex] : null;

  PartDetailsResponse? get selectedPartDetails => _selectedPartDetails;
  bool get isLoadingPart => _isLoadingPart;
  String? get partError => _partError;

  String? get activeCategory => _activeCategory;

  /// Categories derived from the universal parts data.
  List<String> get categories {
    final cats = <String>{};
    for (final p in universalPartsData) {
      cats.add(p.category);
    }
    return cats.toList();
  }

  /// Parts filtered by active category (or all if null).
  List<UniversalPart> get filteredParts {
    if (_activeCategory == null) return universalPartsData;
    return universalPartsData
        .where((p) => p.category == _activeCategory)
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Image loading
  // ---------------------------------------------------------------------------

  /// Load vehicle images by VIN.
  Future<void> loadImages(String vin) async {
    _isLoadingImages = true;
    _imageError = null;
    _images = [];
    _currentIndex = 0;
    notifyListeners();

    try {
      _images = await _service.getVehicleImages(vin);
    } catch (e) {
      _imageError = e.toString().replaceFirst('VehicleViewerException: ', '');
    } finally {
      _isLoadingImages = false;
      notifyListeners();
    }
  }

  /// Load vehicle images by make/model/year.
  Future<void> loadImagesByData({
    required String make,
    required String model,
    required String year,
  }) async {
    _isLoadingImages = true;
    _imageError = null;
    _images = [];
    _currentIndex = 0;
    notifyListeners();

    try {
      _images = await _service.getVehicleImagesByData(
        make: make,
        model: model,
        year: year,
      );
    } catch (e) {
      _imageError = e.toString().replaceFirst('VehicleViewerException: ', '');
    } finally {
      _isLoadingImages = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Rotation
  // ---------------------------------------------------------------------------

  void goToNext() {
    if (validImages.length <= 1) return;
    _currentIndex = (_currentIndex + 1) % validImages.length;
    notifyListeners();
  }

  void goToPrev() {
    if (validImages.length <= 1) return;
    _currentIndex =
        (_currentIndex - 1 + validImages.length) % validImages.length;
    notifyListeners();
  }

  /// Jump by [steps] images (positive = forward, negative = back).
  void rotateBy(int steps) {
    if (validImages.isEmpty) return;
    final len = validImages.length;
    _currentIndex = ((_currentIndex + steps) % len + len) % len;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Part lookup
  // ---------------------------------------------------------------------------

  /// Fetch full details for a universal part.
  Future<void> selectPart(
    UniversalPart part, {
    Map<String, dynamic>? vehicleData,
  }) async {
    _isLoadingPart = true;
    _partError = null;
    _selectedPartDetails = null;
    notifyListeners();

    try {
      _selectedPartDetails = await _service.getPartDetails(
        part.name,
        vehicleData: vehicleData,
      );
    } catch (e) {
      _partError = e.toString().replaceFirst('VehicleViewerException: ', '');
    } finally {
      _isLoadingPart = false;
      notifyListeners();
    }
  }

  void clearPartDetails() {
    _selectedPartDetails = null;
    _partError = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Category filter
  // ---------------------------------------------------------------------------

  void setCategory(String? category) {
    _activeCategory = category;
    notifyListeners();
  }
}
