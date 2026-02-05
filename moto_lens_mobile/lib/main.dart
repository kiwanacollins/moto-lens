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
        title: 'MotoLens',
        debugShowCheckedModeBanner: false,

        // MotoLens theme
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
              'MotoLens',
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
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // MotoLens branding
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusLarge,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricBlue.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Welcome message
                  Text(
                    'Welcome to MotoLens!',
                    style: AppTypography.h1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Professional VIN decoding at your fingertips',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Feature cards
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.qr_code_scanner,
                                color: AppColors.electricBlue,
                                size: 32,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'VIN Scanner',
                                      style: AppTypography.h5,
                                    ),
                                    Text(
                                      'Scan VIN codes with your camera',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.electricBlue,
                                size: 32,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Vehicle Information',
                                      style: AppTypography.h5,
                                    ),
                                    Text(
                                      'Get detailed vehicle specifications',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Icon(
                                Icons.history,
                                color: AppColors.electricBlue,
                                size: 32,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Search History',
                                      style: AppTypography.h5,
                                    ),
                                    Text(
                                      'Access your previous searches',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Coming soon message
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusMedium,
                      ),
                      border: Border.all(
                        color: AppColors.electricBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.construction,
                          color: AppColors.electricBlue,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Full features coming soon! This is a preview build.',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.electricBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
