import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'config/environment.dart';
import 'styles/styles.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';
import 'services/api_service.dart';
import 'services/connectivity_service.dart';
import 'services/sync_queue_service.dart';
import 'services/vin_history_service.dart';
import 'models/vehicle/vin_decode_result.dart';
import 'widgets/offline_banner.dart';

/// Allow HTTP connections on iOS for development
class MotoLensHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable HTTP connections on iOS
  HttpOverrides.global = MotoLensHttpOverrides();

  // Validate environment configuration (warns if release build uses dev mode)
  Environment.validateEnvironment();

  // Initialise core offline services before the widget tree
  await ConnectivityService().initialize();
  final syncQueue = SyncQueueService();
  await syncQueue.initialize();

  // Register sync handlers for queued operations
  final apiService = ApiService();
  final historyService = VinHistoryService();

  syncQueue.registerHandler('vin_decode', (payload) async {
    final vin = payload['vin'] as String;
    try {
      final response = await apiService.decodeVin(vin);
      final result = VinDecodeResult.fromJson(response);
      await historyService.cacheResult(result);
      await historyService.addDecodeResult(result);
      await historyService.markSynced(vin);
      return true;
    } catch (_) {
      return false;
    }
  });

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
        ChangeNotifierProvider(create: (_) => AiChatProvider()),
        ChangeNotifierProvider(create: (_) => QrScanProvider()),
        ChangeNotifierProvider(create: (_) => VehicleViewerProvider()),
        ChangeNotifierProvider(
          create: (_) => ConnectivityProvider()..initialize(),
        ),
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
      case '/vin-scanner':
        return MaterialPageRoute(builder: (_) => const VinScannerScreen());
      case '/ai-assistant':
        return MaterialPageRoute(builder: (_) => const AiAssistantScreen());
      case '/qr-scanner':
        return MaterialPageRoute(builder: (_) => const QrScannerScreen());
      case '/notes':
        return MaterialPageRoute(builder: (_) => const NotesScreen());
      case '/part-detail':
        return MaterialPageRoute(builder: (_) => const PartDetailScreen());
      case '/vehicle-detail':
        // Extract vehicle from arguments
        final args = settings.arguments as Map<String, dynamic>?;
        final vehicle = args?['vehicle'];
        if (vehicle == null) {
          return MaterialPageRoute(
            builder: (_) =>
                Scaffold(body: Center(child: Text('Vehicle data not found'))),
          );
        }
        return MaterialPageRoute(
          builder: (_) => VehicleDetailScreen(vehicle: vehicle),
        );
      case '/vehicle-view':
        // Extract vehicle from arguments
        final viewArgs = settings.arguments as Map<String, dynamic>?;
        final viewVehicle = viewArgs?['vehicle'];
        if (viewVehicle == null) {
          return MaterialPageRoute(
            builder: (_) =>
                Scaffold(body: Center(child: Text('Vehicle data not found'))),
          );
        }
        return MaterialPageRoute(
          builder: (_) => VehicleViewScreen(vehicle: viewVehicle),
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
            backgroundColor: AppColors.headerBar,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.account_circle,
                  color: AppColors.gunmetalGray,
                ),
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
          body: OfflineBannerWrapper(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.lg),

                  // German Car Medic branding
                  SvgPicture.asset(
                    'assets/logo.svg',
                    width: 260,
                    height: 70,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 3),

                  // Welcome message
                  Text(
                    'Welcome to German Car Medic!',
                    style: GoogleFonts.archivoNarrow(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Professional Automobile diagnostics\' Tool',
                    style: GoogleFonts.archivoNarrow(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // 2x2 Feature Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildGridCard(
                          context,
                          icon: Icons.search,
                          title: 'VIN Scanner',
                          subtitle: 'Decode VINs',
                          onTap: () =>
                              Navigator.pushNamed(context, '/vin-scanner'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildGridCard(
                          context,
                          icon: Icons.psychology_outlined,
                          title: 'AI Assistant',
                          subtitle: 'Vehicle diagnostics',
                          onTap: () =>
                              Navigator.pushNamed(context, '/ai-assistant'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGridCard(
                          context,
                          icon: Icons.barcode_reader,
                          title: 'Barcode Scanner',
                          subtitle: 'Scan Part Numbers',
                          onTap: () =>
                              Navigator.pushNamed(context, '/qr-scanner'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildGridCard(
                          context,
                          icon: Icons.note_alt_outlined,
                          title: 'Take Notes',
                          subtitle: 'Save locally',
                          onTap: () => Navigator.pushNamed(context, '/notes'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildGridCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final cardColor = AppColors.electricBlue.withValues(alpha: 0.12);

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      elevation: 1,
      shadowColor: AppColors.electricBlue.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: Border.all(
              color: AppColors.electricBlue.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: Icon(icon, color: AppColors.electricBlue, size: 26),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.h5.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
