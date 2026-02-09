import 'package:flutter/material.dart';
import '../styles/styles.dart';

/// Custom Button Widget
///
/// Professional, consistent buttons for German Car Medic
/// Supports multiple variants: primary, secondary, outline, text, destructive
/// Built with automotive precision and beautiful Electric Blue styling
class CustomButton extends StatelessWidget {
  /// Button text
  final String text;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button variant style
  final CustomButtonVariant variant;

  /// Button size
  final CustomButtonSize size;

  /// Full width button
  final bool isFullWidth;

  /// Loading state - shows spinner and disables button
  final bool isLoading;

  /// Icon to show before text
  final IconData? prefixIcon;

  /// Icon to show after text
  final IconData? suffixIcon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.size = CustomButtonSize.medium,
    this.isFullWidth = false,
    this.isLoading = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  /// Primary button constructor
  const CustomButton.primary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    CustomButtonSize size = CustomButtonSize.medium,
    bool isFullWidth = false,
    bool isLoading = false,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         variant: CustomButtonVariant.primary,
         size: size,
         isFullWidth: isFullWidth,
         isLoading: isLoading,
         prefixIcon: prefixIcon,
         suffixIcon: suffixIcon,
       );

  /// Secondary button constructor
  const CustomButton.secondary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    CustomButtonSize size = CustomButtonSize.medium,
    bool isFullWidth = false,
    bool isLoading = false,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         variant: CustomButtonVariant.secondary,
         size: size,
         isFullWidth: isFullWidth,
         isLoading: isLoading,
         prefixIcon: prefixIcon,
         suffixIcon: suffixIcon,
       );

  /// Outline button constructor
  const CustomButton.outline({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    CustomButtonSize size = CustomButtonSize.medium,
    bool isFullWidth = false,
    bool isLoading = false,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         variant: CustomButtonVariant.outline,
         size: size,
         isFullWidth: isFullWidth,
         isLoading: isLoading,
         prefixIcon: prefixIcon,
         suffixIcon: suffixIcon,
       );

  /// Text button constructor
  const CustomButton.text({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    CustomButtonSize size = CustomButtonSize.medium,
    bool isFullWidth = false,
    bool isLoading = false,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         variant: CustomButtonVariant.text,
         size: size,
         isFullWidth: isFullWidth,
         isLoading: isLoading,
         prefixIcon: prefixIcon,
         suffixIcon: suffixIcon,
       );

  /// Destructive button constructor
  const CustomButton.destructive({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    CustomButtonSize size = CustomButtonSize.medium,
    bool isFullWidth = false,
    bool isLoading = false,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         variant: CustomButtonVariant.destructive,
         size: size,
         isFullWidth: isFullWidth,
         isLoading: isLoading,
         prefixIcon: prefixIcon,
         suffixIcon: suffixIcon,
       );

  /// Auth button constructor
  const CustomButton.auth({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    CustomButtonSize size = CustomButtonSize.medium,
    bool isFullWidth = false,
    bool isLoading = false,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         variant: CustomButtonVariant.auth,
         size: size,
         isFullWidth: isFullWidth,
         isLoading: isLoading,
         prefixIcon: prefixIcon,
         suffixIcon: suffixIcon,
       );

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    // Build button content with optional icons and loading spinner
    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixIcon != null && !isLoading) ...[
          Icon(prefixIcon, size: _getIconSize()),
          const SizedBox(width: AppSpacing.xs),
        ],

        if (isLoading) ...[
          SizedBox(
            width: _getIconSize(),
            height: _getIconSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor()),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],

        Text(text, style: _getTextStyle(), textAlign: TextAlign.center),

        if (suffixIcon != null && !isLoading) ...[
          const SizedBox(width: AppSpacing.xs),
          Icon(suffixIcon, size: _getIconSize()),
        ],
      ],
    );

    // Wrap in full width if needed
    if (isFullWidth) {
      buttonContent = SizedBox(width: double.infinity, child: buttonContent);
    }

    // Build the appropriate button type
    switch (variant) {
      case CustomButtonVariant.primary:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: _getPrimaryButtonStyle(context),
          child: buttonContent,
        );

      case CustomButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: _getSecondaryButtonStyle(context),
          child: buttonContent,
        );

      case CustomButtonVariant.outline:
        return OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: _getOutlineButtonStyle(context),
          child: buttonContent,
        );

      case CustomButtonVariant.text:
        return TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: _getTextButtonStyle(context),
          child: buttonContent,
        );

      case CustomButtonVariant.destructive:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: _getDestructiveButtonStyle(context),
          child: buttonContent,
        );

      case CustomButtonVariant.auth:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: _getAuthButtonStyle(context),
          child: buttonContent,
        );
    }
  }

  /// Get button text style based on size
  TextStyle _getTextStyle() {
    switch (size) {
      case CustomButtonSize.small:
        return AppTypography.buttonSmall;
      case CustomButtonSize.medium:
        return AppTypography.buttonMedium;
      case CustomButtonSize.large:
        return AppTypography.buttonLarge;
    }
  }

  /// Get icon size based on button size
  double _getIconSize() {
    switch (size) {
      case CustomButtonSize.small:
        return 16.0;
      case CustomButtonSize.medium:
        return 20.0;
      case CustomButtonSize.large:
        return 24.0;
    }
  }

  /// Get loading spinner color based on variant
  Color _getLoadingColor() {
    switch (variant) {
      case CustomButtonVariant.primary:
      case CustomButtonVariant.destructive:
      case CustomButtonVariant.auth:
        return Colors.white;
      case CustomButtonVariant.secondary:
      case CustomButtonVariant.outline:
      case CustomButtonVariant.text:
        return AppColors.electricBlue;
    }
  }

  /// Get button padding based on size
  EdgeInsets _getPadding() {
    switch (size) {
      case CustomButtonSize.small:
        return AppSpacing.symmetric(
          horizontal: AppSpacing.buttonSmallPaddingHorizontal,
          vertical: AppSpacing.buttonSmallPaddingVertical,
        );
      case CustomButtonSize.medium:
        return AppSpacing.buttonPaddingEdgeInsets;
      case CustomButtonSize.large:
        return AppSpacing.symmetric(
          horizontal: AppSpacing.buttonLargePaddingHorizontal,
          vertical: AppSpacing.buttonLargePaddingVertical,
        );
    }
  }

  /// Button style for primary variant
  ButtonStyle _getPrimaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.electricBlue,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.zinc300,
      disabledForegroundColor: AppColors.textDisabled,
      textStyle: _getTextStyle(),
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      elevation: AppSpacing.elevationLow,
      shadowColor: AppColors.electricBlue.withOpacity(0.3),
    );
  }

  /// Button style for secondary variant
  ButtonStyle _getSecondaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.gunmetalGray,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.zinc300,
      disabledForegroundColor: AppColors.textDisabled,
      textStyle: _getTextStyle(),
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      elevation: AppSpacing.elevationLow,
      shadowColor: AppColors.gunmetalGray.withOpacity(0.3),
    );
  }

  /// Button style for outline variant
  ButtonStyle _getOutlineButtonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.electricBlue,
      disabledForegroundColor: AppColors.textDisabled,
      textStyle: _getTextStyle(),
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      side: const BorderSide(color: AppColors.electricBlue, width: 1.5),
    );
  }

  /// Button style for text variant
  ButtonStyle _getTextButtonStyle(BuildContext context) {
    return TextButton.styleFrom(
      foregroundColor: AppColors.electricBlue,
      disabledForegroundColor: AppColors.textDisabled,
      textStyle: _getTextStyle(),
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
    );
  }

  /// Button style for destructive variant
  ButtonStyle _getDestructiveButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.error,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.zinc300,
      disabledForegroundColor: AppColors.textDisabled,
      textStyle: _getTextStyle(),
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      elevation: AppSpacing.elevationLow,
      shadowColor: AppColors.error.withOpacity(0.3),
    );
  }

  /// Button style for auth variant
  ButtonStyle _getAuthButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.authButton,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.zinc300,
      disabledForegroundColor: AppColors.textDisabled,
      textStyle: _getTextStyle(),
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      elevation: AppSpacing.elevationLow,
      shadowColor: AppColors.authButton.withOpacity(0.3),
    );
  }
}

/// Button variant enum
enum CustomButtonVariant {
  primary,
  secondary,
  outline,
  text,
  destructive,
  auth,
}

/// Button size enum
enum CustomButtonSize { small, medium, large }
