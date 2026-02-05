import 'package:flutter/material.dart';
import '../styles/styles.dart';

/// Loading Spinner Widget
///
/// Professional, branded loading indicators for MotoLens
/// Supports multiple sizes and styles with Electric Blue styling
/// Built for automotive precision and user feedback
class LoadingSpinner extends StatelessWidget {
  /// Size of the spinner
  final LoadingSpinnerSize size;
  
  /// Color of the spinner
  final Color? color;
  
  /// Stroke width of the spinner
  final double? strokeWidth;
  
  /// Loading message to display below spinner
  final String? message;
  
  /// Whether to center the spinner
  final bool centered;

  const LoadingSpinner({
    Key? key,
    this.size = LoadingSpinnerSize.medium,
    this.color,
    this.strokeWidth,
    this.message,
    this.centered = false,
  }) : super(key: key);

  /// Small spinner constructor
  const LoadingSpinner.small({
    Key? key,
    Color? color,
    bool centered = false,
  }) : this(
          key: key,
          size: LoadingSpinnerSize.small,
          color: color,
          centered: centered,
        );

  /// Medium spinner constructor
  const LoadingSpinner.medium({
    Key? key,
    Color? color,
    String? message,
    bool centered = false,
  }) : this(
          key: key,
          size: LoadingSpinnerSize.medium,
          color: color,
          message: message,
          centered: centered,
        );

  /// Large spinner constructor
  const LoadingSpinner.large({
    Key? key,
    Color? color,
    String? message,
    bool centered = true,
  }) : this(
          key: key,
          size: LoadingSpinnerSize.large,
          color: color,
          message: message,
          centered: centered,
        );

  @override
  Widget build(BuildContext context) {
    final spinner = _buildSpinner();
    
    if (centered) {
      return Center(child: spinner);
    }
    
    return spinner;
  }

  Widget _buildSpinner() {
    final spinnerWidget = SizedBox(
      width: _getSize(),
      height: _getSize(),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.electricBlue,
        ),
        strokeWidth: strokeWidth ?? _getStrokeWidth(),
      ),
    );

    if (message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          spinnerWidget,
          const SizedBox(height: AppSpacing.md),
          Text(
            message!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return spinnerWidget;
  }

  double _getSize() {
    switch (size) {
      case LoadingSpinnerSize.small:
        return 16.0;
      case LoadingSpinnerSize.medium:
        return 24.0;
      case LoadingSpinnerSize.large:
        return 48.0;
      case LoadingSpinnerSize.extraLarge:
        return 64.0;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case LoadingSpinnerSize.small:
        return 2.0;
      case LoadingSpinnerSize.medium:
        return 3.0;
      case LoadingSpinnerSize.large:
        return 4.0;
      case LoadingSpinnerSize.extraLarge:
        return 5.0;
    }
  }
}

/// Page Loading Overlay
///
/// Full-screen loading overlay with backdrop
/// Use when loading entire pages or performing major operations
class PageLoadingOverlay extends StatelessWidget {
  /// Loading message
  final String? message;
  
  /// Background color opacity
  final double backgroundOpacity;

  const PageLoadingOverlay({
    Key? key,
    this.message = 'Loading...',
    this.backgroundOpacity = 0.7,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.carbonBlack.withOpacity(backgroundOpacity),
      child: LoadingSpinner.large(
        message: message,
        color: Colors.white,
      ),
    );
  }
}

/// Inline Loading Widget
///
/// Compact loading indicator for inline use in lists, cards, etc.
/// Preserves layout space while loading
class InlineLoading extends StatelessWidget {
  /// Loading text
  final String text;
  
  /// Text style
  final TextStyle? textStyle;

  const InlineLoading({
    Key? key,
    this.text = 'Loading...',
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LoadingSpinner.small(),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: textStyle ?? AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Automotive Loading Animation
///
/// Custom branded loading animation for automotive context
/// Features car icon with rotating animation
class AutomotiveLoading extends StatefulWidget {
  /// Size of the animation
  final double size;
  
  /// Loading message
  final String? message;

  const AutomotiveLoading({
    Key? key,
    this.size = 60.0,
    this.message,
  }) : super(key: key);

  @override
  State<AutomotiveLoading> createState() => _AutomotiveLoadingState();
}

class _AutomotiveLoadingState extends State<AutomotiveLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border,
                        width: 2.0,
                      ),
                    ),
                  ),
                  
                  // Animated progress arc
                  SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: CircularProgressIndicator(
                      value: _animation.value,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.electricBlue,
                      ),
                      strokeWidth: 3.0,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  
                  // Car icon in center
                  Icon(
                    Icons.directions_car,
                    size: widget.size * 0.4,
                    color: AppColors.electricBlue,
                  ),
                ],
              );
            },
          ),
        ),
        
        if (widget.message != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            widget.message!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Shimmer Loading Effect
///
/// Skeleton loading animation for content placeholders
/// Use when loading lists, cards, or content blocks
class ShimmerLoading extends StatefulWidget {
  /// Child widget to apply shimmer effect to
  final Widget child;
  
  /// Whether shimmer is enabled
  final bool enabled;

  const ShimmerLoading({
    Key? key,
    required this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));
    
    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
              colors: const [
                AppColors.zinc200,
                AppColors.zinc100,
                AppColors.zinc200,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Loading spinner size enum
enum LoadingSpinnerSize {
  small,
  medium,
  large,
  extraLarge,
}