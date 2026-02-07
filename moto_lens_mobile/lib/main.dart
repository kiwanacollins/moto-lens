import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'styles/styles.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style for status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
      ],
      child: MaterialApp(
        // App configuration
        title: 'German Car Medic',
        debugShowCheckedModeBanner: false,

        // German Car Medic theme
        theme: AppTheme.lightTheme,

        // Routing configuration
        initialRoute: '/',
        onGenerateRoute: _generateRoute,

        // Authentication wrapper that manages navigation
        home: const AuthenticationWrapper(),
      ),
    );
  }

  /// Generate routes for navigation
  static Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AuthenticationWrapper());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/password-reset':
        return MaterialPageRoute(builder: (_) => const PasswordResetScreen());
      case '/reset-password':
        // Extract token from arguments
        final args = settings.arguments as Map<String, dynamic>?;
        final token = args?['token'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(token: token),
        );
      case '/vin-scanner':
        return MaterialPageRoute(builder: (_) => const VinScannerScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Page not found: ${settings.name}')),
          ),
        );
    }
  }
}

/// Authentication wrapper that manages app navigation based on auth state
///
/// Shows loading screen during initialization, login screen when unauthenticated,
/// and main app content when authenticated.
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, _) {
        switch (authProvider.state.status) {
          case AuthenticationStatus.initial:
            return const SplashScreen();
          case AuthenticationStatus.loading:
            return const LoadingScreen();
          case AuthenticationStatus.authenticated:
            return const MainApp();
          case AuthenticationStatus.unauthenticated:
            return const LoginScreen();
        }
      },
    );
  }
}

// Splash screen is now imported from screens/auth/splash_screen.dart

/// Loading screen for authentication operations
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricBlue),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Please wait...',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main app content shown when authenticated
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.state.user;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'German Car Medic',
              style: AppTypography.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.electricBlue,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle, color: Colors.white),
                onPressed: () {
                  // Show user menu
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(user?.displayName ?? 'User'),
                            subtitle: Text(user?.email ?? ''),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.logout),
                            title: const Text('Logout'),
                            onTap: () async {
                              Navigator.pop(context);
                              await context.logout();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // German Car Medic branding
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.electricBlue.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Welcome message
                Text(
                  'Welcome to German Car Medic!',
                  style: AppTypography.h2.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Professional German vehicle diagnostics',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),

                // VIN Scanner — primary action card
                _buildFeatureCard(
                  context,
                  icon: Icons.qr_code_scanner,
                  title: 'VIN Scanner',
                  subtitle: 'Decode Vehicle Identification Numbers',
                  onTap: () => Navigator.pushNamed(context, '/vin-scanner'),
                  isPrimary: true,
                ),
                const SizedBox(height: AppSpacing.md),

                // AI Assistant card
                _buildFeatureCard(
                  context,
                  icon: Icons.psychology_outlined,
                  title: 'AI Assistant',
                  subtitle: 'Get intelligent vehicle diagnostics help',
                  onTap: () {
                    // TODO: Navigate to AI Assistant screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('AI Assistant - Coming soon!'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // QR Code Scanner card
                _buildFeatureCard(
                  context,
                  icon: Icons.qr_code_2,
                  title: 'QR Code Scanner',
                  subtitle: 'Scan parts and component QR codes',
                  onTap: () {
                    // TODO: Navigate to QR Code Scanner screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('QR Code Scanner - Coming soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: isPrimary ? AppColors.electricBlue : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      elevation: isPrimary ? 4 : 1,
      shadowColor: isPrimary
          ? AppColors.electricBlue.withValues(alpha: 0.3)
          : AppColors.carbonBlack.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: isPrimary
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  border: Border.all(color: AppColors.border),
                ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.electricBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: Icon(
                  icon,
                  color: isPrimary ? Colors.white : AppColors.electricBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.h5.copyWith(
                        color: isPrimary ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: isPrimary
                            ? Colors.white.withValues(alpha: 0.8)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
