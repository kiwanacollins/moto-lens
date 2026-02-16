import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../styles/styles.dart';

/// User-friendly bottom sheet shown when part lookup fails.
/// Provides helpful suggestions and alternative actions.
class PartNotFoundSheet extends StatelessWidget {
  final String scannedValue;
  final VoidCallback? onTryAgain;
  final VoidCallback? onManualEntry;

  const PartNotFoundSheet({
    super.key,
    required this.scannedValue,
    this.onTryAgain,
    this.onManualEntry,
  });

  /// Show the "Part Not Found" sheet as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required String scannedValue,
    VoidCallback? onTryAgain,
    VoidCallback? onManualEntry,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PartNotFoundSheet(
        scannedValue: scannedValue,
        onTryAgain: onTryAgain,
        onManualEntry: onManualEntry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(context),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + Title
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.search_off_rounded,
                            size: 40,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'Part Not Found',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'We couldn\'t find information for this part number',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Scanned value display
                  _buildScannedValueCard(context),

                  const SizedBox(height: AppSpacing.xl),

                  // Suggestions
                  const Text(
                    'Try these suggestions:',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _buildSuggestion(
                    icon: Icons.camera_alt_outlined,
                    title: 'Check the barcode quality',
                    description:
                        'Ensure the barcode is clean and well-lit. Try scanning again.',
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  _buildSuggestion(
                    icon: Icons.edit_outlined,
                    title: 'Verify the part number',
                    description:
                        'The number might be printed elsewhere on the part. Look for OEM or manufacturer labels.',
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  _buildSuggestion(
                    icon: Icons.abc_outlined,
                    title: 'Try different formats',
                    description:
                        'Some parts use dashes (e.g., 11-427-566-327) or spaces. Try entering it manually.',
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  _buildSuggestion(
                    icon: Icons.support_agent_outlined,
                    title: 'Contact your supplier',
                    description:
                        'If the part is rare or aftermarket, your parts supplier may have specific information.',
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Action buttons
                  _buildActionButton(
                    context,
                    icon: Icons.refresh,
                    label: 'Try Again',
                    color: AppColors.electricBlue,
                    onPressed: () {
                      Navigator.pop(context);
                      onTryAgain?.call();
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  _buildActionButton(
                    context,
                    icon: Icons.keyboard_outlined,
                    label: 'Enter Part Number Manually',
                    color: AppColors.zinc700,
                    onPressed: () {
                      Navigator.pop(context);
                      onManualEntry?.call();
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  _buildActionButton(
                    context,
                    icon: Icons.close,
                    label: 'Cancel',
                    color: AppColors.zinc500,
                    outlined: true,
                    onPressed: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          const Spacer(),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.zinc300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildScannedValueCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.zinc50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.qr_code_2,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              const Text(
                'Scanned Value',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  scannedValue,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 20),
                color: AppColors.electricBlue,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: scannedValue));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: 'Copy to clipboard',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestion({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.electricBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.electricBlue),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    bool outlined = false,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 20),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 20),
              label: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                elevation: 1,
              ),
            ),
    );
  }
}
