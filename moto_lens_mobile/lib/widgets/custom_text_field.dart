import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../styles/styles.dart';

/// Custom Text Field Widget
///
/// Professional, consistent input fields for German Car Medic
/// Supports validation, different input types, and automotive-specific inputs
/// Built with Electric Blue focus states and beautiful typography
class CustomTextField extends StatefulWidget {
  /// Field label
  final String? label;

  /// Field hint text
  final String? hintText;

  /// Initial value
  final String? initialValue;

  /// Text controller
  final TextEditingController? controller;

  /// Input type (email, password, VIN, etc.)
  final CustomTextFieldType type;

  /// Validation function
  final String? Function(String?)? validator;

  /// Callback when text changes
  final void Function(String)? onChanged;

  /// Callback when field is submitted
  final void Function(String)? onSubmitted;

  /// Whether field is required
  final bool isRequired;

  /// Whether field is disabled
  final bool isDisabled;

  /// Whether to show field as error state
  final bool hasError;

  /// Error message to display
  final String? errorMessage;

  /// Help text to display below field
  final String? helpText;

  /// Prefix icon
  final IconData? prefixIcon;

  /// Suffix icon
  final IconData? suffixIcon;

  /// Suffix icon callback
  final VoidCallback? onSuffixIconPressed;

  /// Maximum number of lines (for multiline text)
  final int maxLines;

  /// Maximum length of input
  final int? maxLength;

  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Focus node
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.initialValue,
    this.controller,
    this.type = CustomTextFieldType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.isRequired = false,
    this.isDisabled = false,
    this.hasError = false,
    this.errorMessage,
    this.helpText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
  });

  /// Email input constructor
  const CustomTextField.email({
    Key? key,
    String? label = 'Email',
    String? hintText = 'Enter your email address',
    String? initialValue,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    bool isRequired = false,
    bool isDisabled = false,
    bool hasError = false,
    String? errorMessage,
    String? helpText,
    FocusNode? focusNode,
  }) : this(
         key: key,
         label: label,
         hintText: hintText,
         initialValue: initialValue,
         controller: controller,
         type: CustomTextFieldType.email,
         validator: validator,
         onChanged: onChanged,
         onSubmitted: onSubmitted,
         isRequired: isRequired,
         isDisabled: isDisabled,
         hasError: hasError,
         errorMessage: errorMessage,
         helpText: helpText,
         prefixIcon: Icons.email,
         focusNode: focusNode,
       );

  /// Password input constructor
  const CustomTextField.password({
    Key? key,
    String? label = 'Password',
    String? hintText = 'Enter your password',
    String? initialValue,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    bool isRequired = false,
    bool isDisabled = false,
    bool hasError = false,
    String? errorMessage,
    String? helpText,
    FocusNode? focusNode,
  }) : this(
         key: key,
         label: label,
         hintText: hintText,
         initialValue: initialValue,
         controller: controller,
         type: CustomTextFieldType.password,
         validator: validator,
         onChanged: onChanged,
         onSubmitted: onSubmitted,
         isRequired: isRequired,
         isDisabled: isDisabled,
         hasError: hasError,
         errorMessage: errorMessage,
         helpText: helpText,
         prefixIcon: Icons.lock,
         focusNode: focusNode,
       );

  /// VIN input constructor
  const CustomTextField.vin({
    Key? key,
    String? label = 'VIN Number',
    String? hintText = 'Enter 17-character VIN',
    String? initialValue,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    bool isRequired = false,
    bool isDisabled = false,
    bool hasError = false,
    String? errorMessage,
    String? helpText,
    FocusNode? focusNode,
  }) : this(
         key: key,
         label: label,
         hintText: hintText,
         initialValue: initialValue,
         controller: controller,
         type: CustomTextFieldType.vin,
         validator: validator,
         onChanged: onChanged,
         onSubmitted: onSubmitted,
         isRequired: isRequired,
         isDisabled: isDisabled,
         hasError: hasError,
         errorMessage: errorMessage,
         helpText: helpText,
         prefixIcon: Icons.directions_car,
         maxLength: 17,
         focusNode: focusNode,
       );

  /// Search input constructor
  const CustomTextField.search({
    Key? key,
    String? label,
    String? hintText = 'Search...',
    String? initialValue,
    TextEditingController? controller,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    bool isDisabled = false,
    FocusNode? focusNode,
  }) : this(
         key: key,
         label: label,
         hintText: hintText,
         initialValue: initialValue,
         controller: controller,
         type: CustomTextFieldType.search,
         onChanged: onChanged,
         onSubmitted: onSubmitted,
         isDisabled: isDisabled,
         prefixIcon: Icons.search,
         focusNode: focusNode,
       );

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  bool _isPasswordVisible = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          _buildLabel(),
          const SizedBox(height: AppSpacing.labelInputSpacing),
        ],
        _buildTextField(),
        if (widget.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.errorMessageSpacing),
          _buildErrorMessage(),
        ],
        if (widget.helpText != null && widget.errorMessage == null) ...[
          const SizedBox(height: AppSpacing.xxs),
          _buildHelpText(),
        ],
      ],
    );
  }

  /// Build field label
  Widget _buildLabel() {
    return Text(
      widget.isRequired ? '${widget.label} *' : widget.label!,
      style: AppTypography.inputLabel.copyWith(
        color: _isFocused ? AppColors.electricBlue : AppColors.textSecondary,
      ),
    );
  }

  /// Build error message
  Widget _buildErrorMessage() {
    return Text(widget.errorMessage!, style: AppTypography.inputError);
  }

  /// Build help text
  Widget _buildHelpText() {
    return Text(widget.helpText!, style: AppTypography.bodySmall);
  }

  /// Build the main text field
  Widget _buildTextField() {
    return Focus(
      onFocusChange: (bool focused) {
        setState(() {
          _isFocused = focused;
        });
      },
      child: TextFormField(
        controller: _controller,
        focusNode: widget.focusNode,
        enabled: !widget.isDisabled,
        obscureText: _shouldObscureText(),
        keyboardType: _getKeyboardType(),
        textInputAction: _getTextInputAction(),
        inputFormatters: _getInputFormatters(),
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        style: AppTypography.inputText.copyWith(
          color: widget.isDisabled ? AppColors.textDisabled : null,
          fontFamily: _getFontFamily(),
        ),
        decoration: _buildInputDecoration(),
        validator: widget.validator,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
      ),
    );
  }

  /// Build input decoration
  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      hintText: widget.hintText,
      prefixIcon: widget.prefixIcon != null
          ? Icon(
              widget.prefixIcon,
              color: _isFocused
                  ? AppColors.electricBlue
                  : (widget.isDisabled
                        ? AppColors.textDisabled
                        : AppColors.textSecondary),
            )
          : null,
      suffixIcon: _buildSuffixIcon(),
      filled: true,
      fillColor: widget.isDisabled
          ? AppColors.zinc100
          : AppColors.backgroundSecondary,
      contentPadding: AppSpacing.inputPaddingEdgeInsets,
      border: _buildBorder(),
      enabledBorder: _buildBorder(),
      focusedBorder: _buildBorder(focused: true),
      errorBorder: _buildBorder(error: true),
      focusedErrorBorder: _buildBorder(error: true, focused: true),
      counterText: widget.maxLength != null ? null : '',
      errorStyle: const TextStyle(height: 0), // Hide default error text
    );
  }

  /// Build suffix icon (password visibility toggle, custom icon, etc.)
  Widget? _buildSuffixIcon() {
    if (widget.type == CustomTextFieldType.password) {
      return IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          color: _isFocused ? AppColors.electricBlue : AppColors.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: _isFocused ? AppColors.electricBlue : AppColors.textSecondary,
        ),
        onPressed: widget.onSuffixIconPressed,
      );
    }

    return null;
  }

  /// Build input border
  OutlineInputBorder _buildBorder({bool focused = false, bool error = false}) {
    Color borderColor;
    double borderWidth = 1.0;

    if (error) {
      borderColor = AppColors.borderError;
      borderWidth = focused ? 2.0 : 1.0;
    } else if (focused) {
      borderColor = AppColors.borderFocused;
      borderWidth = 2.0;
    } else {
      borderColor = AppColors.border;
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMedium)),
      borderSide: BorderSide(color: borderColor, width: borderWidth),
    );
  }

  /// Get appropriate keyboard type based on field type
  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case CustomTextFieldType.email:
        return TextInputType.emailAddress;
      case CustomTextFieldType.password:
        return TextInputType.text;
      case CustomTextFieldType.phone:
        return TextInputType.phone;
      case CustomTextFieldType.number:
        return TextInputType.number;
      case CustomTextFieldType.multiline:
        return TextInputType.multiline;
      case CustomTextFieldType.vin:
      case CustomTextFieldType.partNumber:
        return TextInputType.text;
      case CustomTextFieldType.search:
      case CustomTextFieldType.text:
        return TextInputType.text;
    }
  }

  /// Get text input action
  TextInputAction _getTextInputAction() {
    if (widget.type == CustomTextFieldType.multiline) {
      return TextInputAction.newline;
    } else if (widget.type == CustomTextFieldType.search) {
      return TextInputAction.search;
    } else {
      return TextInputAction.next;
    }
  }

  /// Get appropriate font family based on field type
  String _getFontFamily() {
    switch (widget.type) {
      case CustomTextFieldType.vin:
      case CustomTextFieldType.partNumber:
        return AppTypography.monoFontFamily;
      default:
        return AppTypography.primaryFontFamily;
    }
  }

  /// Get input formatters based on field type
  List<TextInputFormatter>? _getInputFormatters() {
    if (widget.inputFormatters != null) {
      return widget.inputFormatters;
    }

    switch (widget.type) {
      case CustomTextFieldType.vin:
        return [
          LengthLimitingTextInputFormatter(17),
          FilteringTextInputFormatter.allow(
            RegExp(r'[A-HJ-NPR-Z0-9]'),
          ), // Valid VIN characters
          UpperCaseTextFormatter(),
        ];
      case CustomTextFieldType.partNumber:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
          UpperCaseTextFormatter(),
        ];
      case CustomTextFieldType.phone:
        return [FilteringTextInputFormatter.digitsOnly];
      case CustomTextFieldType.number:
        return [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];
      default:
        return null;
    }
  }

  /// Determine if text should be obscured (for password fields)
  bool _shouldObscureText() {
    return widget.type == CustomTextFieldType.password && !_isPasswordVisible;
  }
}

/// Text field type enum
enum CustomTextFieldType {
  text,
  email,
  password,
  phone,
  number,
  multiline,
  search,
  vin,
  partNumber,
}

/// Uppercase text formatter for VIN and part numbers
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
