import 'package:flutter/material.dart';
import '../../models/tecdoc_models.dart';
import '../../services/tecdoc_service.dart';
import '../../styles/styles.dart';
import 'article_detail_screen.dart';

/// Parts Lookup screen — decode a VIN or search parts by article number.
class PartsLookupScreen extends StatefulWidget {
  const PartsLookupScreen({super.key});

  @override
  State<PartsLookupScreen> createState() => _PartsLookupScreenState();
}

class _PartsLookupScreenState extends State<PartsLookupScreen> {
  final TecDocService _tecdoc = TecDocService();

  // VIN decode
  final TextEditingController _vinController = TextEditingController();
  bool _vinLoading = false;
  String? _vinError;
  TecDocVehicle? _vehicle;

  // Part search
  final TextEditingController _partController = TextEditingController();
  bool _searchLoading = false;
  String? _searchError;
  List<TecDocArticle>? _searchResults;

  @override
  void dispose() {
    _vinController.dispose();
    _partController.dispose();
    super.dispose();
  }

  Future<void> _decodeVin() async {
    final vin = _vinController.text.trim().toUpperCase();
    if (vin.isEmpty) {
      setState(() => _vinError = 'Please enter a VIN');
      return;
    }
    if (vin.length != 17) {
      setState(() => _vinError = 'VIN must be exactly 17 characters');
      return;
    }

    setState(() {
      _vinLoading = true;
      _vinError = null;
      _vehicle = null;
    });

    try {
      final vehicle = await _tecdoc.decodeVin(vin);
      setState(() {
        _vehicle = vehicle;
        _vinLoading = false;
      });
    } on TecDocException catch (e) {
      setState(() {
        _vinError = e.message;
        _vinLoading = false;
      });
    } catch (e) {
      setState(() {
        _vinError = 'Failed to decode VIN. Please try again.';
        _vinLoading = false;
      });
    }
  }

  Future<void> _searchParts() async {
    final query = _partController.text.trim();
    if (query.isEmpty) {
      setState(() => _searchError = 'Please enter a part number');
      return;
    }

    setState(() {
      _searchLoading = true;
      _searchError = null;
      _searchResults = null;
    });

    try {
      final results = await _tecdoc.searchByArticleNumber(query);
      setState(() {
        _searchResults = results;
        _searchLoading = false;
      });
    } on TecDocException catch (e) {
      setState(() {
        _searchError = e.message;
        _searchLoading = false;
      });
    } catch (e) {
      setState(() {
        _searchError = 'Search failed. Please try again.';
        _searchLoading = false;
      });
    }
  }

  void _openArticle(TecDocArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
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
            // Part number search card
            _buildPartSearchInput(),
            const SizedBox(height: AppSpacing.md),

            // Search results
            if (_searchResults != null) _buildSearchResults(),

            // VIN decode card
            _buildVinInput(),
            const SizedBox(height: AppSpacing.md),

            // Vehicle result
            if (_vehicle != null) _buildVehicleCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPartSearchInput() {
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
              'Search by Part Number',
              style: AppTypography.h5.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Enter an article or OEM part number to find matching parts.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _partController,
              textCapitalization: TextCapitalization.characters,
              style: AppTypography.codeLarge,
              decoration: InputDecoration(
                hintText: 'e.g. C2029 or 11427566327',
                hintStyle: AppTypography.codeLarge.copyWith(
                  color: AppColors.textDisabled,
                ),
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
                errorText: _searchError,
                suffixIcon: _partController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _partController.clear();
                          setState(() {
                            _searchResults = null;
                            _searchError = null;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() => _searchError = null),
              onSubmitted: (_) => _searchParts(),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _searchLoading ? null : _searchParts,
                icon: _searchLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.search, size: 20),
                label: Text(
                  'Search Parts',
                  style: AppTypography.buttonLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = _searchResults!;

    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Material(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          elevation: 0.5,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Column(
              children: [
                Icon(Icons.search_off, size: 48, color: AppColors.textDisabled),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No parts found for this number.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              '${results.length} result${results.length == 1 ? '' : 's'}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...results.map((article) => _buildArticleCard(article)),
        ],
      ),
    );
  }

  Widget _buildArticleCard(TecDocArticle article) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        elevation: 0.5,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          onTap: () => _openArticle(article),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              children: [
                // Thumbnail
                if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    child: Image.network(
                      article.imageUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderIcon(),
                    ),
                  )
                else
                  _placeholderIcon(),
                const SizedBox(width: AppSpacing.sm),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article.articleName != null)
                        Text(
                          article.articleName!,
                          style: AppTypography.h5.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 2),
                      Text(
                        article.articleNumber,
                        style: AppTypography.codeMedium.copyWith(
                          color: AppColors.electricBlue,
                        ),
                      ),
                      if (article.supplierName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          article.supplierName!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textDisabled,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.electricBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      child: const Icon(
        Icons.build_outlined,
        color: AppColors.electricBlue,
        size: 24,
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
              'Decode Vehicle VIN',
              style: AppTypography.h5.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Identify your vehicle from its 17-character VIN.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _vinController,
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
                errorText: _vinError,
              ),
              onChanged: (_) => setState(() => _vinError = null),
              onSubmitted: (_) => _decodeVin(),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _vinLoading ? null : _decodeVin,
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
                child: _vinLoading
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
                  child: Text(
                    v.displayName,
                    style: AppTypography.h5.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _vehicleDetail('Engine', v.engineType),
            _vehicleDetail('Fuel', v.fuelType),
            _vehicleDetail('Body', v.bodyType),
            _vehicleDetail(
              'Power',
              v.powerKw != null
                  ? '${v.powerKw} kW${v.powerHp != null ? ' / ${v.powerHp} HP' : ''}'
                  : v.powerHp != null
                  ? '${v.powerHp} HP'
                  : null,
            ),
            _vehicleDetail(
              'Displacement',
              v.engineDisplacement != null
                  ? '${v.engineDisplacement} cc'
                  : null,
            ),
            _vehicleDetail('Manufacturer ID', v.manufacturerId?.toString()),
            _vehicleDetail('Vehicle ID', v.vehicleId?.toString()),
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
