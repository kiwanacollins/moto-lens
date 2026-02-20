import 'package:flutter/material.dart';
import '../../models/tecdoc_models.dart';
import '../../services/tecdoc_service.dart';
import '../../styles/styles.dart';
import 'parts_category_screen.dart';

/// Parts Lookup screen — enter a VIN and browse compatible parts via TecDoc.
class PartsLookupScreen extends StatefulWidget {
  const PartsLookupScreen({super.key});

  @override
  State<PartsLookupScreen> createState() => _PartsLookupScreenState();
}

class _PartsLookupScreenState extends State<PartsLookupScreen> {
  final TecDocService _tecdoc = TecDocService();
  final TextEditingController _vinController = TextEditingController();
  final FocusNode _vinFocus = FocusNode();

  bool _isLoading = false;
  String? _error;
  TecDocVehicle? _vehicle;

  @override
  void dispose() {
    _vinController.dispose();
    _vinFocus.dispose();
    super.dispose();
  }

  Future<void> _decodeVin() async {
    final vin = _vinController.text.trim().toUpperCase();
    if (vin.isEmpty) {
      setState(() => _error = 'Please enter a VIN');
      return;
    }
    if (vin.length != 17) {
      setState(() => _error = 'VIN must be exactly 17 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _vehicle = null;
    });

    try {
      final vehicle = await _tecdoc.decodeVin(vin);
      setState(() {
        _vehicle = vehicle;
        _isLoading = false;
      });
    } on TecDocException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to decode VIN. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _browseCategories() {
    final v = _vehicle;
    if (v == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PartsCategoryScreen(vehicle: v)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Parts Lookup',
          style: AppTypography.h3.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.headerBar,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // VIN input card
            _buildVinInput(),
            const SizedBox(height: AppSpacing.lg),

            // Vehicle result
            if (_vehicle != null) _buildVehicleCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildVinInput() {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      elevation: 0.5,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Vehicle VIN',
              style: AppTypography.h5.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Decode the VIN to find compatible parts from the TecDoc catalog.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // VIN text field
            TextField(
              controller: _vinController,
              focusNode: _vinFocus,
              textCapitalization: TextCapitalization.characters,
              maxLength: 17,
              style: AppTypography.codeLarge,
              decoration: InputDecoration(
                hintText: 'e.g. WBADT63452CZ12345',
                hintStyle: AppTypography.codeLarge.copyWith(
                  color: AppColors.textDisabled,
                ),
                counterText: '${_vinController.text.length}/17',
                counterStyle: AppTypography.bodySmall,
                filled: true,
                fillColor: AppColors.zinc50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  borderSide: BorderSide(
                    color: AppColors.electricBlue,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  borderSide: BorderSide(color: AppColors.error),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                errorText: _error,
              ),
              onChanged: (_) => setState(() => _error = null),
              onSubmitted: (_) => _decodeVin(),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Decode button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _decodeVin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusMedium,
                    ),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Decode VIN',
                        style: AppTypography.buttonLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard() {
    final v = _vehicle!;
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      elevation: 0.5,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.directions_car_outlined,
                    color: AppColors.electricBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.displayName,
                        style: AppTypography.h5.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Vehicle details
            _vehicleDetail('Engine', v.engineType),
            _vehicleDetail('Fuel', v.fuelType),
            _vehicleDetail('Body', v.bodyType),
            _vehicleDetail('Manufacturer ID', v.manufacturerId?.toString()),
            _vehicleDetail('Vehicle ID', v.vehicleId?.toString()),

            const SizedBox(height: AppSpacing.md),

            // Browse parts button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: (v.vehicleId != null && v.manufacturerId != null)
                    ? _browseCategories
                    : null,
                icon: const Icon(Icons.build_outlined, size: 20),
                label: Text(
                  'Browse Compatible Parts',
                  style: AppTypography.buttonLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.zinc300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusMedium,
                    ),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            if (v.vehicleId == null || v.manufacturerId == null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Vehicle or manufacturer ID missing — cannot browse parts.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.warning,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _vehicleDetail(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Row(
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
