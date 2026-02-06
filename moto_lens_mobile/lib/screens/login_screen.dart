import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../styles/styles.dart';
import '../widgets/widgets.dart';
import '../widgets/error_alert.dart';
import '../providers/providers.dart';

/// Professional Login Screen for MotoLens
///
/// Features:
/// - Email/password authentication
/// - Form validation with real-time feedback
/// - Remember me functionality
/// - Password visibility toggle
/// - Navigation to register and password reset
/// - Social login options (coming soon)
/// - Professional MotoLens branding
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with AuthenticationMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

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

      if (!success && mounted) {
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

  /// Show error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
      ),
    );
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
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),

                // MotoLens Logo & Branding
                _buildHeader(),

                const SizedBox(height: AppSpacing.xxxl),

                // Login Form
                _buildLoginForm(),

                const SizedBox(height: AppSpacing.xl),

                // Login Button
                _buildLoginButton(),

                const SizedBox(height: AppSpacing.lg),

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
        // MotoLens Logo
        Container(
          width: 280,
          height: 140,
          child: SvgPicture.asset(
            'assets/logo.svg',
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Welcome Text
        Text(
          'Welcome Back',
          style: AppTypography.h1.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.md),

        Text(
          'Sign in to continue to MotoLens',
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

        const SizedBox(height: AppSpacing.lg),

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

        const SizedBox(height: AppSpacing.lg),

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
