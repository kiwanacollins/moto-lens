import 'package:flutter/material.dart';

/// German Car Medic Spacing System
///
/// Consistent spacing and layout constants for professional UI
/// Based on 8px grid system for perfect alignment
class AppSpacing {
  // Private constructor to prevent instantiation
  AppSpacing._();

  /// ==================== BASE SPACING UNITS ====================

  /// Base unit - 8px
  static const double base = 8.0;

  /// Extra extra small - 4px
  static const double xxs = base * 0.5; // 4px

  /// Extra small - 8px
  static const double xs = base; // 8px

  /// Small - 12px
  static const double sm = base * 1.5; // 12px

  /// Medium - 16px
  static const double md = base * 2; // 16px

  /// Large - 24px
  static const double lg = base * 3; // 24px

  /// Extra large - 32px
  static const double xl = base * 4; // 32px

  /// Extra extra large - 48px
  static const double xxl = base * 6; // 48px

  /// Extra extra extra large - 64px
  static const double xxxl = base * 8; // 64px

  /// ==================== COMPONENT SPACING ====================

  /// Button padding
  static const double buttonPaddingVertical = sm; // 12px
  static const double buttonPaddingHorizontal = lg; // 24px

  /// Small button padding
  static const double buttonSmallPaddingVertical = xs; // 8px
  static const double buttonSmallPaddingHorizontal = md; // 16px

  /// Large button padding
  static const double buttonLargePaddingVertical = md; // 16px
  static const double buttonLargePaddingHorizontal = xl; // 32px

  /// Input field padding
  static const double inputPaddingVertical = sm; // 12px
  static const double inputPaddingHorizontal = md; // 16px

  /// Card padding
  static const double cardPadding = md; // 16px
  static const double cardPaddingLarge = lg; // 24px

  /// List item padding
  static const double listItemPadding = md; // 16px

  /// Icon margins
  static const double iconMargin = xs; // 8px

  /// Chip padding
  static const double chipPaddingVertical = xxs; // 4px
  static const double chipPaddingHorizontal = sm; // 12px

  /// ==================== LAYOUT SPACING ====================

  /// Screen padding (outer margins)
  static const double screenPadding = md; // 16px
  static const double screenPaddingLarge = lg; // 24px

  /// Section spacing (between major sections)
  static const double sectionSpacing = xl; // 32px
  static const double sectionSpacingLarge = xxl; // 48px

  /// Element spacing (between related elements)
  static const double elementSpacing = md; // 16px
  static const double elementSpacingSmall = xs; // 8px
  static const double elementSpacingLarge = lg; // 24px

  /// Content spacing (between content blocks)
  static const double contentSpacing = lg; // 24px

  /// ==================== FORM SPACING ====================

  /// Form field spacing
  static const double formFieldSpacing = md; // 16px
  static const double formFieldSpacingLarge = lg; // 24px

  /// Form group spacing
  static const double formGroupSpacing = lg; // 24px

  /// Form section spacing
  static const double formSectionSpacing = xl; // 32px

  /// Label to input spacing
  static const double labelInputSpacing = xxs; // 4px

  /// Error message spacing
  static const double errorMessageSpacing = xxs; // 4px

  /// ==================== NAVIGATION SPACING ====================

  /// App bar height
  static const double appBarHeight = 56.0;

  /// Bottom navigation height
  static const double bottomNavHeight = 56.0;

  /// Navigation padding
  static const double navigationPadding = md; // 16px

  /// Tab bar padding
  static const double tabBarPadding = xs; // 8px

  /// ==================== MODAL & DIALOG SPACING ====================

  /// Modal padding
  static const double modalPadding = lg; // 24px

  /// Dialog padding
  static const double dialogPadding = lg; // 24px

  /// Dialog content spacing
  static const double dialogContentSpacing = md; // 16px

  /// Dialog action spacing
  static const double dialogActionSpacing = xs; // 8px

  /// ==================== AUTOMOTIVE-SPECIFIC SPACING ====================

  /// VIN display padding
  static const double vinDisplayPadding = md; // 16px

  /// Part card spacing
  static const double partCardSpacing = md; // 16px

  /// Vehicle info spacing
  static const double vehicleInfoSpacing = xs; // 8px

  /// Image gallery spacing
  static const double imageGallerySpacing = xs; // 8px

  /// ==================== BORDER RADIUS ====================

  /// Subtle radius for inputs, cards
  static const double radiusSmall = 6.0;

  /// Standard radius for buttons, cards
  static const double radiusMedium = 8.0;

  /// Large radius for prominent elements
  static const double radiusLarge = 12.0;

  /// Extra large radius for modals, sheets
  static const double radiusXLarge = 16.0;

  /// Circular radius (for avatars, icons)
  static const double radiusCircular = 50.0;

  /// ==================== ELEVATION/SHADOW ====================

  /// No elevation
  static const double elevationNone = 0.0;

  /// Subtle elevation for cards
  static const double elevationLow = 2.0;

  /// Medium elevation for buttons, focused elements
  static const double elevationMedium = 4.0;

  /// High elevation for floating elements
  static const double elevationHigh = 8.0;

  /// Maximum elevation for modals, overlays
  static const double elevationMax = 16.0;

  /// ==================== UTILITY METHODS ====================

  /// Get responsive padding based on screen size
  static double responsivePadding(double screenWidth) {
    if (screenWidth < 600) {
      return screenPadding; // 16px for mobile
    } else if (screenWidth < 1200) {
      return screenPaddingLarge; // 24px for tablet
    } else {
      return xl; // 32px for desktop
    }
  }

  /// Get responsive spacing between elements
  static double responsiveSpacing(double screenWidth) {
    if (screenWidth < 600) {
      return elementSpacing; // 16px for mobile
    } else {
      return elementSpacingLarge; // 24px for larger screens
    }
  }

  /// Create symmetric padding
  static EdgeInsets symmetric({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) {
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  /// Create all-around padding
  static EdgeInsets all(double value) {
    return EdgeInsets.all(value);
  }

  /// Create only padding
  static EdgeInsets only({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
  }

  /// Standard screen padding
  static const EdgeInsets screenPaddingEdgeInsets = EdgeInsets.all(
    screenPadding,
  );

  /// Standard card padding
  static const EdgeInsets cardPaddingEdgeInsets = EdgeInsets.all(cardPadding);

  /// Standard button padding
  static const EdgeInsets buttonPaddingEdgeInsets = EdgeInsets.symmetric(
    horizontal: buttonPaddingHorizontal,
    vertical: buttonPaddingVertical,
  );

  /// Standard input padding
  static const EdgeInsets inputPaddingEdgeInsets = EdgeInsets.symmetric(
    horizontal: inputPaddingHorizontal,
    vertical: inputPaddingVertical,
  );
}

/// Convenient size box widgets for common spacing
class SpacingBox {
  // Vertical spacing
  static const Widget verticalXXS = SizedBox(height: AppSpacing.xxs);
  static const Widget verticalXS = SizedBox(height: AppSpacing.xs);
  static const Widget verticalSM = SizedBox(height: AppSpacing.sm);
  static const Widget verticalMD = SizedBox(height: AppSpacing.md);
  static const Widget verticalLG = SizedBox(height: AppSpacing.lg);
  static const Widget verticalXL = SizedBox(height: AppSpacing.xl);
  static const Widget verticalXXL = SizedBox(height: AppSpacing.xxl);

  // Horizontal spacing
  static const Widget horizontalXXS = SizedBox(width: AppSpacing.xxs);
  static const Widget horizontalXS = SizedBox(width: AppSpacing.xs);
  static const Widget horizontalSM = SizedBox(width: AppSpacing.sm);
  static const Widget horizontalMD = SizedBox(width: AppSpacing.md);
  static const Widget horizontalLG = SizedBox(width: AppSpacing.lg);
  static const Widget horizontalXL = SizedBox(width: AppSpacing.xl);
  static const Widget horizontalXXL = SizedBox(width: AppSpacing.xxl);

  // Custom size boxes
  static Widget vertical(double height) => SizedBox(height: height);
  static Widget horizontal(double width) => SizedBox(width: width);
}
