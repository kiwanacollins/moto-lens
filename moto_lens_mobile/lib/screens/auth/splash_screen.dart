import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/services.dart';
import '../../styles/styles.dart';

/// MotoLens Splash Screen with Auto-Login
///
/// Professional branded splash screen that:
/// - Displays MotoLens logo and branding
/// - Checks authentication status
/// - Automatically navigates to appropriate screen
/// - Handles network errors gracefully
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final SecureStorageService _storageService = SecureStorageService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _statusMessage = 'Initializing...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthStatus();
  }

  /// Initialize fade and scale animations for smooth appearance
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    _animationController.forward();
  }

  /// Check authentication status and navigate accordingly
  Future<void> _checkAuthStatus() async {
    try {
      // Display branding for minimum duration (smooth UX)
      await Future.delayed(const Duration(seconds: 2));

      // Check if secure storage is available
      setState(() {
        _statusMessage = 'Checking credentials...';
      });

      final storageAvailable = await _storageService.isSecureStorageAvailable();
      if (!storageAvailable) {
        _handleError('Secure storage not available');
        return;
      }

      // Check for valid tokens
      final hasValidTokens = await _storageService.hasValidTokens();

      if (!hasValidTokens) {
        // No valid tokens - navigate to login
        _navigateToLogin();
        return;
      }

      // Tokens exist - verify with server
      setState(() {
        _statusMessage = 'Verifying session...';
      });

      final user = await _authService.getCurrentUser();

      if (user != null) {
        // Valid session - navigate to dashboard
        _navigateToDashboard(user.fullName);
      } else {
        // Invalid/expired tokens - clean up and go to login
        await _storageService.deleteTokens();
        _navigateToLogin();
      }
    } catch (e) {
      // Handle errors gracefully
      _handleError(e.toString());
    }
  }

  /// Handle errors during authentication check
  void _handleError(String error) {
    setState(() {
      _hasError = true;
      _statusMessage = 'Connection error';
    });

    // Show error message and navigate to login after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _navigateToLogin();
      }
    });
  }

  /// Navigate to login screen
  void _navigateToLogin() {
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed('/login');
  }

  /// Navigate to dashboard
  void _navigateToDashboard(String userName) {
    if (!mounted) return;

    setState(() {
      _statusMessage = 'Welcome back, $userName!';
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbonBlack,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Section
                  _buildLogo(),

                  const SizedBox(height: AppSpacing.xl),

                  // Tagline
                  _buildTagline(),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Loading Indicator
                  _buildLoadingIndicator(),

                  const SizedBox(height: AppSpacing.lg),

                  // Status Message
                  _buildStatusMessage(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build MotoLens logo
  Widget _buildLogo() {
    return Container(
      width: 250,
      height: 120,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SvgPicture.asset(
        'assets/logo.svg',
        fit: BoxFit.contain,
      ),
    );
  }

  /// Build tagline text
  Widget _buildTagline() {
    return Column(
      children: [
        // Brand Name
        Text(
          'MotoLens',
          style: AppTypography.h1.copyWith(
            color: Colors.white,
            fontSize: 40,
            fontWeight: AppTypography.bold,
            letterSpacing: -1,
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        // Tagline
        Text(
          'Professional VIN Decoding',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.electricBlue,
            fontSize: 16,
            fontWeight: AppTypography.medium,
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.xs),

        // Subtitle
        Text(
          'For German Vehicles',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.zinc400,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator() {
    if (_hasError) {
      return Icon(
        Icons.error_outline,
        color: AppColors.error,
        size: 32,
      );
    }

    return SizedBox(
      width: 32,
      height: 32,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricBlue),
        strokeWidth: 3,
      ),
    );
  }

  /// Build status message text
  Widget _buildStatusMessage() {
    return Text(
      _statusMessage,
      style: AppTypography.bodySmall.copyWith(
        color: _hasError ? AppColors.error : AppColors.zinc400,
        fontSize: 14,
      ),
      textAlign: TextAlign.center,
    );
  }
}
