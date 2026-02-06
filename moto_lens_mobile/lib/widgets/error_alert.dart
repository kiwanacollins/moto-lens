import 'package:flutter/material.dart';
import '../styles/styles.dart';
import '../utils/error_handler.dart';

/// User-friendly error alert widget
///
/// Displays errors with clear messages and helpful suggestions
class ErrorAlert extends StatelessWidget {
  final dynamic error;
  final String? title;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showSuggestions;

  const ErrorAlert({
    super.key,
    required this.error,
    this.title,
    this.onRetry,
    this.onDismiss,
    this.showSuggestions = true,
  });

  @override
  Widget build(BuildContext context) {
    final errorMessage = ErrorHandler.getUserFriendlyMessage(error);
    final suggestions = showSuggestions
        ? ErrorHandler.getSuggestion(error)
        : null;
    final isNetworkError = ErrorHandler.isNetworkError(error);
    final canRetry = ErrorHandler.shouldRetry(error);

    return Card(
      elevation: 2,
      color: AppColors.error.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        side: BorderSide(color: AppColors.error, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and icon
            Row(
              children: [
                Icon(
                  isNetworkError ? Icons.wifi_off : Icons.error_outline,
                  color: AppColors.error,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title ?? (isNetworkError ? 'Connection Error' : 'Error'),
                    style: AppTypography.h3.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: AppColors.textSecondary,
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // Error message
            Text(
              errorMessage,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),

            // Suggestions
            if (suggestions != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.electricBlue,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        suggestions,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action buttons
            if (canRetry && onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                      horizontal: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusSmall,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Simple error snackbar
class ErrorSnackBar {
  static void show(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
  }) {
    final errorMessage = ErrorHandler.getUserFriendlyMessage(error);
    final canRetry = ErrorHandler.shouldRetry(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              ErrorHandler.isNetworkError(error)
                  ? Icons.wifi_off
                  : Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                errorMessage,
                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
        action: canRetry && onRetry != null
            ? SnackBarAction(
                label: 'RETRY',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}

/// Error dialog
class ErrorDialog {
  static Future<void> show(
    BuildContext context,
    dynamic error, {
    String? title,
    VoidCallback? onRetry,
  }) async {
    final errorMessage = ErrorHandler.getUserFriendlyMessage(error);
    final suggestions = ErrorHandler.getSuggestion(error);
    final isNetworkError = ErrorHandler.isNetworkError(error);
    final canRetry = ErrorHandler.shouldRetry(error);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          title: Row(
            children: [
              Icon(
                isNetworkError ? Icons.wifi_off : Icons.error_outline,
                color: AppColors.error,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title ?? (isNetworkError ? 'Connection Error' : 'Error'),
                  style: AppTypography.h3.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(errorMessage, style: AppTypography.bodyMedium),
              if (suggestions != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    border: Border.all(
                      color: AppColors.electricBlue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.electricBlue,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          suggestions,
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (canRetry && onRetry != null)
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.electricBlue,
                ),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
