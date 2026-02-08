import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../models/part_scan_entry.dart';
import '../../providers/qr_scan_provider.dart';
import '../../styles/styles.dart';

/// Full Barcode Scanner screen with two modes:
///
/// 1. **Camera mode** — live barcode scanning via `mobile_scanner`
///    Supports Code 128, Code 39, EAN-13, UPC-A, and DataMatrix
///    formats commonly used on automotive parts.
/// 2. **Manual mode** — text-field entry for part numbers
///
/// After a code is captured (or typed) the provider performs a backend
/// lookup and the user is navigated to the part detail page.
///
/// **What automotive part barcodes contain:**
/// - OEM Part Number (e.g., 11-42-7-953-129 for BMW)
/// - Manufacturer identification code
/// - Batch/lot numbers for traceability
/// - Serial numbers for warranty tracking
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with WidgetsBindingObserver {
  // Camera
  MobileScannerController? _controller;
  bool _hasPermission = false;
  bool _permissionDenied = false;
  bool _isInitializing = true;
  bool _scanProcessed = false;
  bool _torchEnabled = false;
  String? _lastScannedValue;

  // Manual entry
  bool _showManualEntry = false;
  final _manualController = TextEditingController();
  final _manualFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndRequestPermission();

    // Load history when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QrScanProvider>().loadHistory();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _manualController.dispose();
    _manualFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _permissionDenied) {
      _checkAndRequestPermission();
    }
  }

  // ---------------------------------------------------------------------------
  // Permission & scanner init
  // ---------------------------------------------------------------------------

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
      // Barcode formats commonly used on automotive parts
      formats: [
        BarcodeFormat.code128, // Most common for auto parts
        BarcodeFormat.code39, // Widely used in automotive industry
        BarcodeFormat.ean13, // Retail parts
        BarcodeFormat.ean8, // Smaller retail parts
        BarcodeFormat.upcA, // North American parts
        BarcodeFormat.upcE, // Compact UPC
        BarcodeFormat.dataMatrix, // Small/dense labels
        BarcodeFormat.qrCode, // Some modern parts still use QR
      ],
    );
    setState(() => _isInitializing = false);
  }

  // ---------------------------------------------------------------------------
  // Scan handler
  // ---------------------------------------------------------------------------

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_scanProcessed) return;

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue == null || rawValue.trim().isEmpty) continue;

      final value = rawValue.trim();

      // Debounce same value
      if (value == _lastScannedValue) continue;
      _lastScannedValue = value;

      // Mark processed
      setState(() => _scanProcessed = true);
      HapticFeedback.mediumImpact();

      // Look up after a short visual pause
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _performLookup(value);
      });
      return;
    }
  }

  void _toggleTorch() {
    _controller?.toggleTorch();
    setState(() => _torchEnabled = !_torchEnabled);
  }

  // ---------------------------------------------------------------------------
  // Lookup
  // ---------------------------------------------------------------------------

  Future<void> _performLookup(String value) async {
    final provider = context.read<QrScanProvider>();
    await provider.lookupPart(value);

    if (!mounted) return;

    // Reset scanner for next scan
    setState(() {
      _scanProcessed = false;
      _lastScannedValue = null;
    });

    if (provider.currentPartDetails != null) {
      Navigator.pushNamed(context, '/part-detail');
    } else if (provider.error != null) {
      _showErrorSnackBar(provider.error!);
    }
  }

  void _submitManualEntry() {
    final value = _manualController.text.trim();
    if (value.isEmpty) return;

    _manualController.clear();
    _manualFocusNode.unfocus();
    setState(() => _showManualEntry = false);

    _performLookup(value);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<QrScanProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              // Camera / permission / manual entry
              if (_showManualEntry)
                _buildManualEntry(provider)
              else if (_isInitializing)
                _buildLoadingState()
              else if (!_hasPermission)
                _buildPermissionDeniedState()
              else if (_controller != null)
                _buildCameraPreview(),

              // Top bar
              _buildTopBar(),

              // Scan overlay
              if (_hasPermission && !_isInitializing && !_showManualEntry)
                _buildScanOverlay(provider),

              // Bottom controls
              if (!_showManualEntry) _buildBottomControls(provider),

              // Loading overlay
              if (provider.isLookingUp) _buildLookupOverlay(),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Loading state
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Permission denied
  // ---------------------------------------------------------------------------

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
                Icons.barcode_reader,
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
              'Moto Lens needs camera access to scan barcodes '
              'on vehicle parts. You can also enter part numbers manually.',
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
                onPressed: () => setState(() => _showManualEntry = true),
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
                  'Enter Part Number Manually',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Camera preview
  // ---------------------------------------------------------------------------

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
                  onPressed: () => setState(() => _showManualEntry = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricBlue,
                  ),
                  child: const Text('Enter Part Number Manually'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Scan overlay
  // ---------------------------------------------------------------------------

  Widget _buildScanOverlay(QrScanProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Horizontal rectangle for barcode scanning
        final scanWidth = constraints.maxWidth * 0.85;
        const scanHeight = 140.0;
        final left = (constraints.maxWidth - scanWidth) / 2;
        final top = (constraints.maxHeight - scanHeight) / 2 - 40;

        return Stack(
          children: [
            // Semi-transparent overlay with horizontal cutout
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.55),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: scanWidth,
                      height: scanHeight,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Corner markers for barcode area
            Positioned(
              left: left,
              top: top,
              child: _ScanAreaBorder(
                width: scanWidth,
                height: scanHeight,
                isScanned: _scanProcessed,
              ),
            ),

            // Instruction text
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: top + scanHeight + AppSpacing.lg,
              child: Column(
                children: [
                  Text(
                    _scanProcessed
                        ? 'Barcode Detected!'
                        : 'Align the barcode within the frame',
                    style: TextStyle(
                      color: _scanProcessed ? AppColors.success : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Supports Code 128, Code 39, EAN-13, UPC & QR',
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

  // ---------------------------------------------------------------------------
  // Top bar
  // ---------------------------------------------------------------------------

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
            _buildCircleButton(
              icon: Icons.close,
              onTap: () => Navigator.pop(context),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Text(
                _showManualEntry ? 'Enter Part Number' : 'Scan Barcode',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (_hasPermission && !_isInitializing && !_showManualEntry)
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

  // ---------------------------------------------------------------------------
  // Bottom controls
  // ---------------------------------------------------------------------------

  Widget _buildBottomControls(QrScanProvider provider) {
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
              // Recent scans
              if (provider.hasHistory) ...[
                _buildRecentScans(provider),
                const SizedBox(height: AppSpacing.md),
              ],

              // Manual entry toggle
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      setState(() => _showManualEntry = !_showManualEntry),
                  icon: Icon(
                    _showManualEntry ? Icons.barcode_reader : Icons.keyboard,
                    size: 20,
                  ),
                  label: Text(
                    _showManualEntry
                        ? 'Switch to Camera'
                        : 'Enter Part Number Manually',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
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

  Widget _buildRecentScans(QrScanProvider provider) {
    final recent = provider.history.take(3).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Scans',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ...recent.map((entry) => _buildRecentTile(entry, provider)),
        ],
      ),
    );
  }

  Widget _buildRecentTile(PartScanEntry entry, QrScanProvider provider) {
    return InkWell(
      onTap: () => provider.lookupFromHistory(entry).then((_) {
        if (mounted && provider.currentPartDetails != null) {
          Navigator.pushNamed(context, '/part-detail');
        }
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        child: Row(
          children: [
            Icon(
              entry.isResolved ? Icons.check_circle : Icons.barcode_reader,
              color: entry.isResolved
                  ? AppColors.success
                  : AppColors.electricBlue,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                entry.displayLabel,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              entry.formattedDate,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Manual entry view
  // ---------------------------------------------------------------------------

  Widget _buildManualEntry(QrScanProvider provider) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          80, // below top bar
          AppSpacing.lg,
          120, // above bottom controls
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              ),
              child: const Icon(
                Icons.keyboard_alt_outlined,
                color: AppColors.electricBlue,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Enter Part Number',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Type the part number, name, or any text from the barcode label.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Input
            TextField(
              controller: _manualController,
              focusNode: _manualFocusNode,
              autofocus: true,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'JetBrains Mono',
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. 11-42-7-953-129',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 18,
                  fontFamily: 'JetBrains Mono',
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  borderSide: const BorderSide(
                    color: AppColors.electricBlue,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: AppColors.electricBlue),
                  onPressed: _submitManualEntry,
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _submitManualEntry(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // History list in manual mode
            if (provider.hasHistory) ...[
              const Text(
                'SCAN HISTORY',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: ListView.separated(
                  itemCount: provider.history.length,
                  separatorBuilder: (_, __) => Divider(
                    color: Colors.white.withValues(alpha: 0.1),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final entry = provider.history[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        entry.isResolved
                            ? Icons.check_circle
                            : Icons.barcode_reader,
                        color: entry.isResolved
                            ? AppColors.success
                            : AppColors.electricBlue,
                      ),
                      title: Text(
                        entry.displayLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        entry.formattedDate,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.white24,
                      ),
                      onTap: () {
                        _manualController.text = entry.scannedValue;
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Lookup overlay
  // ---------------------------------------------------------------------------

  Widget _buildLookupOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricBlue),
              strokeWidth: 3,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Looking up part...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Scan area border with animated scan line
// =============================================================================

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
          // Corners
          _buildCorner(Alignment.topLeft, color),
          _buildCorner(Alignment.topRight, color),
          _buildCorner(Alignment.bottomLeft, color),
          _buildCorner(Alignment.bottomRight, color),

          // Animated scan line (vertical for horizontal barcode)
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

          // Success
          if (widget.isScanned)
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.success,
                  size: 32,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment, Color color) {
    const cornerLength = 28.0;
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
