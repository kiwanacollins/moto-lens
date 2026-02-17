import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/vehicle/vin_decode_result.dart';
import '../../models/vehicle_viewer.dart';
import '../../services/favorites_service.dart';
import '../../services/vehicle_viewer_service.dart';
import '../../styles/styles.dart';

/// Vehicle Detail Screen - Displays decoded VIN information
///
/// Shows comprehensive vehicle information in grouped sections:
/// - Hero image from SERP API
/// - Basic Vehicle Identification (Make, Model, Year, Product Type, Body, Drive)
/// - Engine (Displacement, Power, Fuel Type, Engine Code, Transmission)
/// - Manufacturer (Manufacturer, Plant Country)
class VehicleDetailScreen extends StatefulWidget {
  final VinDecodeResult vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  bool _isFavorite = false;
  late FavoritesService _favoritesService;
  bool _isInitialized = false;

  // Vehicle image from SERP API
  String? _vehicleImageUrl;
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    _initializeFavorites();
    _loadVehicleImage();
  }

  Future<void> _initializeFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoritesService = FavoritesService(prefs);

    final isFavorite = await _favoritesService.isFavorite(widget.vehicle.vin);

    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
        _isInitialized = true;
      });
    }
  }

  Future<void> _loadVehicleImage() async {
    // Skip loading images for invalid VINs — no useful results possible
    if (!widget.vehicle.isValidDecode) return;

    setState(() => _isLoadingImage = true);

    try {
      final service = VehicleViewerService();
      List<VehicleImage> images;

      if (widget.vehicle.vin.isNotEmpty) {
        images = await service.getVehicleImages(widget.vehicle.vin);
      } else if (widget.vehicle.manufacturer != null &&
          widget.vehicle.model != null &&
          widget.vehicle.year != null) {
        images = await service.getVehicleImagesByData(
          make: widget.vehicle.manufacturer!,
          model: widget.vehicle.model!,
          year: widget.vehicle.year!,
        );
      } else {
        images = [];
      }

      final validImages = images
          .where((i) => i.success && i.imageUrl.isNotEmpty)
          .toList();

      if (mounted && validImages.isNotEmpty) {
        setState(() {
          _vehicleImageUrl = validImages.first.imageUrl;
          _isLoadingImage = false;
        });
      } else if (mounted) {
        setState(() => _isLoadingImage = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Vehicle Details',
          style: AppTypography.h3.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.headerBar,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.black,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: _shareVehicle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section with vehicle image from SERP API
            _buildHeroSection(),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // VIN display with copy button
                  _buildVinDisplay(),
                  const SizedBox(height: AppSpacing.lg),

                  // Basic Vehicle Identification section
                  _buildSection(
                    title: 'Basic Vehicle Identification',
                    rows: [
                      if (widget.vehicle.manufacturer != null)
                        _SectionRow('Make', widget.vehicle.manufacturer!),
                      if (widget.vehicle.model != null)
                        _SectionRow('Model', widget.vehicle.model!),
                      if (widget.vehicle.year != null)
                        _SectionRow('Model Year', widget.vehicle.year!),
                      if (widget.vehicle.productType != null)
                        _SectionRow(
                          'Product Type',
                          widget.vehicle.productType!,
                        ),
                      if (widget.vehicle.bodyStyle != null)
                        _SectionRow('Body', widget.vehicle.bodyStyle!),
                      if (widget.vehicle.driveType != null)
                        _SectionRow('Drive', widget.vehicle.driveType!),
                      if (widget.vehicle.trim != null)
                        _SectionRow('Trim', widget.vehicle.trim!),
                      if (widget.vehicle.series != null)
                        _SectionRow('Series', widget.vehicle.series!),
                      if (widget.vehicle.doors != null)
                        _SectionRow('Doors', widget.vehicle.doors!),
                      if (widget.vehicle.seats != null)
                        _SectionRow('Seats', widget.vehicle.seats!),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Engine section
                  _buildSection(
                    title: 'Engine',
                    rows: [
                      if (widget.vehicle.displacementCcm != null)
                        _SectionRow(
                          'Engine Displacement (ccm)',
                          widget.vehicle.displacementCcm!,
                        ),
                      if (widget.vehicle.displacement != null &&
                          widget.vehicle.displacementCcm == null)
                        _SectionRow(
                          'Displacement',
                          '${widget.vehicle.displacement}L',
                        ),
                      if (widget.vehicle.powerKw != null)
                        _SectionRow(
                          'Engine Power (kW)',
                          widget.vehicle.powerKw!,
                        ),
                      if (widget.vehicle.power != null)
                        _SectionRow('Engine Power (HP)', widget.vehicle.power!),
                      if (widget.vehicle.cylinders != null)
                        _SectionRow('Cylinders', widget.vehicle.cylinders!),
                      if (widget.vehicle.fuelType != null)
                        _SectionRow(
                          'Fuel Type - Primary',
                          widget.vehicle.fuelType!,
                        ),
                      if (widget.vehicle.engineCode != null)
                        _SectionRow('Engine Code', widget.vehicle.engineCode!),
                      if (widget.vehicle.engineType != null)
                        _SectionRow('Engine', widget.vehicle.engineType!),
                      if (widget.vehicle.engineHead != null)
                        _SectionRow('Engine Head', widget.vehicle.engineHead!),
                      if (widget.vehicle.engineValves != null)
                        _SectionRow(
                          'Engine Valves',
                          widget.vehicle.engineValves!,
                        ),
                      if (widget.vehicle.transmission != null)
                        _SectionRow(
                          'Transmission',
                          widget.vehicle.transmission!,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Dimensions & Weight section
                  _buildSection(
                    title: 'Dimensions & Weight',
                    rows: [
                      if (widget.vehicle.length != null)
                        _SectionRow('Length', '${widget.vehicle.length} mm'),
                      if (widget.vehicle.width != null)
                        _SectionRow('Width', '${widget.vehicle.width} mm'),
                      if (widget.vehicle.height != null)
                        _SectionRow('Height', '${widget.vehicle.height} mm'),
                      if (widget.vehicle.wheelbase != null)
                        _SectionRow(
                          'Wheelbase',
                          '${widget.vehicle.wheelbase} mm',
                        ),
                      if (widget.vehicle.weight != null)
                        _SectionRow(
                          'Weight (empty)',
                          '${widget.vehicle.weight} kg',
                        ),
                      if (widget.vehicle.maxWeight != null)
                        _SectionRow(
                          'Max Weight',
                          '${widget.vehicle.maxWeight} kg',
                        ),
                      if (widget.vehicle.wheelSize != null)
                        _SectionRow('Wheel Size', widget.vehicle.wheelSize!),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Performance & Emissions section
                  _buildSection(
                    title: 'Performance & Emissions',
                    rows: [
                      if (widget.vehicle.maxSpeed != null)
                        _SectionRow(
                          'Max Speed',
                          '${widget.vehicle.maxSpeed} km/h',
                        ),
                      if (widget.vehicle.torque != null)
                        _SectionRow('Torque', widget.vehicle.torque!),
                      if (widget.vehicle.co2Emission != null)
                        _SectionRow(
                          'CO2 Emission',
                          '${widget.vehicle.co2Emission} g/km',
                        ),
                      if (widget.vehicle.emissionStandard != null)
                        _SectionRow(
                          'Emission Standard',
                          widget.vehicle.emissionStandard!,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Manufacturer & Production section
                  _buildSection(
                    title: 'Manufacturer',
                    rows: [
                      if (widget.vehicle.manufacturer != null)
                        _SectionRow(
                          'Manufacturer',
                          widget.vehicle.manufacturer!,
                        ),
                      if (widget.vehicle.manufacturerAddress != null)
                        _SectionRow(
                          'Manufacturer Address',
                          widget.vehicle.manufacturerAddress!,
                        ),
                      if (widget.vehicle.plantCity != null)
                        _SectionRow('Plant City', widget.vehicle.plantCity!),
                      if (widget.vehicle.plantCountry != null ||
                          widget.vehicle.countryOfOrigin != null)
                        _SectionRow(
                          'Plant Country',
                          widget.vehicle.plantCountry ??
                              widget.vehicle.countryOfOrigin!,
                        ),
                      if (widget.vehicle.productionStarted != null)
                        _SectionRow(
                          'Production Started',
                          widget.vehicle.productionStarted!,
                        ),
                      if (widget.vehicle.productionStopped != null)
                        _SectionRow(
                          'Production Stopped',
                          widget.vehicle.productionStopped!,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Additional Features section
                  _buildSection(
                    title: 'Additional Features',
                    rows: [
                      if (widget.vehicle.airConditioning != null)
                        _SectionRow(
                          'Air Conditioning',
                          widget.vehicle.airConditioning!,
                        ),
                      if (widget.vehicle.vehicleType != null)
                        _SectionRow(
                          'Vehicle Type',
                          widget.vehicle.vehicleType!,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hero section with vehicle image from SERP API
  Widget _buildHeroSection() {
    final isValid = widget.vehicle.isValidDecode;

    return GestureDetector(
      onTap: isValid
          ? () => Navigator.pushNamed(
              context,
              '/vehicle-view',
              arguments: {'vehicle': widget.vehicle},
            )
          : null,
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: const BoxDecoration(color: AppColors.surface),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image or placeholder
            if (_vehicleImageUrl != null)
              CachedNetworkImage(
                imageUrl: _vehicleImageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _buildImagePlaceholder(),
                errorWidget: (_, __, ___) => _buildImagePlaceholder(),
              )
            else if (_isLoadingImage)
              _buildImageLoading()
            else
              _buildImagePlaceholder(),

            // Gradient overlay for readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),

            // "View 360° & Parts" overlay
            Positioned(
              bottom: AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.vehicle.displayName,
                      style: AppTypography.h4.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isValid) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMedium,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.view_in_ar,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '360° & Parts',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageLoading() {
    return Container(
      color: AppColors.zinc100,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricBlue),
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.electricBlue.withValues(alpha: 0.8),
            AppColors.electricBlue,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.directions_car,
          size: 80,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  /// VIN display with copy functionality
  Widget _buildVinDisplay() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: AppColors.electricBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.pin, color: AppColors.electricBlue, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VIN',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.vehicle.vin,
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.electricBlue,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            color: AppColors.electricBlue,
            onPressed: () => _copyVin(context),
            tooltip: 'Copy VIN',
          ),
        ],
      ),
    );
  }

  /// Build a grouped section card with a title and key-value rows
  Widget _buildSection({
    required String title,
    required List<_SectionRow> rows,
  }) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              title,
              style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          // Key-value rows
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      row.label,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 3,
                    child: Text(
                      row.value,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  /// Copy VIN to clipboard
  void _copyVin(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.vehicle.vin));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('VIN copied to clipboard'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Toggle favorite status
  Future<void> _toggleFavorite() async {
    if (!_isInitialized) return;

    try {
      if (_isFavorite) {
        await _favoritesService.removeFavorite(widget.vehicle.vin);
      } else {
        await _favoritesService.addFavorite(widget.vehicle);
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite ? 'Added to favorites' : 'Removed from favorites',
            ),
            backgroundColor: AppColors.electricBlue,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorites: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Share vehicle details
  Future<void> _shareVehicle() async {
    final vehicle = widget.vehicle;

    final shareText = StringBuffer();
    shareText.writeln(vehicle.displayName);
    shareText.writeln('');
    shareText.writeln('VIN: ${vehicle.vin}');
    shareText.writeln('');

    if (vehicle.bodyStyle != null) {
      shareText.writeln('Body: ${vehicle.bodyStyle}');
    }
    if (vehicle.driveType != null) {
      shareText.writeln('Drive: ${vehicle.driveType}');
    }
    if (vehicle.engineType != null) {
      shareText.writeln('Engine: ${vehicle.engineType}');
    }
    if (vehicle.transmission != null) {
      shareText.writeln('Transmission: ${vehicle.transmission}');
    }
    if (vehicle.fuelType != null) {
      shareText.writeln('Fuel Type: ${vehicle.fuelType}');
    }
    if (vehicle.power != null) {
      shareText.writeln('Power: ${vehicle.power} HP');
    }
    if (vehicle.countryOfOrigin != null) {
      shareText.writeln('Origin: ${vehicle.countryOfOrigin}');
    }

    shareText.writeln('');
    shareText.writeln('Decoded with German Car Medic');

    try {
      await Share.share(shareText.toString(), subject: vehicle.displayName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

/// Simple data class for section rows
class _SectionRow {
  final String label;
  final String value;

  const _SectionRow(this.label, this.value);
}
