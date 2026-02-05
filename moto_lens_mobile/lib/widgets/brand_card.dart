import 'package:flutter/material.dart';
import '../styles/styles.dart';

/// Brand Card Widget
///
/// Professional card component for automotive data display
/// Optimized for VIN results, part information, and vehicle details
/// Features MotoLens branding and consistent styling
class BrandCard extends StatelessWidget {
  /// Card title
  final String? title;

  /// Card subtitle
  final String? subtitle;

  /// Main content widget
  final Widget? child;

  /// Leading icon or widget
  final Widget? leading;

  /// Trailing widget (action buttons, chips, etc.)
  final Widget? trailing;

  /// Card background color
  final Color? backgroundColor;

  /// Card border color
  final Color? borderColor;

  /// Card padding
  final EdgeInsets? padding;

  /// Card margin
  final EdgeInsets? margin;

  /// Card elevation
  final double? elevation;

  /// On tap callback
  final VoidCallback? onTap;

  /// Whether card is selected/active
  final bool isSelected;

  /// Whether card is disabled
  final bool isDisabled;

  /// Whether to show loading state
  final bool isLoading;

  const BrandCard({
    super.key,
    this.title,
    this.subtitle,
    this.child,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.margin,
    this.elevation,
    this.onTap,
    this.isSelected = false,
    this.isDisabled = false,
    this.isLoading = false,
  });

  /// Vehicle information card constructor
  const BrandCard.vehicleInfo({
    Key? key,
    required String make,
    required String model,
    required String year,
    String? vin,
    Widget? trailing,
    VoidCallback? onTap,
    bool isSelected = false,
  }) : this(
         key: key,
         title: '$year $make $model',
         subtitle: vin,
         leading: const Icon(
           Icons.directions_car,
           color: AppColors.electricBlue,
           size: 24,
         ),
         trailing: trailing,
         onTap: onTap,
         isSelected: isSelected,
       );

  /// Part information card constructor
  BrandCard.partInfo({
    Key? key,
    required String partName,
    required String partNumber,
    String? category,
    Widget? trailing,
    VoidCallback? onTap,
    bool isSelected = false,
  }) : this(
         key: key,
         title: partName,
         subtitle: 'Part #$partNumber',
         leading: Icon(
           _getPartIcon(category),
           color: AppColors.electricBlue,
           size: 24,
         ),
         trailing: trailing,
         onTap: onTap,
         isSelected: isSelected,
       );

  /// Service card constructor
  BrandCard.service({
    Key? key,
    required String serviceName,
    required String description,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
    bool isSelected = false,
  }) : this(
         key: key,
         title: serviceName,
         subtitle: description,
         leading: Icon(icon, color: AppColors.electricBlue, size: 24),
         trailing: trailing,
         onTap: onTap,
         isSelected: isSelected,
       );

  /// Content card constructor for custom layouts
  const BrandCard.content({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    VoidCallback? onTap,
    bool isSelected = false,
  }) : this(
         key: key,
         child: child,
         padding: padding,
         margin: margin,
         backgroundColor: backgroundColor,
         onTap: onTap,
         isSelected: isSelected,
       );

  static IconData _getPartIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'engine':
        return Icons.settings;
      case 'brake':
      case 'brakes':
        return Icons.disc_full;
      case 'electrical':
        return Icons.electrical_services;
      case 'body':
        return Icons.directions_car;
      case 'interior':
        return Icons.airline_seat_legroom_normal;
      case 'suspension':
        return Icons.height;
      default:
        return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = _getBackgroundColor();
    final effectiveBorderColor = _getBorderColor();
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.md);
    final effectiveMargin =
        margin ??
        const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        );

    Widget cardContent = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: effectiveBorderColor,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          if (elevation != null && elevation! > 0)
            BoxShadow(
              color: AppColors.zinc200.withOpacity(0.5),
              offset: const Offset(0, 2),
              blurRadius: elevation! * 2,
              spreadRadius: 0,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          child: Padding(padding: effectivePadding, child: _buildCardContent()),
        ),
      ),
    );

    return Container(margin: effectiveMargin, child: cardContent);
  }

  Widget _buildCardContent() {
    if (child != null) {
      return child!;
    }

    if (title == null && subtitle == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        // Leading widget
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSpacing.sm),
        ],

        // Title and subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: AppTypography.h6.copyWith(
                    color: isDisabled
                        ? AppColors.textDisabled
                        : AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle!,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDisabled
                        ? AppColors.textDisabled
                        : AppColors.textSecondary,
                    fontFamily: _isCodeText(subtitle!)
                        ? AppTypography.monoFontFamily
                        : AppTypography.primaryFontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        // Trailing widget
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ],

        // Loading indicator
        if (isLoading) ...[
          const SizedBox(width: AppSpacing.sm),
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricBlue),
            ),
          ),
        ],
      ],
    );
  }

  Color _getBackgroundColor() {
    if (isDisabled) {
      return AppColors.zinc100;
    }

    if (isSelected) {
      return AppColors.electricBlue.withOpacity(0.1);
    }

    return backgroundColor ?? AppColors.surface;
  }

  Color _getBorderColor() {
    if (isDisabled) {
      return AppColors.zinc200;
    }

    if (isSelected) {
      return AppColors.electricBlue;
    }

    return borderColor ?? AppColors.border;
  }

  /// Check if text appears to be a code (VIN, part number, etc.)
  bool _isCodeText(String text) {
    // Simple heuristic: if text is mostly uppercase and contains numbers
    final hasNumbers = text.contains(RegExp(r'\d'));
    final hasUppercase = text.contains(RegExp(r'[A-Z]'));
    final isShort = text.length <= 20;

    return hasNumbers && hasUppercase && isShort;
  }
}

/// Expandable Brand Card
///
/// Card that can expand to show additional content
/// Perfect for detailed vehicle or part information
class ExpandableBrandCard extends StatefulWidget {
  /// Card title
  final String title;

  /// Card subtitle
  final String? subtitle;

  /// Leading widget
  final Widget? leading;

  /// Collapsed content (shown when collapsed)
  final Widget? collapsedContent;

  /// Expanded content (shown when expanded)
  final Widget expandedContent;

  /// Initially expanded state
  final bool initiallyExpanded;

  /// On expansion changed callback
  final void Function(bool isExpanded)? onExpansionChanged;

  const ExpandableBrandCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.collapsedContent,
    required this.expandedContent,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
  });

  @override
  State<ExpandableBrandCard> createState() => _ExpandableBrandCardState();
}

class _ExpandableBrandCardState extends State<ExpandableBrandCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
      widget.onExpansionChanged?.call(_isExpanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BrandCard(
      onTap: _toggleExpanded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: AppSpacing.sm),
              ],

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTypography.h6,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        widget.subtitle!,
                        style: AppTypography.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Expand/collapse icon
              AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.electricBlue,
                ),
              ),
            ],
          ),

          // Collapsed content
          if (widget.collapsedContent != null && !_isExpanded) ...[
            const SizedBox(height: AppSpacing.sm),
            widget.collapsedContent!,
          ],

          // Expanded content with animation
          SizeTransition(
            sizeFactor: _animation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sm),
                const Divider(color: AppColors.border),
                const SizedBox(height: AppSpacing.sm),
                widget.expandedContent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
