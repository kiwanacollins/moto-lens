import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../styles/styles.dart';
import '../widgets/widgets.dart';
import '../widgets/error_alert.dart';
import '../providers/providers.dart';
import '../services/services.dart';

/// Professional Login Screen for German Car Medic
///
/// Features:
/// - Email/password authentication
/// - Form validation with real-time feedback
/// - Remember me functionality
/// - Password visibility toggle
/// - Navigation to register and password reset
/// - Social login options (coming soon)
/// - Professional German Car Medic branding
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with AuthenticationMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _biometricService = BiometricService();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  /// Check if biometric login is available on this device
  Future<void> _checkBiometricAvailability() async {
    final available = await _biometricService.isBiometricLoginAvailable();
    if (mounted) {
      setState(() => _biometricAvailable = available);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login submission
  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final success = await context.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (success && mounted) {
        // After successful login, offer biometric opt-in if not already enabled
        await _offerBiometricOptIn();
      } else if (!success && mounted) {
        ErrorSnackBar.show(
          context,
          context.authErrorOnce ?? 'Login failed. Please try again.',
          onRetry: _handleLogin,
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackBar.show(context, e, onRetry: _handleLogin);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Offer biometric opt-in after successful email/password login
  Future<void> _offerBiometricOptIn() async {
    // Only offer if device supports biometric and user hasn't already opted in
    final canOffer = await _biometricService.canOfferBiometric();
    if (!canOffer) return;

    final alreadyEnabled = await _biometricService.isBiometricEnabled();
    if (alreadyEnabled) return;

    if (!mounted) return;

    final label = await _biometricService.getBiometricLabel();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.fingerprint, color: AppColors.electricBlue, size: 28),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Enable $label Login?',
                style: AppTypography.h3.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Text(
          'Use $label for quick access next time you open the app.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Not Now',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.electricBlue,
            ),
            child: Text('Enable'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _biometricService.enableBiometric();
    }
  }

  /// Handle biometric login (fingerprint/face)
  Future<void> _handleBiometricLogin() async {
    setState(() => _isLoading = true);

    try {
      final authenticated = await _biometricService.authenticate();

      if (authenticated && mounted) {
        // Biometric verified — tokens are already in secure storage,
        // so we just need to load the user profile via the provider
        final provider = context.auth;
        final success = await provider.refreshTokens();

        if (!success && mounted) {
          // Tokens expired or invalid, fall back to regular login
          ErrorSnackBar.show(
            context,
            'Session expired. Please sign in with your password.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackBar.show(context, 'Biometric authentication failed.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Navigate to register screen
  void _navigateToRegister() {
    Navigator.pushReplacementNamed(context, '/register');
  }

  /// Navigate to password reset
  void _navigateToPasswordReset() {
    Navigator.pushNamed(context, '/password-reset');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xs),

                // German Car Medic Logo & Branding
                _buildHeader(),

                const SizedBox(height: AppSpacing.sm),

                // Login Form
                _buildLoginForm(),

                const SizedBox(height: AppSpacing.sm),

                // Login Button
                _buildLoginButton(),

                // Biometric Login Button
                if (_biometricAvailable) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _buildBiometricButton(),
                ],

                const SizedBox(height: AppSpacing.sm),

                // Register & Password Reset Links
                _buildBottomActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build header with logo and welcome text
  Widget _buildHeader() {
    return Column(
      children: [
        // German Car Medic Logo
        Container(
          width: 140,
          height: 140,
          child: SvgPicture.asset('assets/logo.svg', fit: BoxFit.contain),
        ),

        const SizedBox(height: AppSpacing.xs),

        // App Name
        Text(
          'German Car Medic',
          style: AppTypography.h1.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.electricBlue,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.xs),

        // Welcome Text
        Text(
          'Welcome Back',
          style: AppTypography.h2.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.xs),

        Text(
          'Sign in to continue to German Car Medic',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build login form with email and password fields
  Widget _buildLoginForm() {
    return Column(
      children: [
        // Email Field
        CustomTextField(
          controller: _emailController,
          label: 'Email Address',
          hintText: 'Enter your email',
          type: CustomTextFieldType.email,
          prefixIcon: Icons.email_outlined,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: 'Email is required'),
            FormBuilderValidators.email(
              errorText: 'Enter a valid email address',
            ),
          ]),
        ),

        const SizedBox(height: AppSpacing.sm),

        // Password Field
        CustomTextField(
          controller: _passwordController,
          label: 'Password',
          hintText: 'Enter your password',
          type: CustomTextFieldType.password,
          prefixIcon: Icons.lock_outlined,
          suffixIcon: _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          onSuffixIconPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: 'Password is required'),
            FormBuilderValidators.minLength(
              6,
              errorText: 'Password must be at least 6 characters',
            ),
          ]),
          onSubmitted: (_) => _handleLogin(),
        ),

        const SizedBox(height: AppSpacing.xs),

        // Remember Me & Forgot Password
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Remember Me Checkbox
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() => _rememberMe = value ?? false);
                  },
                  activeColor: AppColors.electricBlue,
                ),
                Text('Remember me', style: AppTypography.bodyMedium),
              ],
            ),

            // Forgot Password Link
            TextButton(
              onPressed: _navigateToPasswordReset,
              child: Text(
                'Forgot Password?',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.electricBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build login button
  Widget _buildLoginButton() {
    return CustomButton(
      text: _isLoading ? 'Signing In...' : 'Sign In',
      onPressed: _isLoading ? null : _handleLogin,
      variant: CustomButtonVariant.primary,
      size: CustomButtonSize.large,
      isFullWidth: true,
      isLoading: _isLoading,
      prefixIcon: _isLoading ? null : Icons.login,
    );
  }

  /// Build biometric login button
  Widget _buildBiometricButton() {
    return Center(
      child: Column(
        children: [
          Text(
            'or sign in with',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: 64,
            height: 64,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(
                side: BorderSide(color: AppColors.electricBlue, width: 2),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _isLoading ? null : _handleBiometricLogin,
                child: const Center(
                  child: Icon(
                    Icons.fingerprint,
                    size: 36,
                    color: AppColors.electricBlue,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build bottom action links
  Widget _buildBottomActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: _navigateToRegister,
          child: Text(
            'Sign Up',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.electricBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
