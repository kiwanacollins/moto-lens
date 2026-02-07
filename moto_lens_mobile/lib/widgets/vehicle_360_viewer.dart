import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/vehicle_viewer.dart';
import '../../styles/styles.dart';

/// Drag-to-rotate vehicle image viewer.
///
/// Mirrors the PWA's `Custom360Viewer` exactly:
/// - Horizontal drag / swipe rotates through images
/// - Thumbnail blur placeholder while full image loads
/// - Prev / Next navigation buttons
/// - "Drag to rotate" hint that auto-fades after 3 s
/// - Image counter overlay
/// - Autoplay support
class Vehicle360Viewer extends StatefulWidget {
  final List<VehicleImage> images;
  final bool loading;
  final String vehicleName;
  final double height;

  /// Pixels per step: low=40, medium=20, high=10.
  final String dragSensitivity;
  final bool enableAutoplay;
  final int autoplaySpeedMs;

  const Vehicle360Viewer({
    super.key,
    required this.images,
    this.loading = false,
    this.vehicleName = '',
    this.height = 300,
    this.dragSensitivity = 'medium',
    this.enableAutoplay = false,
    this.autoplaySpeedMs = 2000,
  });

  @override
  State<Vehicle360Viewer> createState() => _Vehicle360ViewerState();
}

class _Vehicle360ViewerState extends State<Vehicle360Viewer> {
  int _currentIndex = 0;
  bool _isDragging = false;
  double _dragStartX = 0;
  bool _showHint = true;
  Timer? _hintTimer;
  Timer? _autoplayTimer;

  List<VehicleImage> get _validImages =>
      widget.images.where((i) => i.success && i.imageUrl.isNotEmpty).toList();

  int get _sensitivity {
    switch (widget.dragSensitivity) {
      case 'low':
        return 40;
      case 'high':
        return 10;
      default:
        return 20;
    }
  }

  @override
  void initState() {
    super.initState();
    _hintTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showHint = false);
    });
    _startAutoplay();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _autoplayTimer?.cancel();
    super.dispose();
  }

  void _startAutoplay() {
    if (!widget.enableAutoplay) return;
    _autoplayTimer = Timer.periodic(
      Duration(milliseconds: widget.autoplaySpeedMs),
      (_) {
        if (!_isDragging && _validImages.length > 1 && mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % _validImages.length;
          });
        }
      },
    );
  }

  void _stopAutoplay() {
    _autoplayTimer?.cancel();
    _autoplayTimer = null;
  }

  // ---------------------------------------------------------------------------
  // Drag / swipe
  // ---------------------------------------------------------------------------

  void _onDragStart(double x) {
    _isDragging = true;
    _dragStartX = x;
    _stopAutoplay();
  }

  void _onDragUpdate(double x) {
    if (!_isDragging || _validImages.length <= 1) return;

    final dx = x - _dragStartX;
    final steps = (dx.abs() / _sensitivity).floor();

    if (steps > 0) {
      final direction = dx > 0 ? 1 : -1;
      final len = _validImages.length;
      final newIndex = ((_currentIndex + direction * steps) % len + len) % len;

      setState(() {
        _currentIndex = newIndex;
        _dragStartX = x;
      });
    }
  }

  void _onDragEnd() => _isDragging = false;

  void _goNext() {
    if (_validImages.length <= 1) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _validImages.length;
    });
  }

  void _goPrev() {
    if (_validImages.length <= 1) return;
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + _validImages.length) % _validImages.length;
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (widget.loading) return _buildLoadingState();
    if (_validImages.isEmpty) return _buildErrorState();

    final current = _validImages[_currentIndex];

    return Container(
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: GestureDetector(
        onHorizontalDragStart: (d) => _onDragStart(d.globalPosition.dx),
        onHorizontalDragUpdate: (d) => _onDragUpdate(d.globalPosition.dx),
        onHorizontalDragEnd: (_) => _onDragEnd(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.zinc50, AppColors.zinc100],
                ),
              ),
            ),

            // Vehicle image
            Center(
              child: CachedNetworkImage(
                imageUrl: current.imageUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => _buildPlaceholder(current),
                errorWidget: (_, __, ___) => const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.zinc400,
                  size: 48,
                ),
              ),
            ),

            // "Drag to rotate" hint
            if (_showHint && _validImages.length > 1) _buildDragHint(),

            // Source badge (top-right)
            if (current.searchEngine != null)
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.carbonBlack.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  ),
                  child: Text(
                    current.searchEngine ?? 'web',
                    style: AppTypography.codeSmall.copyWith(
                      color: AppColors.electricBlue,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),

            // Bottom info bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(current),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-widgets
  // ---------------------------------------------------------------------------

  Widget _buildPlaceholder(VehicleImage current) {
    if (current.thumbnail != null && current.thumbnail!.isNotEmpty) {
      return Opacity(
        opacity: 0.7,
        child: CachedNetworkImage(
          imageUrl: current.thumbnail!,
          fit: BoxFit.contain,
          // ignore thumbnail errors
          errorWidget: (_, __, ___) => const SizedBox.shrink(),
        ),
      );
    }
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricBlue),
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildDragHint() {
    return Center(
      child: AnimatedOpacity(
        opacity: _showHint ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.carbonBlack.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.touch_app, color: AppColors.electricBlue, size: 20),
              SizedBox(width: AppSpacing.xs),
              Text(
                'Drag to rotate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Icon(Icons.rotate_right, color: AppColors.electricBlue, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(VehicleImage current) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.carbonBlack.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Row(
        children: [
          // Vehicle name + counter
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.vehicleName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_currentIndex + 1} of ${_validImages.length}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),

          // Nav buttons
          if (_validImages.length > 1) ...[
            _buildNavButton(Icons.rotate_left, _goPrev),
            const SizedBox(width: AppSpacing.xs),
            _buildNavButton(Icons.rotate_right, _goNext),
          ],
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppColors.electricBlue.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricBlue),
              strokeWidth: 3,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Loading Vehicle Images...',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.vehicleName.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                widget.vehicleName,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.zinc400,
                size: 40,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No Images Available',
                style: AppTypography.h5.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Unable to load vehicle images. Please try again.',
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
