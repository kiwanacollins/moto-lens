import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/vehicle/vin_decode_result.dart';
import '../../services/favorites_service.dart';
import '../../styles/styles.dart';

/// Vehicle Detail Screen - Displays decoded VIN information
///
/// Shows comprehensive vehicle information including:
/// - Make, Model, Year (prominent)
/// - Engine, Body Type, Trim
/// - VIN display with copy functionality
/// - Vehicle specifications
class VehicleDetailScreen extends StatefulWidget {
  final VinDecodeResult vehicle;

  const VehicleDetailScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  bool _isFavorite = false;
  late FavoritesService _favoritesService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeFavorites();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Vehicle Details',
          style: AppTypography.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.electricBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareVehicle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section with vehicle image placeholder
            _buildHeroSection(),

            // Main vehicle information
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Make, Model, Year (large, prominent)
                  _buildVehicleTitle(),
                  const SizedBox(height: AppSpacing.md),

                  // VIN display with copy button
                  _buildVinDisplay(),
                  const SizedBox(height: AppSpacing.xl),

                  // Specifications grid
                  _buildSpecificationsGrid(),
                  const SizedBox(height: AppSpacing.xl),

                  // Additional details
                  _buildAdditionalDetails(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hero section with vehicle image
  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.electricBlue,
            AppColors.electricBlue.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              size: 80,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Vehicle Image',
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            Text(
              'Coming Soon',
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Large, prominent vehicle title
  Widget _buildVehicleTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Manufacturer
        if (widget.vehicle.manufacturer != null)
          Text(
            widget.vehicle.manufacturer!.toUpperCase(),
            style: AppTypography.h5.copyWith(
              color: AppColors.electricBlue,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        const SizedBox(height: AppSpacing.xs),

        // Model and Year
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                widget.vehicle.model ?? 'Unknown Model',
                style: AppTypography.h1.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ),
            if (widget.vehicle.year != null)
              Text(
                widget.vehicle.year!,
                style: AppTypography.h2.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),

        // Trim (if available)
        if (widget.vehicle.trim != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.vehicle.trim!,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  /// VIN display with copy functionality
  Widget _buildVinDisplay() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.electricBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.pin,
            color: AppColors.electricBlue,
            size: 20,
          ),
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

  /// Specifications grid (Engine, Body Type, etc.)
  Widget _buildSpecificationsGrid() {
    final specs = [
      if (widget.vehicle.engineType != null)
        _SpecItem(
          icon: Icons.speed,
          label: 'Engine',
          value: widget.vehicle.engineType!,
        ),
      if (widget.vehicle.bodyStyle != null)
        _SpecItem(
          icon: Icons.directions_car_outlined,
          label: 'Body Style',
          value: widget.vehicle.bodyStyle!,
        ),
      if (widget.vehicle.transmission != null)
        _SpecItem(
          icon: Icons.settings,
          label: 'Transmission',
          value: widget.vehicle.transmission!,
        ),
      if (widget.vehicle.fuelType != null)
        _SpecItem(
          icon: Icons.local_gas_station,
          label: 'Fuel Type',
          value: widget.vehicle.fuelType!,
        ),
      if (widget.vehicle.driveType != null)
        _SpecItem(
          icon: Icons.compare_arrows,
          label: 'Drive Type',
          value: widget.vehicle.driveType!,
        ),
      if (widget.vehicle.displacement != null)
        _SpecItem(
          icon: Icons.straighten,
          label: 'Displacement',
          value: '${widget.vehicle.displacement}L',
        ),
      if (widget.vehicle.power != null)
        _SpecItem(
          icon: Icons.bolt,
          label: 'Power',
          value: '${widget.vehicle.power} HP',
        ),
    ];

    if (specs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specifications',
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 2.5,
          ),
          itemCount: specs.length,
          itemBuilder: (context, index) => _buildSpecCard(specs[index]),
        ),
      ],
    );
  }

  /// Individual specification card
  Widget _buildSpecCard(_SpecItem spec) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            spec.icon,
            size: 20,
            color: AppColors.electricBlue,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  spec.label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  spec.value,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Additional details section
  Widget _buildAdditionalDetails() {
    final details = <Widget>[];

    if (widget.vehicle.series != null) {
      details.add(_buildDetailRow('Series', widget.vehicle.series!));
    }
    if (widget.vehicle.countryOfOrigin != null) {
      details.add(_buildDetailRow('Country of Origin', widget.vehicle.countryOfOrigin!));
    }
    if (widget.vehicle.plantCity != null) {
      details.add(_buildDetailRow('Plant City', widget.vehicle.plantCity!));
    }

    if (details.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Information',
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: details,
          ),
        ),
      ],
    );
  }

  /// Detail row for additional information
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
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
        // Remove from favorites
        await _favoritesService.removeFavorite(widget.vehicle.vin);
      } else {
        // Add to favorites
        await _favoritesService.addFavorite(widget.vehicle);
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite
                  ? 'Added to favorites'
                  : 'Removed from favorites',
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

    // Build comprehensive share text
    final shareText = StringBuffer();
    shareText.writeln('🚗 ${vehicle.displayName}');
    shareText.writeln('');
    shareText.writeln('VIN: ${vehicle.vin}');
    shareText.writeln('');

    // Add specifications
    if (vehicle.engineType != null) {
      shareText.writeln('Engine: ${vehicle.engineType}');
    }
    if (vehicle.bodyStyle != null) {
      shareText.writeln('Body Style: ${vehicle.bodyStyle}');
    }
    if (vehicle.transmission != null) {
      shareText.writeln('Transmission: ${vehicle.transmission}');
    }
    if (vehicle.fuelType != null) {
      shareText.writeln('Fuel Type: ${vehicle.fuelType}');
    }
    if (vehicle.driveType != null) {
      shareText.writeln('Drive Type: ${vehicle.driveType}');
    }
    if (vehicle.displacement != null) {
      shareText.writeln('Displacement: ${vehicle.displacement}L');
    }
    if (vehicle.power != null) {
      shareText.writeln('Power: ${vehicle.power} HP');
    }

    shareText.writeln('');
    shareText.writeln('Decoded with German Car Medic');

    try {
      await Share.share(
        shareText.toString(),
        subject: vehicle.displayName,
      );
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

/// Specification item data class
class _SpecItem {
  final IconData icon;
  final String label;
  final String value;

  const _SpecItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
