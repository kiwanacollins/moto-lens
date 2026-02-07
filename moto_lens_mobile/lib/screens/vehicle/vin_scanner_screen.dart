import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../styles/styles.dart';
import '../../widgets/widgets.dart';
import '../../utils/vin_validator.dart';
import '../../models/vehicle/vin_decode_result.dart';
import '../../models/vehicle/vin_scan_entry.dart';
import '../../services/api_service.dart';
import '../../services/vin_history_service.dart';
import '../../utils/error_handler.dart';

/// VIN Scanner & Input Screen for German Car Medic
///
/// Features:
/// - Manual VIN input with real-time 17-character validation
/// - Uppercase transformation with JetBrains Mono font
/// - Real-time format checking with inline manufacturer detection
/// - Sample VIN button for testing
/// - VIN scan history (local + synced)
/// - Quick re-scan from history
/// - Offline scan caching
/// - Connected to backend `/api/vehicle/decode` endpoint
/// - Professional German Car Medic branding with loading states
/// - Graceful API error handling
class VinScannerScreen extends StatefulWidget {
  const VinScannerScreen({super.key});

  @override
  State<VinScannerScreen> createState() => _VinScannerScreenState();
}

class _VinScannerScreenState extends State<VinScannerScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _vinController = TextEditingController();
  final FocusNode _vinFocusNode = FocusNode();
  final ApiService _apiService = ApiService();
  final VinHistoryService _historyService = VinHistoryService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // State
  VinValidationResult? _validationResult;
  VinDecodeResult? _decodeResult;
  List<VinScanEntry> _scanHistory = [];
  bool _isDecoding = false;
  bool _isLoadingHistory = true;
  String? _decodeError;
  bool _showHistory = false;
  bool _showCameraScanner = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

    _vinController.addListener(_onVinChanged);
    _loadHistory();
  }

  @override
  void dispose() {
    _vinController.removeListener(_onVinChanged);
    _vinController.dispose();
    _vinFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onVinChanged() {
    final text = _vinController.text.trim();
    setState(() {
      _decodeError = null;
      _decodeResult = null;
      if (text.isEmpty) {
        _validationResult = null;
      } else {
        _validationResult = VinValidator.validate(text);
      }
    });
  }

  Future<void> _loadHistory() async {
    final history = await _historyService.getHistory();
    if (mounted) {
      setState(() {
        _scanHistory = history;
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _decodeVin() async {
    final vin = _vinController.text.trim().toUpperCase();
    final validation = VinValidator.validate(vin);

    if (!validation.isValid) {
      setState(() => _decodeError = validation.error);
      return;
    }

    setState(() {
      _isDecoding = true;
      _decodeError = null;
      _decodeResult = null;
    });

    try {
      // Try cache first
      final cached = await _historyService.getCachedResult(vin);
      if (cached != null) {
        setState(() {
          _decodeResult = cached;
          _isDecoding = false;
        });
        await _historyService.addDecodeResult(cached);
        await _loadHistory();
        return;
      }

      // Call backend API
      final response = await _apiService.decodeVin(vin);
      final result = VinDecodeResult.fromJson(response);

      // Cache and add to history
      await _historyService.cacheResult(result);
      await _historyService.addDecodeResult(result);
      await _loadHistory();

      if (mounted) {
        setState(() {
          _decodeResult = result;
          _isDecoding = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDecoding = false;
          _decodeError = ErrorHandler.getUserFriendlyMessage(e);
        });
      }
    }
  }

  void _useSampleVin(SampleVin sample) {
    _vinController.text = sample.vin;
    _vinFocusNode.requestFocus();
  }

  void _useHistoryVin(VinScanEntry entry) {
    _vinController.text = entry.vin;
    setState(() => _showHistory = false);
  }

  Future<void> _deleteHistoryEntry(String vin) async {
    await _historyService.removeEntry(vin);
    await _loadHistory();
  }

  Future<void> _clearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all scan history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.clearHistory();
      await _loadHistory();
    }
  }

  void _clearInput() {
    _vinController.clear();
    setState(() {
      _validationResult = null;
      _decodeResult = null;
      _decodeError = null;
    });
    _vinFocusNode.requestFocus();
  }

  void _openCameraScanner() {
    setState(() => _showCameraScanner = true);
  }

  void _onCameraScanComplete(String vin) {
    setState(() {
      _showCameraScanner = false;
    });
    _vinController.text = vin;
    // Auto-decode after camera scan
    _decodeVin();
  }

  void _closeCameraScanner() {
    setState(() => _showCameraScanner = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'VIN Scanner',
          style: AppTypography.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.electricBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showHistory ? Icons.edit : Icons.history,
              color: Colors.white,
            ),
            tooltip: _showHistory ? 'VIN Input' : 'Scan History',
            onPressed: () {
              setState(() => _showHistory = !_showHistory);
            },
          ),
        ],
      ),
      body: _showCameraScanner
          ? VinCameraScanner(
              onVinDetected: _onCameraScanComplete,
              onClose: _closeCameraScanner,
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: _showHistory ? _buildHistoryView() : _buildInputView(),
            ),
    );
  }

  // ===================== INPUT VIEW =====================

  Widget _buildInputView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildInputHeader(),
          const SizedBox(height: AppSpacing.lg),

          // Camera scan button
          _buildCameraScanButton(),
          const SizedBox(height: AppSpacing.md),

          // "or" divider
          _buildOrDivider(),
          const SizedBox(height: AppSpacing.md),

          // VIN Input Field
          _buildVinInput(),
          const SizedBox(height: AppSpacing.sm),

          // Real-time validation feedback
          _buildValidationFeedback(),
          const SizedBox(height: AppSpacing.lg),

          // Character counter
          _buildCharacterCounter(),
          const SizedBox(height: AppSpacing.lg),

          // Decode button
          _buildDecodeButton(),
          const SizedBox(height: AppSpacing.lg),

          // Decode error
          if (_decodeError != null) ...[
            _buildDecodeError(),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Decode result
          if (_decodeResult != null) ...[
            _buildDecodeResultCard(),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Loading state
          if (_isDecoding) ...[
            _buildDecodingIndicator(),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Sample VINs
          _buildSampleVins(),
          const SizedBox(height: AppSpacing.lg),

          // Quick history
          if (_scanHistory.isNotEmpty) ...[_buildQuickHistory()],
        ],
      ),
    );
  }

  Widget _buildInputHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: AppColors.electricBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Decode a VIN', style: AppTypography.h2),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Enter a 17-character Vehicle Identification Number',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'OR ENTER MANUALLY',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Widget _buildCameraScanButton() {
    return Material(
      color: AppColors.carbonBlack,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      elevation: 2,
      shadowColor: AppColors.carbonBlack.withValues(alpha: 0.2),
      child: InkWell(
        onTap: _openCameraScanner,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.electricBlue,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan VIN Barcode',
                      style: AppTypography.h5.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Use camera to scan the barcode on the vehicle',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVinInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VIN Number',
          style: AppTypography.inputLabel.copyWith(
            color: _vinFocusNode.hasFocus
                ? AppColors.electricBlue
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.labelInputSpacing),
        TextFormField(
          controller: _vinController,
          focusNode: _vinFocusNode,
          textCapitalization: TextCapitalization.characters,
          style: AppTypography.vinDisplay.copyWith(
            fontSize: 18,
            letterSpacing: 2.0,
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(17),
            FilteringTextInputFormatter.allow(
              RegExp(r'[A-HJ-NPR-Za-hj-npr-z0-9]'),
            ),
            UpperCaseTextFormatter(),
          ],
          decoration: InputDecoration(
            hintText: 'WBADT63452CK12345',
            hintStyle: AppTypography.vinDisplay.copyWith(
              fontSize: 18,
              letterSpacing: 2.0,
              color: AppColors.textDisabled,
            ),
            filled: true,
            fillColor: AppColors.backgroundSecondary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.electricBlue,
                width: 2.0,
              ),
            ),
            prefixIcon: const Icon(
              Icons.directions_car,
              color: AppColors.electricBlue,
            ),
            suffixIcon: _vinController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: _clearInput,
                  )
                : null,
          ),
          onFieldSubmitted: (_) => _decodeVin(),
        ),
      ],
    );
  }

  Widget _buildValidationFeedback() {
    if (_validationResult == null) return const SizedBox.shrink();

    final result = _validationResult!;
    final vin = _vinController.text.trim().toUpperCase();

    // Manufacturer detection (real-time as user types)
    if (vin.length >= 3) {
      final partialInfo = result.partialInfo;
      if (partialInfo?.manufacturer != null) {
        return _buildInfoChip(
          icon: Icons.verified,
          label: partialInfo!.manufacturer!,
          color: AppColors.success,
        );
      } else if (vin.length >= 3) {
        return _buildInfoChip(
          icon: Icons.info_outline,
          label: 'Non-German manufacturer',
          color: AppColors.textSecondary,
        );
      }
    }

    // Validation error
    if (!result.isValid && result.errorType != VinErrorType.tooShort) {
      return _buildInfoChip(
        icon: Icons.error_outline,
        label: result.error ?? 'Invalid VIN',
        color: AppColors.error,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(label),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: AppSpacing.xxs),
            Flexible(
              child: Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterCounter() {
    final length = _vinController.text.trim().length;
    final isComplete = length == VinValidator.vinLength;

    return Row(
      children: [
        // Progress bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: length / VinValidator.vinLength,
              backgroundColor: AppColors.zinc200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? AppColors.success : AppColors.electricBlue,
              ),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$length/${VinValidator.vinLength}',
          style: AppTypography.codeMedium.copyWith(
            color: isComplete ? AppColors.success : AppColors.textSecondary,
            fontWeight: isComplete ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildDecodeButton() {
    final vin = _vinController.text.trim();
    final isValid =
        vin.length == VinValidator.vinLength &&
        (_validationResult?.isValid ?? false);

    return CustomButton.primary(
      text: _isDecoding ? 'Decoding...' : 'Decode VIN',
      onPressed: isValid && !_isDecoding ? _decodeVin : null,
      isFullWidth: true,
      isLoading: _isDecoding,
      prefixIcon: Icons.search,
      size: CustomButtonSize.large,
    );
  }

  Widget _buildDecodeError() {
    return ErrorMessage(
      message: _decodeError!,
      type: ErrorMessageType.vin,
      onRetry: _decodeVin,
    );
  }

  Widget _buildDecodingIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricBlue),
            strokeWidth: 3,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Decoding VIN...',
            style: AppTypography.h5.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Fetching vehicle information from database',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== DECODE RESULT =====================

  Widget _buildDecodeResultCard() {
    final result = _decodeResult!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.carbonBlack.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with brand accent
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.electricBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusLarge - 1),
                topRight: Radius.circular(AppSpacing.radiusLarge - 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.displayName,
                        style: AppTypography.h4.copyWith(color: Colors.white),
                      ),
                      Text(
                        result.vin,
                        style: AppTypography.codeMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Vehicle details
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                if (result.manufacturer != null)
                  _buildDetailRow('Manufacturer', result.manufacturer!),
                if (result.model != null)
                  _buildDetailRow('Model', result.model!),
                if (result.year != null) _buildDetailRow('Year', result.year!),
                if (result.series != null)
                  _buildDetailRow('Series', result.series!),
                if (result.trim != null) _buildDetailRow('Trim', result.trim!),
                if (result.bodyStyle != null)
                  _buildDetailRow('Body Style', result.bodyStyle!),
                if (result.engineType != null)
                  _buildDetailRow('Engine', result.engineType!),
                if (result.displacement != null)
                  _buildDetailRow('Displacement', '${result.displacement}L'),
                if (result.power != null)
                  _buildDetailRow('Power', '${result.power} HP'),
                if (result.transmission != null)
                  _buildDetailRow('Transmission', result.transmission!),
                if (result.driveType != null)
                  _buildDetailRow('Drive Type', result.driveType!),
                if (result.fuelType != null)
                  _buildDetailRow('Fuel Type', result.fuelType!),
                if (result.countryOfOrigin != null)
                  _buildDetailRow('Origin', result.countryOfOrigin!),
                if (result.plantCity != null)
                  _buildDetailRow('Plant', result.plantCity!),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton.outline(
                    text: 'New Scan',
                    onPressed: _clearInput,
                    prefixIcon: Icons.refresh,
                    size: CustomButtonSize.small,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: CustomButton.primary(
                    text: 'Copy VIN',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: result.vin));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('VIN copied to clipboard'),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMedium,
                            ),
                          ),
                        ),
                      );
                    },
                    prefixIcon: Icons.copy,
                    size: CustomButtonSize.small,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== SAMPLE VINS =====================

  Widget _buildSampleVins() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.science, color: AppColors.textSecondary, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Sample VINs for Testing',
              style: AppTypography.h6.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...VinValidator.sampleVins.map((sample) => _buildSampleVinTile(sample)),
      ],
    );
  }

  Widget _buildSampleVinTile(SampleVin sample) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: InkWell(
        onTap: () => _useSampleVin(sample),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: AppColors.electricBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sample.description,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      sample.vin,
                      style: AppTypography.codeSmall.copyWith(
                        color: AppColors.electricBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== QUICK HISTORY =====================

  Widget _buildQuickHistory() {
    final recentScans = _scanHistory.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: AppColors.textSecondary, size: 18),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Recent Scans',
                  style: AppTypography.h6.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (_scanHistory.length > 3)
              TextButton(
                onPressed: () => setState(() => _showHistory = true),
                child: Text(
                  'View All',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.electricBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...recentScans.map((entry) => _buildHistoryTile(entry)),
      ],
    );
  }

  // ===================== HISTORY VIEW =====================

  Widget _buildHistoryView() {
    if (_isLoadingHistory) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricBlue),
        ),
      );
    }

    if (_scanHistory.isEmpty) {
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
                  color: AppColors.electricBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                ),
                child: const Icon(
                  Icons.history,
                  color: AppColors.electricBlue,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No Scan History',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Your decoded VINs will appear here for quick access',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              CustomButton.primary(
                text: 'Scan a VIN',
                onPressed: () => setState(() => _showHistory = false),
                prefixIcon: Icons.qr_code_scanner,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // History header with clear all
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_scanHistory.length} scans',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              TextButton.icon(
                onPressed: _clearAllHistory,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ],
          ),
        ),

        // History list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: _scanHistory.length,
            itemBuilder: (context, index) {
              return _buildHistoryTile(_scanHistory[index], showDelete: true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTile(VinScanEntry entry, {bool showDelete = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: InkWell(
        onTap: () => _useHistoryVin(entry),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: Icon(
                  _getManufacturerIcon(entry.manufacturer),
                  color: AppColors.electricBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.displayName,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          entry.vin,
                          style: AppTypography.codeSmall.copyWith(
                            color: AppColors.electricBlue,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '· ${entry.timeAgo}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (showDelete)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => _deleteHistoryEntry(entry.vin),
                )
              else
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getManufacturerIcon(String? manufacturer) {
    // All German car brands use the same car icon in material icons
    return Icons.directions_car;
  }
}
