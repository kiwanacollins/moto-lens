import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../styles/styles.dart';
import '../widgets/widgets.dart';
import '../widgets/error_alert.dart';
import '../providers/providers.dart';

/// OTP Verification Screen for Password Reset
///
/// Features:
/// - 6-digit OTP code input
/// - New password entry with visibility toggle
/// - Confirm password field
/// - Form validation with real-time feedback
/// - Success navigation to login
class VerifyOTPScreen extends StatefulWidget {
  final String email;

  const VerifyOTPScreen({super.key, required this.email});

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen>
    with AuthenticationMixin {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handle password reset with OTP
  Future<void> _handleResetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Check passwords match
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ErrorSnackBar.show(context, 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await context.resetPassword(
        widget.email,
        _otpController.text.trim(),
        _newPasswordController.text,
      );

      if (success) {
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Password reset successful! Please sign in.'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Navigate to login screen
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } else if (mounted) {
        ErrorSnackBar.show(
          context,
          context.authErrorOnce ??
              'Password reset failed. Please check your code and try again.',
          onRetry: _handleResetPassword,
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackBar.show(context, e, onRetry: _handleResetPassword);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Resend OTP code
  Future<void> _resendOTP() async {
    setState(() => _isLoading = true);

    try {
      final success = await context.requestPasswordReset(widget.email);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('New code sent to your email!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        ErrorSnackBar.show(
          context,
          context.authErrorOnce ?? 'Failed to resend code. Please try again.',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackBar.show(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xl),

                // Header
                _buildHeader(),

                const SizedBox(height: AppSpacing.xxxl),

                // OTP Input
                _buildOTPField(),

                const SizedBox(height: AppSpacing.lg),

                // New Password Field
                CustomTextField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  hintText: 'Enter your new password',
                  type: CustomTextFieldType.password,
                  prefixIcon: Icons.lock_outline,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      errorText: 'Password is required',
                    ),
                    FormBuilderValidators.minLength(
                      8,
                      errorText: 'Password must be at least 8 characters',
                    ),
                  ]),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Confirm Password Field
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hintText: 'Re-enter your new password',
                  type: CustomTextFieldType.password,
                  prefixIcon: Icons.lock_outline,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      errorText: 'Please confirm your password',
                    ),
                    (value) {
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ]),
                  onSubmitted: (_) => _handleResetPassword(),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Reset Button
                CustomButton(
                  text: _isLoading ? 'Resetting Password...' : 'Reset Password',
                  onPressed: _isLoading ? null : _handleResetPassword,
                  variant: CustomButtonVariant.auth,
                  size: CustomButtonSize.large,
                  isFullWidth: true,
                  isLoading: _isLoading,
                  prefixIcon: _isLoading ? null : Icons.check_circle,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Resend OTP Button
                TextButton.icon(
                  onPressed: _isLoading ? null : _resendOTP,
                  icon: Icon(Icons.refresh, color: AppColors.electricBlue),
                  label: Text(
                    'Resend Code',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.electricBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
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
            color: AppColors.electricBlue,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
            boxShadow: [
              BoxShadow(
                color: AppColors.electricBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.security, size: 48, color: Colors.white),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Title
        Text(
          'Verify Code',
          style: AppTypography.h1.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.md),

        // Subtitle
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            children: [
              const TextSpan(text: 'Enter the 6-digit code sent to\n'),
              TextSpan(
                text: widget.email,
                style: TextStyle(
                  color: AppColors.electricBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build OTP input field
  Widget _buildOTPField() {
    return CustomTextField(
      controller: _otpController,
      label: 'Verification Code',
      hintText: 'Enter 6-digit code',
      type: CustomTextFieldType.number,
      prefixIcon: Icons.pin,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: 'Code is required'),
        FormBuilderValidators.numeric(errorText: 'Code must be numeric'),
        FormBuilderValidators.minLength(6, errorText: 'Code must be 6 digits'),
        FormBuilderValidators.maxLength(6, errorText: 'Code must be 6 digits'),
      ]),
    );
  }
}
