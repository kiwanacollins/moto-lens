import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// MotoLens App Theme
///
/// Complete theme configuration combining colors, typography, and spacing
/// Professional automotive design system based on Navy Blue & Racing Red brand
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// ==================== LIGHT THEME ====================

  static ThemeData get lightTheme => ThemeData(
    // Color scheme
    colorScheme: _lightColorScheme,

    // Material 3 design
    useMaterial3: true,

    // Primary color
    primarySwatch: const ElectricBlueSwatch(),
    primaryColor: AppColors.electricBlue,

    // Scaffold
    scaffoldBackgroundColor: AppColors.background,

    // Typography
    textTheme: AppTextTheme.textTheme,
    fontFamily: AppTypography.primaryFontFamily,

    // App bar theme
    appBarTheme: _lightAppBarTheme,

    // Button themes
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,

    // Input field theme
    inputDecorationTheme: _inputDecorationTheme,

    // Card theme
    cardTheme: _cardTheme,

    // Chip theme
    chipTheme: _chipTheme,

    // Bottom navigation theme
    bottomNavigationBarTheme: _bottomNavigationBarTheme,

    // Navigation rail theme
    navigationRailTheme: _navigationRailTheme,

    // Tab bar theme
    tabBarTheme: _tabBarTheme,

    // Dialog theme
    dialogTheme: _dialogTheme,

    // Snackbar theme
    snackBarTheme: _snackBarTheme,

    // Floating action button theme
    floatingActionButtonTheme: _floatingActionButtonTheme,

    // Icon theme
    iconTheme: _iconTheme,
    primaryIconTheme: _primaryIconTheme,

    // Divider theme
    dividerTheme: _dividerTheme,

    // List tile theme
    listTileTheme: _listTileTheme,

    // Switch theme
    switchTheme: _switchTheme,

    // Checkbox theme
    checkboxTheme: _checkboxTheme,

    // Radio theme
    radioTheme: _radioTheme,

    // Slider theme
    sliderTheme: _sliderTheme,

    // Progress indicator theme
    progressIndicatorTheme: _progressIndicatorTheme,

    // Tooltip theme
    tooltipTheme: _tooltipTheme,
  );

  /// ==================== COLOR SCHEMES ====================

  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppColors.electricBlue,
    onPrimary: AppColors.textOnPrimary,
    secondary: AppColors.gunmetalGray,
    onSecondary: AppColors.textOnDark,
    tertiary: AppColors.zinc500,
    onTertiary: AppColors.textOnDark,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.backgroundSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.zinc200,
    shadow: AppColors.zinc200,
    scrim: Colors.black54,
    inverseSurface: AppColors.carbonBlack,
    onInverseSurface: Colors.white,
    inversePrimary: AppColors.electricBlue,
  );

  /// ==================== APP BAR THEME ====================

  static const AppBarTheme _lightAppBarTheme = AppBarTheme(
    elevation: AppSpacing.elevationLow,
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    titleTextStyle: AppTypography.h5,
    toolbarTextStyle: AppTypography.bodyMedium,
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
    scrolledUnderElevation: AppSpacing.elevationMedium,
    surfaceTintColor: AppColors.electricBlue,
  );

  /// ==================== BUTTON THEMES ====================

  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricBlue,
          foregroundColor: AppColors.textOnPrimary,
          textStyle: AppTypography.buttonMedium,
          padding: AppSpacing.buttonPaddingEdgeInsets,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          elevation: AppSpacing.elevationLow,
          shadowColor: AppColors.electricBlue.withOpacity(0.3),
        ),
      );

  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.electricBlue,
          textStyle: AppTypography.buttonMedium,
          padding: AppSpacing.buttonPaddingEdgeInsets,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          side: const BorderSide(color: AppColors.electricBlue, width: 1.5),
        ),
      );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.electricBlue,
      textStyle: AppTypography.buttonMedium,
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
    ),
  );

  /// ==================== INPUT DECORATION THEME ====================

  static final InputDecorationTheme
  _inputDecorationTheme = const InputDecorationTheme(
    filled: true,
    fillColor: AppColors.backgroundSecondary,
    contentPadding: AppSpacing.inputPaddingEdgeInsets,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMedium)),
      borderSide: BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMedium)),
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMedium)),
      borderSide: BorderSide(color: AppColors.borderFocused, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMedium)),
      borderSide: BorderSide(color: AppColors.borderError),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMedium)),
      borderSide: BorderSide(color: AppColors.borderError, width: 2.0),
    ),
    labelStyle: AppTypography.inputLabel,
    hintStyle: AppTypography.inputPlaceholder,
    errorStyle: AppTypography.inputError,
  );

  /// ==================== CARD THEME ====================

  static const CardThemeData _cardTheme = CardThemeData(
    elevation: AppSpacing.elevationLow,
    color: AppColors.surface,
    shadowColor: AppColors.zinc200,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusLarge)),
    ),
    margin: EdgeInsets.all(4.0),
  );

  /// ==================== CHIP THEME ====================

  static const ChipThemeData _chipTheme = ChipThemeData(
    backgroundColor: AppColors.backgroundSecondary,
    selectedColor: AppColors.electricBlue,
    labelStyle: AppTypography.chip,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSmall)),
    ),
  );

  /// ==================== NAVIGATION THEMES ====================

  static const BottomNavigationBarThemeData _bottomNavigationBarTheme =
      BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.electricBlue,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTypography.navigation,
        unselectedLabelStyle: AppTypography.navigation,
        type: BottomNavigationBarType.fixed,
        elevation: AppSpacing.elevationMedium,
      );

  static const NavigationRailThemeData _navigationRailTheme =
      NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        selectedIconTheme: IconThemeData(color: AppColors.electricBlue),
        unselectedIconTheme: IconThemeData(color: AppColors.textSecondary),
        selectedLabelTextStyle: AppTypography.navigation,
        unselectedLabelTextStyle: AppTypography.navigation,
      );

  /// ==================== TAB BAR THEME ====================

  static const TabBarThemeData _tabBarTheme = TabBarThemeData(
    labelColor: AppColors.electricBlue,
    unselectedLabelColor: AppColors.textSecondary,
    labelStyle: AppTypography.tab,
    unselectedLabelStyle: AppTypography.tab,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: AppColors.electricBlue, width: 2.0),
    ),
    indicatorSize: TabBarIndicatorSize.label,
  );

  /// ==================== DIALOG THEME ====================

  static const DialogThemeData _dialogTheme = DialogThemeData(
    backgroundColor: AppColors.surface,
    elevation: AppSpacing.elevationHigh,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusXLarge)),
    ),
    titleTextStyle: AppTypography.h4,
    contentTextStyle: AppTypography.bodyMedium,
  );

  /// ==================== OTHER WIDGET THEMES ====================

  static final SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    backgroundColor: AppColors.carbonBlack,
    contentTextStyle: AppTypography.bodyMedium.copyWith(color: Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMedium)),
    ),
    behavior: SnackBarBehavior.floating,
  );

  static const FloatingActionButtonThemeData _floatingActionButtonTheme =
      FloatingActionButtonThemeData(
        backgroundColor: AppColors.electricBlue,
        foregroundColor: Colors.white,
        elevation: AppSpacing.elevationMedium,
        shape: CircleBorder(),
      );

  static const IconThemeData _iconTheme = IconThemeData(
    color: AppColors.textSecondary,
    size: 24.0,
  );

  static const IconThemeData _primaryIconTheme = IconThemeData(
    color: AppColors.electricBlue,
    size: 24.0,
  );

  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: AppColors.border,
    thickness: 1.0,
    space: 1.0,
  );

  static const ListTileThemeData _listTileTheme = ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
    titleTextStyle: AppTypography.bodyLarge,
    subtitleTextStyle: AppTypography.bodyMedium,
    dense: false,
  );

  static final SwitchThemeData _switchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.electricBlue;
      }
      return AppColors.zinc400;
    }),
    trackColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.electricBlue.withOpacity(0.3);
      }
      return AppColors.zinc200;
    }),
  );

  static final CheckboxThemeData _checkboxTheme = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.electricBlue;
      }
      return AppColors.surface;
    }),
    checkColor: WidgetStateProperty.all(Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
    ),
  );

  static final RadioThemeData _radioTheme = RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.electricBlue;
      }
      return AppColors.textSecondary;
    }),
  );

  static final SliderThemeData _sliderTheme = SliderThemeData(
    activeTrackColor: AppColors.electricBlue,
    inactiveTrackColor: AppColors.zinc200,
    thumbColor: AppColors.electricBlue,
    overlayColor: AppColors.electricBlue.withOpacity(0.1),
    valueIndicatorColor: AppColors.electricBlue,
    valueIndicatorTextStyle: AppTypography.bodySmall.copyWith(
      color: Colors.white,
    ),
  );

  static const ProgressIndicatorThemeData _progressIndicatorTheme =
      ProgressIndicatorThemeData(
        color: AppColors.electricBlue,
        linearTrackColor: AppColors.zinc200,
        circularTrackColor: AppColors.zinc200,
      );

  static final TooltipThemeData _tooltipTheme = TooltipThemeData(
    decoration: const BoxDecoration(
      color: AppColors.carbonBlack,
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
    textStyle: AppTypography.bodySmall.copyWith(color: Colors.white),
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
  );

  /// ==================== CUSTOM WIDGET STYLES ====================

  /// VIN input field style
  static InputDecoration get vinInputDecoration => const InputDecoration(
    labelText: 'Enter VIN Number',
    hintText: 'WBAVA31070F123456',
    prefixIcon: Icon(Icons.directions_car),
  );

  /// Search input field style
  static InputDecoration get searchInputDecoration => const InputDecoration(
    labelText: 'Search parts...',
    hintText: 'Enter part name or number',
    prefixIcon: Icon(Icons.search),
  );

  /// Part card style
  static BoxDecoration get partCardDecoration => const BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusLarge)),
    boxShadow: [
      BoxShadow(
        color: AppColors.zinc200,
        offset: Offset(0, 2),
        blurRadius: 4,
        spreadRadius: 0,
      ),
    ],
  );

  /// Vehicle info card style
  static BoxDecoration get vehicleInfoDecoration => const BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMedium)),
    border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
  );
}
