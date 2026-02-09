import 'package:flutter/material.dart';

/// MotoLens Brand Colors
///
/// Professional automotive design system
/// Core colors: Navy Blue, Racing Red, Carbon Black, Gunmetal Gray
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  /// ==================== BRAND CORE COLORS ====================

  /// Electric Blue (#19A7CE) - Primary brand color (from logo)
  /// Used for: CTAs, primary buttons, interactive elements, highlights
  static const Color electricBlue = Color(0xFF19A7CE);

  /// Racing Red (#d82f37) - Accent brand color (from logo)
  /// Used for: Secondary CTAs, highlights, status indicators, accents
  static const Color racingRed = Color(0xFFD82F37);

  /// Logo Blue (#3C558F) - Logo text color
  /// Used for: "CAR MEDIC" text in logo to match logo design
  static const Color logoBlue = Color(0xFF3C558F);

  /// Auth Button Gray (#393E46) - Authentication button background
  /// Used for: Login, register, signin buttons
  static const Color authButton = Color(0xFF393E46);

  /// Header Bar (#F7F7F7) - App bar / header section background
  /// Used for: AppBar backgrounds across all screens
  static const Color headerBar = Color(0xFFF7F7F7);

  /// Carbon Black (#0a0a0a) - Main text and high-contrast elements
  /// Used for: Main text, headings, dark backgrounds
  static const Color carbonBlack = Color(0xFF0A0A0A);

  /// Gunmetal Gray (#52525b) - Secondary text and subtle elements
  /// Used for: Secondary text, icons, disabled states
  static const Color gunmetalGray = Color(0xFF52525B);

  /// ==================== ZINC SCALE (Neutrals) ====================

  static const Color zinc50 = Color(0xFFFAFAFA); // Light backgrounds
  static const Color zinc100 = Color(
    0xFFF4F4F5,
  ); // Hover states, muted backgrounds
  static const Color zinc200 = Color(0xFFE4E4E7); // Borders, dividers
  static const Color zinc300 = Color(0xFFD4D4D8); // Disabled states
  static const Color zinc400 = Color(0xFFA1A1AA); // Placeholder text
  static const Color zinc500 = Color(0xFF71717A); // Medium gray
  static const Color zinc600 = Color(0xFF52525B); // Gunmetal Gray (alias)
  static const Color zinc700 = Color(0xFF3F3F46); // Dark gray
  static const Color zinc800 = Color(0xFF27272A); // Darker gray
  static const Color zinc900 = Color(0xFF18181B); // Very dark
  static const Color zinc950 = Color(0xFF09090B); // Nearly black

  /// ==================== SEMANTIC COLORS ====================

  /// Success - Emerald 500
  static const Color success = Color(0xFF10B981);

  /// Warning - Amber 500
  static const Color warning = Color(0xFFF59E0B);

  /// Error/Destructive - Red 500
  static const Color error = Color(0xFFEF4444);

  /// Info - Navy Blue (reuse primary)
  static const Color info = electricBlue;

  /// ==================== UI BACKGROUNDS ====================

  /// Primary page background (light mode)
  static const Color background = Color(0xFFF7F7F7);

  /// Secondary background for sections
  static const Color backgroundSecondary = zinc50;

  /// Card and component backgrounds
  static const Color surface = Color(0xFFF7F7F7);

  /// Elevated surface (modals, dropdowns)
  static const Color surfaceElevated = Colors.white;

  /// ==================== TEXT COLORS ====================

  /// Primary text color
  static const Color textPrimary = carbonBlack;

  /// Secondary text color
  static const Color textSecondary = gunmetalGray;

  /// Disabled text color
  static const Color textDisabled = zinc400;

  /// Text on dark backgrounds
  static const Color textOnDark = Colors.white;

  /// Text on primary (Electric Blue) backgrounds
  static const Color textOnPrimary = Colors.white;

  /// ==================== BORDER COLORS ====================

  /// Default border color
  static const Color border = zinc200;

  /// Focused border color
  static const Color borderFocused = electricBlue;

  /// Error border color
  static const Color borderError = error;

  /// ==================== AUTOMOTIVE-SPECIFIC COLORS ====================

  /// For mechanical parts highlighting
  static const Color mechanicalPart = zinc600;

  /// For electrical components
  static const Color electricalPart = electricBlue;

  /// For body/exterior parts
  static const Color bodyPart = zinc500;

  /// For interior components
  static const Color interiorPart = zinc400;

  /// ==================== UTILITY METHODS ====================

  /// Get shade of Navy Blue (primary)
  static Color electricBlueShade(double opacity) {
    return electricBlue.withOpacity(opacity);
  }

  /// Get shade of Racing Red (accent)
  static Color racingRedShade(double opacity) {
    return racingRed.withOpacity(opacity);
  }

  /// Get shade of Carbon Black
  static Color carbonBlackShade(double opacity) {
    return carbonBlack.withOpacity(opacity);
  }

  /// Get suitable text color for given background
  static Color getTextColorForBackground(Color background) {
    // Simple luminance-based text color selection
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? carbonBlack : Colors.white;
  }

  /// Check if a color is dark
  static bool isDark(Color color) {
    return color.computeLuminance() < 0.5;
  }
}

/// Material Color Swatch for Navy Blue (for use with MaterialApp)
class ElectricBlueSwatch extends MaterialColor {
  const ElectricBlueSwatch() : super(_navyBluePrimary, _navyBlueMap);

  static const int _navyBluePrimary = 0xFF3C558F;

  static const Map<int, Color> _navyBlueMap = {
    50: Color(0xFFEBEEF5),
    100: Color(0xFFCDD4E4),
    200: Color(0xFFACB8D1),
    300: Color(0xFF8B9BBD),
    400: Color(0xFF6A7FA9),
    500: Color(0xFF3C558F), // Primary
    600: Color(0xFF344B80),
    700: Color(0xFF2C406E),
    800: Color(0xFF24355C),
    900: Color(0xFF1A2741),
  };
}
