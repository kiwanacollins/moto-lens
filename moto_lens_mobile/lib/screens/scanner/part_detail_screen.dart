import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/part_scan_entry.dart';
import '../../providers/qr_scan_provider.dart';
import '../../styles/styles.dart';

/// Displays full details for a scanned part.
///
/// Reads [QrScanProvider.currentPartDetails] and renders the part
/// image, description, function, symptoms, and part number.
class PartDetailScreen extends StatelessWidget {
  const PartDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QrScanProvider>(
      builder: (context, provider, _) {
        final details = provider.currentPartDetails;

        if (details == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Part Details'),
              backgroundColor: AppColors.headerBar,
              foregroundColor: Colors.white,
            ),
            body: const Center(child: Text('No part data available.')),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // App bar with optional image
              _buildSliverAppBar(context, details),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Part name & number header
                      _buildHeader(context, details),
                      const SizedBox(height: AppSpacing.lg),

                      // Vehicle context
                      if (details.vehicleLabel.isNotEmpty) ...[
                        _buildSection(
                          icon: Icons.directions_car,
                          title: 'Vehicle',
                          child: Text(
                            details.vehicleLabel,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Description
                      if (details.description != null &&
                          details.description!.isNotEmpty) ...[
                        _buildSection(
                          icon: Icons.description_outlined,
                          title: 'Description',
                          child: Text(
                            details.description!,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Function
                      if (details.function != null &&
                          details.function!.isNotEmpty) ...[
                        _buildSection(
                          icon: Icons.build_outlined,
                          title: 'Function',
                          child: Text(
                            details.function!,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Symptoms
                      if (details.symptoms.isNotEmpty) ...[
                        _buildSection(
                          icon: Icons.warning_amber_outlined,
                          title: 'Common Symptoms',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: details.symptoms
                                .map((s) => _buildSymptomTile(s))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Part number (copyable)
                      if (details.partNumber != null &&
                          details.partNumber!.isNotEmpty) ...[
                        _buildSection(
                          icon: Icons.tag,
                          title: 'Part Number',
                          child: _buildPartNumberChip(
                            context,
                            details.partNumber!,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      const SizedBox(height: AppSpacing.xl),

                      // Scan another button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.qr_code_scanner, size: 22),
                          label: const Text(
                            'Scan Another Part',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.electricBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMedium,
                              ),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Sliver app bar with image
  // ---------------------------------------------------------------------------

  Widget _buildSliverAppBar(BuildContext context, PartDetails details) {
    final hasImage = details.imageUrl != null && details.imageUrl!.isNotEmpty;

    return SliverAppBar(
      expandedHeight: hasImage ? 260 : 0,
      pinned: true,
      backgroundColor: AppColors.headerBar,
      foregroundColor: Colors.white,
      title: Text(
        details.partName,
        style: AppTypography.h4.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      flexibleSpace: hasImage
          ? FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    details.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.zinc800,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.zinc500,
                        size: 48,
                      ),
                    ),
                  ),
                  // Gradient scrim for text readability
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader(BuildContext context, PartDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          details.partName,
          style: AppTypography.h2.copyWith(fontWeight: FontWeight.bold),
        ),
        if (details.partNumber != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(details.partNumber!, style: AppTypography.partNumber),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section wrapper
  // ---------------------------------------------------------------------------

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.electricBlue),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: AppTypography.h6.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Symptom tile
  // ---------------------------------------------------------------------------

  Widget _buildSymptomTile(String symptom) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7, right: AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              symptom,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Part number chip (copyable)
  // ---------------------------------------------------------------------------

  Widget _buildPartNumberChip(BuildContext context, String partNumber) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: partNumber));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Part number copied to clipboard'),
            backgroundColor: AppColors.electricBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.electricBlue.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color: AppColors.electricBlue.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(partNumber, style: AppTypography.codeLarge),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.copy,
              size: 16,
              color: AppColors.electricBlue.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
