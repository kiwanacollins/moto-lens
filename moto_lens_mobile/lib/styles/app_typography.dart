import 'package:flutter/material.dart';
import 'app_colors.dart';

/// MotoLens Typography System
///
/// Professional font system matching React PWA design
/// Fonts: Inter (primary), JetBrains Mono (code/technical)
class AppTypography {
  // Private constructor to prevent instantiation
  AppTypography._();

  /// ==================== FONT FAMILIES ====================

  /// Primary font family - Inter
  /// Used for: UI text, body content, navigation
  static const String primaryFontFamily = 'Inter';

  /// Monospace font family - JetBrains Mono
  /// Used for: VIN numbers, codes, technical data
  static const String monoFontFamily = 'JetBrains Mono';

  /// ==================== FONT WEIGHT CONSTANTS ====================

  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  /// ==================== HEADING STYLES ====================

  /// H1 - Page titles, main headings
  static const TextStyle h1 = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 32,
    fontWeight: bold,
    letterSpacing: -0.02,
    height: 1.2,
    color: AppColors.carbonBlack,
  );

  /// H2 - Section headings
  static const TextStyle h2 = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 24,
    fontWeight: semiBold,
    letterSpacing: -0.02,
    height: 1.3,
    color: AppColors.carbonBlack,
  );

  /// H3 - Subsection headings
  static const TextStyle h3 = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 20,
    fontWeight: semiBold,
    letterSpacing: -0.01,
    height: 1.4,
    color: AppColors.carbonBlack,
  );

  /// H4 - Card titles, smaller headings
  static const TextStyle h4 = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 18,
    fontWeight: medium,
    letterSpacing: -0.01,
    height: 1.4,
    color: AppColors.carbonBlack,
  );

  /// H5 - Component titles
  static const TextStyle h5 = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: medium,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.carbonBlack,
  );

  /// H6 - Small titles, labels
  static const TextStyle h6 = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.carbonBlack,
  );

  /// ==================== BODY TEXT STYLES ====================

  /// Body Large - Main content, descriptions
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: regular,
    letterSpacing: 0,
    height: 1.6,
    color: AppColors.carbonBlack,
  );

  /// Body Medium - Secondary content
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: regular,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.carbonBlack,
  );

  /// Body Small - Supporting text, captions
  static const TextStyle bodySmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: regular,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  /// ==================== BUTTON STYLES ====================

  /// Button Large - Primary action buttons
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: semiBold,
    letterSpacing: 0,
    height: 1.2,
  );

  /// Button Medium - Standard buttons
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0,
    height: 1.2,
  );

  /// Button Small - Compact buttons
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: 0,
    height: 1.2,
  );

  /// ==================== FORM & INPUT STYLES ====================

  /// Input Field Text
  static const TextStyle inputText = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: regular,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.carbonBlack,
  );

  /// Input Label
  static const TextStyle inputLabel = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  /// Input Placeholder
  static const TextStyle inputPlaceholder = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: regular,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.textDisabled,
  );

  /// Input Error
  static const TextStyle inputError = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: regular,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.error,
  );

  /// ==================== MONOSPACE STYLES ====================

  /// Code/Technical Large - VIN numbers, main technical data
  static const TextStyle codeLarge = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 16,
    fontWeight: medium,
    letterSpacing: 0.5,
    height: 1.4,
    color: AppColors.carbonBlack,
  );

  /// Code/Technical Medium - Part numbers, IDs
  static const TextStyle codeMedium = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 14,
    fontWeight: regular,
    letterSpacing: 0.3,
    height: 1.4,
    color: AppColors.carbonBlack,
  );

  /// Code/Technical Small - Technical details
  static const TextStyle codeSmall = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 12,
    fontWeight: regular,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  /// ==================== SPECIALIZED STYLES ====================

  /// Navigation text
  static const TextStyle navigation = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  /// Tab text
  static const TextStyle tab = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0,
    height: 1.4,
  );

  /// Badge text
  static const TextStyle badge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: semiBold,
    letterSpacing: 0.3,
    height: 1.2,
  );

  /// Chip text
  static const TextStyle chip = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: 0,
    height: 1.2,
  );

  /// ==================== AUTOMOTIVE-SPECIFIC STYLES ====================

  /// VIN Display - Large, prominent VIN numbers
  static const TextStyle vinDisplay = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 20,
    fontWeight: semiBold,
    letterSpacing: 1.0,
    height: 1.3,
    color: AppColors.carbonBlack,
  );

  /// Part Number - Part identification numbers
  static const TextStyle partNumber = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.5,
    height: 1.4,
    color: AppColors.electricBlue,
  );

  /// Vehicle Info - Car model, year, specs
  static const TextStyle vehicleInfo = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: medium,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.carbonBlack,
  );

  /// ==================== UTILITY METHODS ====================

  /// Apply color to text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply weight to text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Apply size to text style
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Apply opacity to text style
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withOpacity(opacity));
  }

  /// Create responsive text style based on screen size
  static TextStyle responsive(
    BuildContext context,
    TextStyle baseStyle, {
    double? mobileScale,
    double? tabletScale,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      // Mobile
      final scale = mobileScale ?? 0.9;
      return baseStyle.copyWith(fontSize: (baseStyle.fontSize ?? 14) * scale);
    } else if (screenWidth < 1200) {
      // Tablet
      final scale = tabletScale ?? 0.95;
      return baseStyle.copyWith(fontSize: (baseStyle.fontSize ?? 14) * scale);
    }

    // Desktop - use base style
    return baseStyle;
  }
}

/// Text Theme for Material App
class AppTextTheme {
  static TextTheme get textTheme => const TextTheme(
    // Display styles
    displayLarge: AppTypography.h1,
    displayMedium: AppTypography.h2,
    displaySmall: AppTypography.h3,

    // Headline styles
    headlineLarge: AppTypography.h2,
    headlineMedium: AppTypography.h3,
    headlineSmall: AppTypography.h4,

    // Title styles
    titleLarge: AppTypography.h4,
    titleMedium: AppTypography.h5,
    titleSmall: AppTypography.h6,

    // Body styles
    bodyLarge: AppTypography.bodyLarge,
    bodyMedium: AppTypography.bodyMedium,
    bodySmall: AppTypography.bodySmall,

    // Label styles
    labelLarge: AppTypography.buttonLarge,
    labelMedium: AppTypography.buttonMedium,
    labelSmall: AppTypography.buttonSmall,
  );
}
