import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../styles/styles.dart';
import '../utils/vin_validator.dart';

/// Full-screen camera scanner for VIN barcodes
///
/// Supports Code 39, Code 128, DataMatrix, and QR code formats
/// commonly used for vehicle VIN barcodes. Includes:
/// - Live camera preview with scan region overlay
/// - Flashlight toggle for garage/low-light environments
/// - Auto-detection with VIN validation before accepting
/// - Permission handling with user-friendly prompts
/// - Haptic feedback on successful scan
class VinCameraScanner extends StatefulWidget {
  /// Called when a valid VIN barcode is detected
  final ValueChanged<String> onVinDetected;

  /// Called when the user closes the scanner
  final VoidCallback onClose;

  const VinCameraScanner({
    super.key,
    required this.onVinDetected,
    required this.onClose,
  });

  @override
  State<VinCameraScanner> createState() => _VinCameraScannerState();
}

class _VinCameraScannerState extends State<VinCameraScanner>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _hasPermission = false;
  bool _permissionDenied = false;
  bool _isInitializing = true;
  bool _scanProcessed = false;
  bool _torchEnabled = false;
  String? _lastScannedValue;
  String? _scanFeedback;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndRequestPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check permission when returning from settings
    if (state == AppLifecycleState.resumed && _permissionDenied) {
      _checkAndRequestPermission();
    }
  }

  Future<void> _checkAndRequestPermission() async {
    setState(() {
      _isInitializing = true;
      _permissionDenied = false;
    });

    final status = await Permission.camera.request();

    if (!mounted) return;

    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
        _permissionDenied = false;
      });
      _initializeScanner();
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _hasPermission = false;
        _permissionDenied = true;
        _isInitializing = false;
      });
    } else {
      setState(() {
        _hasPermission = false;
        _permissionDenied = true;
        _isInitializing = false;
      });
    }
  }

  void _initializeScanner() {
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      formats: [
        BarcodeFormat.code39,
        BarcodeFormat.code128,
        BarcodeFormat.dataMatrix,
        BarcodeFormat.qrCode,
      ],
    );

    setState(() => _isInitializing = false);
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_scanProcessed) return;

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue == null || rawValue.isEmpty) continue;

      // Normalize: uppercase, trim
      final normalized = rawValue.toUpperCase().trim();

      // Skip if same as last scanned (debounce)
      if (normalized == _lastScannedValue) continue;
      _lastScannedValue = normalized;

      // Check if this looks like a VIN (17 alphanumeric chars)
      if (normalized.length != VinValidator.vinLength) {
        setState(() {
          _scanFeedback =
              'Detected ${normalized.length} chars — VIN must be 17';
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _scanFeedback = null);
        });
        continue;
      }

      // Validate as VIN
      final validation = VinValidator.validate(normalized);
      if (!validation.isValid) {
        setState(() {
          _scanFeedback = validation.error ?? 'Invalid VIN format';
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _scanFeedback = null);
        });
        continue;
      }

      // Valid VIN detected
      setState(() => _scanProcessed = true);

      // Brief delay for visual feedback before returning
      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onVinDetected(normalized);
      });
      return;
    }
  }

  void _toggleTorch() {
    _controller?.toggleTorch();
    setState(() => _torchEnabled = !_torchEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview or permission state
          if (_isInitializing)
            _buildLoadingState()
          else if (!_hasPermission)
            _buildPermissionDeniedState()
          else if (_controller != null)
            _buildCameraPreview(),

          // Top bar with close button
          _buildTopBar(),

          // Scan overlay with viewfinder
          if (_hasPermission && !_isInitializing) _buildScanOverlay(),

          // Bottom controls
          if (_hasPermission && !_isInitializing) _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricBlue),
            strokeWidth: 3,
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Initializing camera...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.electricBlue,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Camera Permission Required',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'German Car Medic needs camera access to scan VIN barcodes on vehicles. '
              'You can also enter VINs manually.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => openAppSettings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusMedium,
                    ),
                  ),
                ),
                child: const Text(
                  'Open Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: widget.onClose,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusMedium,
                    ),
                  ),
                ),
                child: const Text(
                  'Enter VIN Manually',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return MobileScanner(
      controller: _controller!,
      onDetect: _onBarcodeDetected,
      errorBuilder: (context, error) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Camera Error',
                  style: AppTypography.h4.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  error.errorDetails?.message ?? 'Failed to initialize camera',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: widget.onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricBlue,
                  ),
                  child: const Text('Enter VIN Manually'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Close button
            _buildCircleButton(icon: Icons.close, onTap: widget.onClose),
            // Title
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: const Text(
                'Scan VIN Barcode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Torch toggle
            if (_hasPermission && !_isInitializing)
              _buildCircleButton(
                icon: _torchEnabled ? Icons.flash_on : Icons.flash_off,
                onTap: _toggleTorch,
                isActive: _torchEnabled,
              )
            else
              const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.electricBlue.withValues(alpha: 0.9)
              : Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildScanOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaWidth = constraints.maxWidth * 0.85;
        const scanAreaHeight = 120.0; // Narrow horizontal strip for barcode
        final left = (constraints.maxWidth - scanAreaWidth) / 2;
        final top = (constraints.maxHeight - scanAreaHeight) / 2 - 40;

        return Stack(
          children: [
            // Semi-transparent overlay with cutout
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.55),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  // Full coverage
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  // Cutout for scan area
                  Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: scanAreaWidth,
                      height: scanAreaHeight,
                      decoration: BoxDecoration(
                        color: Colors.red, // Any color, will be cut out
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scan area border (animated)
            Positioned(
              left: left,
              top: top,
              child: _ScanAreaBorder(
                width: scanAreaWidth,
                height: scanAreaHeight,
                isScanned: _scanProcessed,
              ),
            ),

            // Instruction text below scan area
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: top + scanAreaHeight + AppSpacing.lg,
              child: Column(
                children: [
                  Text(
                    _scanProcessed
                        ? 'VIN Detected!'
                        : 'Align the VIN barcode within the frame',
                    style: TextStyle(
                      color: _scanProcessed ? AppColors.success : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_scanFeedback != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSmall,
                        ),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        _scanFeedback!,
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Supports Code 39, Code 128, DataMatrix & QR',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
                Colors.black.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tip text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.electricBlue,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Look for the VIN barcode on the driver-side door jamb, '
                        'dashboard, or under the windshield.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Manual entry button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.keyboard, size: 20),
                  label: const Text(
                    'Enter VIN Manually',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusMedium,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated scan area border with corner markers
class _ScanAreaBorder extends StatefulWidget {
  final double width;
  final double height;
  final bool isScanned;

  const _ScanAreaBorder({
    required this.width,
    required this.height,
    this.isScanned = false,
  });

  @override
  State<_ScanAreaBorder> createState() => _ScanAreaBorderState();
}

class _ScanAreaBorderState extends State<_ScanAreaBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isScanned ? AppColors.success : AppColors.electricBlue;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // Corner markers
          _buildCorner(Alignment.topLeft, color),
          _buildCorner(Alignment.topRight, color),
          _buildCorner(Alignment.bottomLeft, color),
          _buildCorner(Alignment.bottomRight, color),

          // Animated scan line
          if (!widget.isScanned)
            AnimatedBuilder(
              animation: _scanLineAnimation,
              builder: (context, child) {
                return Positioned(
                  left: 8,
                  right: 8,
                  top: _scanLineAnimation.value * (widget.height - 4),
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.electricBlue.withValues(alpha: 0.8),
                          AppColors.electricBlue,
                          AppColors.electricBlue.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                );
              },
            ),

          // Success checkmark
          if (widget.isScanned)
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.success,
                  size: 28,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment, Color color) {
    const cornerLength = 24.0;
    const thickness = 3.0;

    final isTop =
        alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isLeft =
        alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      child: SizedBox(
        width: cornerLength,
        height: cornerLength,
        child: CustomPaint(
          painter: _CornerPainter(
            color: color,
            thickness: thickness,
            isTop: isTop,
            isLeft: isLeft,
          ),
        ),
      ),
    );
  }
}

/// Paints a single corner bracket
class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool isTop;
  final bool isLeft;

  _CornerPainter({
    required this.color,
    required this.thickness,
    required this.isTop,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
