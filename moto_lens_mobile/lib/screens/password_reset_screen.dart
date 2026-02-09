import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../styles/styles.dart';
import '../widgets/widgets.dart';
import '../widgets/error_alert.dart';
import '../providers/providers.dart';
import 'verify_otp_screen.dart';

/// Password Reset Screen for German Car Medic
///
/// Features:
/// - Email input for password reset request
/// - Form validation with real-time feedback
/// - Success state with instructions
/// - Navigation back to login
/// - Professional German Car Medic branding
class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen>
    with AuthenticationMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Handle password reset request
  Future<void> _handlePasswordReset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final success = await context.requestPasswordReset(
        _emailController.text.trim(),
      );

      if (success) {
        if (mounted) {
          // Navigate to OTP verification screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VerifyOTPScreen(email: _emailController.text.trim()),
            ),
          );
        }
      } else if (mounted) {
        ErrorSnackBar.show(
          context,
          context.authErrorOnce ??
              'Password reset request failed. Please try again.',
          onRetry: _handlePasswordReset,
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackBar.show(context, e, onRetry: _handlePasswordReset);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Navigate back to login screen
  void _navigateToLogin() {
    Navigator.pop(context);
  }

  /// Resend reset email
  void _resendEmail() {
    setState(() {
      _emailSent = false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: _navigateToLogin,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Header
              _buildHeader(),

              const SizedBox(height: AppSpacing.xxxl),

              // Main Content
              if (_emailSent) _buildSuccessContent() else _buildResetForm(),

              const SizedBox(height: AppSpacing.xl),

              // Bottom Actions
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header with icon and title
  Widget _buildHeader() {
    return Column(
      children: [
        // Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: _emailSent ? AppColors.success : AppColors.warning,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
            boxShadow: [
              BoxShadow(
                color: (_emailSent ? AppColors.success : AppColors.warning)
                    .withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            _emailSent ? Icons.mark_email_read : Icons.lock_reset,
            size: 48,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Title
        Text(
          _emailSent ? 'Check Your Email' : 'Reset Password',
          style: AppTypography.h1.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.md),

        // Subtitle
        Text(
          _emailSent
              ? 'We\'ve sent password reset instructions to your email address'
              : 'Enter your email address and we\'ll send you instructions to reset your password',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build password reset form
  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          CustomTextField(
            controller: _emailController,
            label: 'Email Address',
            hintText: 'Enter your email address',
            type: CustomTextFieldType.email,
            prefixIcon: Icons.email_outlined,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Email is required'),
              FormBuilderValidators.email(
                errorText: 'Enter a valid email address',
              ),
            ]),
            onSubmitted: (_) => _handlePasswordReset(),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Reset Button
          CustomButton(
            text: _isLoading
                ? 'Sending Instructions...'
                : 'Send Reset Instructions',
            onPressed: _isLoading ? null : _handlePasswordReset,
            variant: CustomButtonVariant.auth,
            size: CustomButtonSize.large,
            isFullWidth: true,
            isLoading: _isLoading,
            prefixIcon: _isLoading ? null : Icons.send,
          ),
        ],
      ),
    );
  }

  /// Build success content after email is sent
  Widget _buildSuccessContent() {
    return Column(
      children: [
        // Email address confirmation
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: Border.all(
              color: AppColors.success.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.email, color: AppColors.success, size: 32),

              const SizedBox(height: AppSpacing.md),

              Text(
                'Email sent to:',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                _emailController.text.trim(),
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Instructions
        Card(
          elevation: 0,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            side: BorderSide(color: AppColors.border, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What\'s Next?',
                  style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: AppSpacing.md),

                _buildInstructionStep(
                  '1',
                  'Check your email inbox',
                  'Look for an email from German Car Medic with reset instructions',
                ),

                const SizedBox(height: AppSpacing.md),

                _buildInstructionStep(
                  '2',
                  'Click the reset link',
                  'Follow the secure link in the email to reset your password',
                ),

                const SizedBox(height: AppSpacing.md),

                _buildInstructionStep(
                  '3',
                  'Create a new password',
                  'Choose a strong password and sign back in',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build instruction step
  Widget _buildInstructionStep(
    String number,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.electricBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                description,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build bottom action buttons
  Widget _buildBottomActions() {
    if (_emailSent) {
      return Column(
        children: [
          // Resend Email Button
          TextButton.icon(
            onPressed: _resendEmail,
            icon: Icon(Icons.refresh, color: AppColors.electricBlue),
            label: Text(
              'Didn\'t receive the email? Send again',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.electricBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Back to Login Button
          CustomButton(
            text: 'Back to Sign In',
            onPressed: _navigateToLogin,
            variant: CustomButtonVariant.outline,
            size: CustomButtonSize.large,
            isFullWidth: true,
            prefixIcon: Icons.arrow_back,
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Remember your password? ',
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
      );
    }
  }
}
