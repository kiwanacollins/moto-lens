import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vehicle/vin_decode_result.dart';
import '../../models/vehicle_viewer.dart';
import '../../providers/vehicle_viewer_provider.dart';
import '../../styles/styles.dart';
import '../../widgets/vehicle_360_viewer.dart';
import '../../widgets/parts_grid.dart';
import '../../widgets/part_detail_sheet.dart';

/// Vehicle View Screen — orchestrates the 360° viewer + parts grid.
///
/// Mirrors the PWA's `VehicleViewPage`:
/// - Header with vehicle info
/// - 360° viewer (top, drag-to-rotate)
/// - Parts grid (bottom, filterable, tappable)
/// - Part detail bottom sheet on tap
class VehicleViewScreen extends StatefulWidget {
  final VinDecodeResult vehicle;

  const VehicleViewScreen({super.key, required this.vehicle});

  @override
  State<VehicleViewScreen> createState() => _VehicleViewScreenState();
}

class _VehicleViewScreenState extends State<VehicleViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadImages();
    });
  }

  Future<void> _loadImages() async {
    final provider = context.read<VehicleViewerProvider>();
    final v = widget.vehicle;

    // Prefer loading by VIN, fall back to make/model/year
    if (v.vin.isNotEmpty) {
      await provider.loadImages(v.vin);
    } else if (v.manufacturer != null && v.model != null && v.year != null) {
      await provider.loadImagesByData(
        make: v.manufacturer!,
        model: v.model!,
        year: v.year!,
      );
    }
  }

  String get _vehicleName {
    final parts = <String>[];
    if (widget.vehicle.year != null) parts.add(widget.vehicle.year!);
    if (widget.vehicle.manufacturer != null) {
      parts.add(widget.vehicle.manufacturer!);
    }
    if (widget.vehicle.model != null) parts.add(widget.vehicle.model!);
    return parts.join(' ');
  }

  Map<String, dynamic>? get _vehicleData {
    final v = widget.vehicle;
    if (v.manufacturer == null || v.model == null || v.year == null) {
      return null;
    }
    return {
      'make': v.manufacturer,
      'model': v.model,
      'year': int.tryParse(v.year!) ?? v.year,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.headerBar,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _vehicleName,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.vehicle.vin,
              style: AppTypography.codeSmall.copyWith(
                color: AppColors.electricBlue,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<VehicleViewerProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            color: AppColors.electricBlue,
            onRefresh: _loadImages,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),

                  // 360° Vehicle Viewer
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Vehicle360Viewer(
                      images: provider.images,
                      loading: provider.isLoadingImages,
                      vehicleName: _vehicleName,
                      height: 300,
                      dragSensitivity: 'medium',
                    ),
                  ),

                  // Error message
                  if (provider.imageError != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMedium,
                          ),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.warning,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                provider.imageError!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // Parts Grid
                  PartsGrid(
                    parts: provider.filteredParts,
                    selectedCategory: provider.activeCategory ?? 'All',
                    onCategoryChanged: (cat) => provider.setCategory(cat),
                    onPartTapped: (part) => _onPartTapped(part, provider),
                    loading: provider.isLoadingPart,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Bottom safe area padding
                  SizedBox(
                    height:
                        MediaQuery.of(context).padding.bottom + AppSpacing.lg,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onPartTapped(
    UniversalPart part,
    VehicleViewerProvider provider,
  ) async {
    // Show loading sheet immediately so the user knows something is happening
    if (!mounted) return;
    PartDetailSheet.showLoading(context, partName: part.name);

    await provider.selectPart(part, vehicleData: _vehicleData);

    if (!mounted) return;

    // Close the loading sheet
    Navigator.pop(context);

    // Show the actual details if available
    if (provider.selectedPartDetails != null) {
      PartDetailSheet.show(context, details: provider.selectedPartDetails!);
    } else if (provider.partError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load details: ${provider.partError}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
