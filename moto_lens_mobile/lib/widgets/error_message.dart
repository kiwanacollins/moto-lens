import 'package:flutter/material.dart';
import '../styles/styles.dart';

/// Error Message Widget
///
/// Professional, consistent error handling for MotoLens
/// Supports different error types, retry functionality, and automotive context
/// Built with clear messaging and helpful recovery actions
class ErrorMessage extends StatelessWidget {
  /// Error message text
  final String message;

  /// Error type for styling and icon selection
  final ErrorMessageType type;

  /// Optional retry callback
  final VoidCallback? onRetry;

  /// Retry button text
  final String retryText;

  /// Whether to show as card (with background)
  final bool showAsCard;

  /// Custom icon to override default
  final IconData? customIcon;

  /// Additional description text
  final String? description;

  const ErrorMessage({
    super.key,
    required this.message,
    this.type = ErrorMessageType.general,
    this.onRetry,
    this.retryText = 'Retry',
    this.showAsCard = false,
    this.customIcon,
    this.description,
  });

  /// Network error constructor
  const ErrorMessage.network({
    Key? key,
    String message = 'Network connection failed',
    String? description =
        'Please check your internet connection and try again.',
    VoidCallback? onRetry,
    String retryText = 'Retry',
    bool showAsCard = false,
  }) : this(
         key: key,
         message: message,
         description: description,
         type: ErrorMessageType.network,
         onRetry: onRetry,
         retryText: retryText,
         showAsCard: showAsCard,
       );

  /// Validation error constructor
  const ErrorMessage.validation({
    Key? key,
    required String message,
    String? description,
    bool showAsCard = false,
  }) : this(
         key: key,
         message: message,
         description: description,
         type: ErrorMessageType.validation,
         showAsCard: showAsCard,
       );

  /// VIN error constructor
  const ErrorMessage.vin({
    Key? key,
    String message = 'Invalid VIN number',
    String? description = 'Please enter a valid 17-character VIN number.',
    VoidCallback? onRetry,
    String retryText = 'Try Again',
    bool showAsCard = false,
  }) : this(
         key: key,
         message: message,
         description: description,
         type: ErrorMessageType.vin,
         onRetry: onRetry,
         retryText: retryText,
         showAsCard: showAsCard,
       );

  /// Auth error constructor
  const ErrorMessage.auth({
    Key? key,
    String message = 'Authentication failed',
    String? description = 'Please check your credentials and try again.',
    VoidCallback? onRetry,
    String retryText = 'Retry',
    bool showAsCard = false,
  }) : this(
         key: key,
         message: message,
         description: description,
         type: ErrorMessageType.auth,
         onRetry: onRetry,
         retryText: retryText,
         showAsCard: showAsCard,
       );

  /// Server error constructor
  const ErrorMessage.server({
    Key? key,
    String message = 'Server error occurred',
    String? description =
        'Something went wrong on our end. Please try again later.',
    VoidCallback? onRetry,
    String retryText = 'Retry',
    bool showAsCard = true,
  }) : this(
         key: key,
         message: message,
         description: description,
         type: ErrorMessageType.server,
         onRetry: onRetry,
         retryText: retryText,
         showAsCard: showAsCard,
       );

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();

    if (showAsCard) {
      return Card(
        margin: const EdgeInsets.all(AppSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: content,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: content,
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Error icon
        Icon(_getErrorIcon(), size: 48, color: _getErrorColor()),

        const SizedBox(height: AppSpacing.md),

        // Error message
        Text(
          message,
          style: AppTypography.h5.copyWith(color: _getErrorColor()),
          textAlign: TextAlign.center,
        ),

        // Description text
        if (description != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            description!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        // Retry button
        if (onRetry != null) ...[
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getErrorColor(),
              foregroundColor: Colors.white,
            ),
            child: Text(retryText),
          ),
        ],
      ],
    );
  }

  IconData _getErrorIcon() {
    if (customIcon != null) {
      return customIcon!;
    }

    switch (type) {
      case ErrorMessageType.network:
        return Icons.wifi_off;
      case ErrorMessageType.validation:
        return Icons.error_outline;
      case ErrorMessageType.vin:
        return Icons.no_crash;
      case ErrorMessageType.auth:
        return Icons.lock_outline;
      case ErrorMessageType.server:
        return Icons.cloud_off;
      case ErrorMessageType.general:
        return Icons.error_outline;
    }
  }

  Color _getErrorColor() {
    switch (type) {
      case ErrorMessageType.network:
        return AppColors.warning;
      case ErrorMessageType.validation:
        return AppColors.error;
      case ErrorMessageType.vin:
        return AppColors.electricBlue;
      case ErrorMessageType.auth:
        return AppColors.error;
      case ErrorMessageType.server:
        return AppColors.error;
      case ErrorMessageType.general:
        return AppColors.error;
    }
  }
}

/// Inline Error Message
///
/// Compact error message for form fields and inline validation
/// Designed to fit within form layouts without disrupting flow
class InlineErrorMessage extends StatelessWidget {
  /// Error message text
  final String message;

  /// Optional icon
  final IconData? icon;

  /// Whether to show with background
  final bool showBackground;

  const InlineErrorMessage({
    super.key,
    required this.message,
    this.icon,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: AppColors.error),
          const SizedBox(width: AppSpacing.xxs),
        ],
        Expanded(
          child: Text(
            message,
            style: AppTypography.inputError,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    if (showBackground) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          border: Border.all(color: AppColors.error.withOpacity(0.3), width: 1),
        ),
        child: content,
      );
    }

    return content;
  }
}

/// Empty State Message
///
/// Message for when no data is available or empty states
/// Provides clear feedback and optional call-to-action
class EmptyStateMessage extends StatelessWidget {
  /// Main message
  final String title;

  /// Description text
  final String? description;

  /// Action button text
  final String? actionText;

  /// Action button callback
  final VoidCallback? onAction;

  /// Icon to display
  final IconData? icon;

  /// Custom illustration widget
  final Widget? illustration;

  const EmptyStateMessage({
    super.key,
    required this.title,
    this.description,
    this.actionText,
    this.onAction,
    this.icon,
    this.illustration,
  });

  /// No VIN results constructor
  const EmptyStateMessage.noVinResults({
    Key? key,
    String title = 'No vehicle found',
    String? description =
        'No vehicle information found for this VIN. Please check the VIN and try again.',
    String? actionText = 'Try Another VIN',
    VoidCallback? onAction,
  }) : this(
         key: key,
         title: title,
         description: description,
         actionText: actionText,
         onAction: onAction,
         icon: Icons.search_off,
       );

  /// No parts found constructor
  const EmptyStateMessage.noParts({
    Key? key,
    String title = 'No parts found',
    String? description =
        'No parts match your search criteria. Try adjusting your search terms.',
    String? actionText = 'Clear Search',
    VoidCallback? onAction,
  }) : this(
         key: key,
         title: title,
         description: description,
         actionText: actionText,
         onAction: onAction,
         icon: Icons.build_outlined,
       );

  /// No internet constructor
  const EmptyStateMessage.noInternet({
    Key? key,
    String title = 'No internet connection',
    String? description =
        'Please check your internet connection and try again.',
    String? actionText = 'Retry',
    VoidCallback? onAction,
  }) : this(
         key: key,
         title: title,
         description: description,
         actionText: actionText,
         onAction: onAction,
         icon: Icons.wifi_off,
       );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration or icon
          if (illustration != null)
            illustration!
          else if (icon != null)
            Icon(icon, size: 64, color: AppColors.textDisabled),

          const SizedBox(height: AppSpacing.lg),

          // Title
          Text(
            title,
            style: AppTypography.h4.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),

          // Description
          if (description != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              description!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Action button
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(onPressed: onAction, child: Text(actionText!)),
          ],
        ],
      ),
    );
  }
}

/// Error message type enum
enum ErrorMessageType { general, network, validation, vin, auth, server }
