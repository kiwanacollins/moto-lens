import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import '../../widgets/widgets.dart';
import '../../services/services.dart';

/// Reset Password Screen for MotoLens
///
/// Features:
/// - New password field with strength indicator
/// - Confirm password field with validation
/// - Professional submit button
/// - Success message and auto-navigation to login
/// - Reset token validation
class ResetPasswordScreen extends StatefulWidget {
  /// Reset token from email link
  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.token,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _resetSuccess = false;

  // Password strength tracking
  PasswordStrength _passwordStrength = PasswordStrength.none;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handle password reset submission
  Future<void> _handleResetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final success = await _authService.resetPassword(
        widget.token,
        _newPasswordController.text,
      );

      if (success && mounted) {
        setState(() {
          _resetSuccess = true;
          _isLoading = false;
        });

        // Auto-navigate to login after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      } else if (mounted) {
        _showErrorSnackBar('Password reset failed. Please try again.');
        setState(() => _isLoading = false);
      }
    } on AuthValidationException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message);
        setState(() => _isLoading = false);
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Password reset failed: $e');
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

  /// Navigate to login screen manually
  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  /// Calculate password strength
  void _updatePasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() => _passwordStrength = PasswordStrength.none);
      return;
    }

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety checks
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    // Determine strength level
    PasswordStrength strength;
    if (score <= 2) {
      strength = PasswordStrength.weak;
    } else if (score <= 4) {
      strength = PasswordStrength.medium;
    } else {
      strength = PasswordStrength.strong;
    }

    setState(() => _passwordStrength = strength);
  }

  /// Validate password meets requirements
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }

    return null;
  }

  /// Validate password confirmation
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _resetSuccess
            ? null
            : IconButton(
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
              if (_resetSuccess) _buildSuccessContent() else _buildResetForm(),

              const SizedBox(height: AppSpacing.xl),
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
            color: _resetSuccess ? AppColors.success : AppColors.electricBlue,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
            boxShadow: [
              BoxShadow(
                color: (_resetSuccess ? AppColors.success : AppColors.electricBlue)
                    .withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            _resetSuccess ? Icons.check_circle_outline : Icons.lock_reset,
            size: 48,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Title
        Text(
          _resetSuccess ? 'Password Reset!' : 'Create New Password',
          style: AppTypography.h1.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.md),

        // Subtitle
        Text(
          _resetSuccess
              ? 'Your password has been successfully reset'
              : 'Please create a strong password to secure your account',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // New Password Field
          CustomTextField(
            controller: _newPasswordController,
            label: 'New Password',
            hintText: 'Enter your new password',
            type: CustomTextFieldType.password,
            prefixIcon: Icons.lock_outlined,
            suffixIcon: _obscureNewPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            onSuffixIconPressed: () {
              setState(() => _obscureNewPassword = !_obscureNewPassword);
            },
            validator: _validatePassword,
            onChanged: _updatePasswordStrength,
          ),

          const SizedBox(height: AppSpacing.md),

          // Password Strength Indicator
          _buildPasswordStrengthIndicator(),

          const SizedBox(height: AppSpacing.lg),

          // Confirm Password Field
          CustomTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hintText: 'Re-enter your new password',
            type: CustomTextFieldType.password,
            prefixIcon: Icons.lock_outlined,
            suffixIcon: _obscureConfirmPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            onSuffixIconPressed: () {
              setState(() =>
                  _obscureConfirmPassword = !_obscureConfirmPassword);
            },
            validator: _validateConfirmPassword,
            onSubmitted: (_) => _handleResetPassword(),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Password Requirements Card
          _buildPasswordRequirements(),

          const SizedBox(height: AppSpacing.xl),

          // Reset Button
          CustomButton(
            text: _isLoading ? 'Resetting Password...' : 'Reset Password',
            onPressed: _isLoading ? null : _handleResetPassword,
            variant: CustomButtonVariant.primary,
            size: CustomButtonSize.large,
            isFullWidth: true,
            isLoading: _isLoading,
            prefixIcon: _isLoading ? null : Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }

  /// Build password strength indicator
  Widget _buildPasswordStrengthIndicator() {
    if (_passwordStrength == PasswordStrength.none) {
      return const SizedBox.shrink();
    }

    final strengthConfig = _getStrengthConfig(_passwordStrength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Password Strength: ',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              strengthConfig['label'] as String,
              style: AppTypography.bodySmall.copyWith(
                color: strengthConfig['color'] as Color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          child: LinearProgressIndicator(
            value: strengthConfig['progress'] as double,
            backgroundColor: AppColors.zinc200,
            valueColor: AlwaysStoppedAnimation<Color>(
              strengthConfig['color'] as Color,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  /// Get configuration for password strength display
  Map<String, dynamic> _getStrengthConfig(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return {
          'label': 'Weak',
          'color': AppColors.error,
          'progress': 0.33,
        };
      case PasswordStrength.medium:
        return {
          'label': 'Medium',
          'color': AppColors.warning,
          'progress': 0.66,
        };
      case PasswordStrength.strong:
        return {
          'label': 'Strong',
          'color': AppColors.success,
          'progress': 1.0,
        };
      case PasswordStrength.none:
        return {
          'label': '',
          'color': AppColors.zinc300,
          'progress': 0.0,
        };
    }
  }

  /// Build password requirements card
  Widget _buildPasswordRequirements() {
    final password = _newPasswordController.text;

    return Card(
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
              'Password Requirements',
              style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildRequirementItem(
              'At least 8 characters',
              password.length >= 8,
            ),
            _buildRequirementItem(
              'Contains lowercase letter',
              password.contains(RegExp(r'[a-z]')),
            ),
            _buildRequirementItem(
              'Contains uppercase letter',
              password.contains(RegExp(r'[A-Z]')),
            ),
            _buildRequirementItem(
              'Contains a number',
              password.contains(RegExp(r'[0-9]')),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual requirement item
  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: isMet ? AppColors.success : AppColors.zinc400,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: isMet ? AppColors.textPrimary : AppColors.textSecondary,
              decoration: isMet ? TextDecoration.none : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Build success content after password reset
  Widget _buildSuccessContent() {
    return Column(
      children: [
        // Success message card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.verified_outlined, color: AppColors.success, size: 48),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Password Successfully Reset',
                style: AppTypography.h4.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'You can now sign in with your new password',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Auto-redirect message
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.electricBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(
              color: AppColors.electricBlue.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.electricBlue,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Redirecting to login...',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.electricBlue,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Manual navigation button
        CustomButton(
          text: 'Go to Sign In',
          onPressed: _navigateToLogin,
          variant: CustomButtonVariant.outline,
          size: CustomButtonSize.large,
          isFullWidth: true,
          prefixIcon: Icons.login,
        ),
      ],
    );
  }
}

/// Password strength enumeration
enum PasswordStrength {
  none,
  weak,
  medium,
  strong,
}
