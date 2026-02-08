import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../styles/styles.dart';
import '../widgets/widgets.dart';
import '../widgets/error_alert.dart';
import '../providers/providers.dart';

/// Professional Registration Screen for German Car Medic
///
/// Features:
/// - 2-step registration process for mechanics
/// - Comprehensive form validation
/// - Password strength requirements
/// - Terms and conditions acceptance
/// - Professional German Car Medic branding
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with AuthenticationMixin {
  final _pageController = PageController();
  final _formKeys = [
    GlobalKey<FormState>(), // Step 1: Personal Info & Email
    GlobalKey<FormState>(), // Step 2: Password & Terms
  ];

  // Form Controllers
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Form State
  int _currentStep = 0;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Handle registration submission
  Future<void> _handleRegister() async {
    if (!(_formKeys[1].currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final success = await context.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        acceptTerms: true,
        acceptMarketing: false,
      );

      if (!success && mounted) {
        ErrorSnackBar.show(
          context,
          context.authErrorOnce ?? 'Registration failed. Please try again.',
          onRetry: _handleRegister,
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackBar.show(context, e, onRetry: _handleRegister);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Navigate to next step
  void _nextStep() {
    if (_currentStep < 1) {
      if (_formKeys[_currentStep].currentState?.validate() ?? false) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  /// Navigate to previous step
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigate to login screen
  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStepPage(_buildPersonalInfoStep()),
            _buildStepPage(_buildPasswordStep()),
          ],
        ),
      ),
    );
  }

  /// Wraps a step's form content with the shared header and bottom nav
  /// inside a single scrollable column so the keyboard never obscures fields.
  Widget _buildStepPage(Widget stepContent) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Header (scrolls with content)
                  _buildHeader(),

                  // Step form content
                  stepContent,

                  const Spacer(),

                  // Bottom navigation
                  _buildBottomNavigation(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build header with logo and progress
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 150,
          height: 80,
          padding: const EdgeInsets.all(AppSpacing.sm),
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

        Text(
          'Create Account',
          style: AppTypography.h2.copyWith(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: AppSpacing.xs),

        // Progress Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 24,
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? AppColors.electricBlue
                    : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Step 1: Personal Information & Email
  Widget _buildPersonalInfoStep() {
    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Information', style: AppTypography.h3),

          const SizedBox(height: AppSpacing.xs),

          Text(
            'Tell us about yourself',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Email Address
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

          // First Name
          CustomTextField(
            controller: _firstNameController,
            label: 'First Name',
            hintText: 'Enter your first name',
            prefixIcon: Icons.person_outlined,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'First name is required',
              ),
              FormBuilderValidators.minLength(
                2,
                errorText: 'Name must be at least 2 characters',
              ),
            ]),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Last Name
          CustomTextField(
            controller: _lastNameController,
            label: 'Last Name',
            hintText: 'Enter your last name',
            prefixIcon: Icons.person_outlined,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'Last name is required',
              ),
              FormBuilderValidators.minLength(
                2,
                errorText: 'Name must be at least 2 characters',
              ),
            ]),
          ),
        ],
      ),
    );
  }

  /// Step 2: Password & Terms
  Widget _buildPasswordStep() {
    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Password', style: AppTypography.h3),

          const SizedBox(height: AppSpacing.xs),

          Text(
            'Create a secure password',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Password
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            hintText: 'Create a secure password',
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
                8,
                errorText: 'Password must be at least 8 characters',
              ),
              (value) {
                if (value == null || value.isEmpty) return null;
                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                  return 'Password must contain at least one uppercase letter';
                }
                if (!RegExp(r'[a-z]').hasMatch(value)) {
                  return 'Password must contain at least one lowercase letter';
                }
                if (!RegExp(r'[0-9]').hasMatch(value)) {
                  return 'Password must contain at least one number';
                }
                return null;
              },
            ]),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Confirm Password
          CustomTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hintText: 'Re-enter your password',
            type: CustomTextFieldType.password,
            prefixIcon: Icons.lock_outlined,
            suffixIcon: _obscureConfirmPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            onSuffixIconPressed: () {
              setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              );
            },
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Build bottom navigation buttons
  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main Action Button
          if (_currentStep < 1)
            CustomButton(
              text: 'Continue',
              onPressed: _nextStep,
              variant: CustomButtonVariant.primary,
              size: CustomButtonSize.large,
              isFullWidth: true,
              prefixIcon: Icons.arrow_forward,
            )
          else
            CustomButton(
              text: _isLoading ? 'Creating Account...' : 'Create Account',
              onPressed: _isLoading ? null : _handleRegister,
              variant: CustomButtonVariant.primary,
              size: CustomButtonSize.large,
              isFullWidth: true,
              isLoading: _isLoading,
              prefixIcon: _isLoading ? null : Icons.check,
            ),

          const SizedBox(height: AppSpacing.xs),

          // Bottom Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              if (_currentStep > 0)
                TextButton(
                  onPressed: _previousStep,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Back',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

              if (_currentStep == 0) ...[
                // Login Link
                Row(
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: _navigateToLogin,
                      child: Text(
                        'Sign In',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.electricBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              if (_currentStep > 0) const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
