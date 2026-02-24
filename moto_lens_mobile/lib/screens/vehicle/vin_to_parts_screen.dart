import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/vin_to_parts_provider.dart';
import '../../styles/styles.dart';

/// VIN-to-Parts Screen
///
/// Professional 3-step flow:
///   1. Enter VIN → decode & auto-resolve vehicle
///   2. (Optional) Pick a different engine variant
///   3. Browse categorised OEM parts list with search
class VinToPartsScreen extends StatelessWidget {
  const VinToPartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VinToPartsProvider(),
      child: Consumer<VinToPartsProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.headerBar,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.carbonBlack,
                  size: 20,
                ),
                onPressed: () {
                  if (provider.step == VinToPartsStep.partsResult ||
                      provider.step == VinToPartsStep.vehicleSelect) {
                    provider.reset();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              title: Text(
                'VIN to Parts',
                style: AppTypography.h4.copyWith(
                  color: AppColors.carbonBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              actions: [
                if (provider.step == VinToPartsStep.partsResult)
                  IconButton(
                    icon: const Icon(
                      Icons.restart_alt,
                      color: AppColors.gunmetalGray,
                    ),
                    onPressed: provider.reset,
                    tooltip: 'New lookup',
                  ),
              ],
            ),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildBody(provider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(VinToPartsProvider provider) {
    switch (provider.step) {
      case VinToPartsStep.input:
        return _VinInputView(key: const ValueKey('input'));
      case VinToPartsStep.loading:
        return _LoadingView(
          key: const ValueKey('loading'),
          message: provider.loadingMessage,
        );
      case VinToPartsStep.vehicleSelect:
        return _VehicleSelectView(key: const ValueKey('vehicleSelect'));
      case VinToPartsStep.partsResult:
        return _PartsResultView(key: const ValueKey('partsResult'));
      case VinToPartsStep.error:
        return _ErrorView(key: const ValueKey('error'));
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Step 1: VIN Input
// ─────────────────────────────────────────────────────────────

class _VinInputView extends StatefulWidget {
  const _VinInputView({super.key});

  @override
  State<_VinInputView> createState() => _VinInputViewState();
}

class _VinInputViewState extends State<_VinInputView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _isValid => _controller.text.trim().length == 17;

  void _submit() {
    if (!_isValid) return;
    context.read<VinToPartsProvider>().lookupVin(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.build_circle_outlined,
              size: 36,
              color: AppColors.electricBlue,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(
            'Find OEM Parts by VIN',
            style: AppTypography.h3.copyWith(color: AppColors.carbonBlack),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Enter a 17-character VIN to look up compatible OEM part numbers from the TecDoc catalog.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gunmetalGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),

          // VIN text field
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.characters,
            maxLength: 17,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[A-HJ-NPR-Za-hj-npr-z0-9]'),
              ),
              UpperCaseTextFormatter(),
            ],
            style: const TextStyle(
              fontFamily: AppTypography.monoFontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: AppColors.carbonBlack,
            ),
            decoration: InputDecoration(
              labelText: 'Vehicle Identification Number',
              hintText: 'WDBFA68F42F202731',
              hintStyle: TextStyle(
                fontFamily: AppTypography.monoFontFamily,
                fontSize: 18,
                color: AppColors.zinc400,
                letterSpacing: 2.0,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                borderSide: const BorderSide(color: AppColors.zinc200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                borderSide: const BorderSide(color: AppColors.zinc200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                borderSide: const BorderSide(
                  color: AppColors.electricBlue,
                  width: 2,
                ),
              ),
              prefixIcon: const Icon(
                Icons.pin_outlined,
                color: AppColors.gunmetalGray,
              ),
              counterStyle: AppTypography.bodySmall.copyWith(
                color: AppColors.gunmetalGray,
              ),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Lookup button
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isValid ? _submit : null,
              icon: const Icon(Icons.search, size: 20),
              label: const Text('Look Up Parts'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.zinc200,
                disabledForegroundColor: AppColors.zinc400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                textStyle: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Forces upper-case input
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

// ─────────────────────────────────────────────────────────────
// Loading state
// ─────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  final String message;
  const _LoadingView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.electricBlue,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.gunmetalGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Vehicle selection list
// ─────────────────────────────────────────────────────────────

class _VehicleSelectView extends StatelessWidget {
  const _VehicleSelectView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VinToPartsProvider>();
    final vehicles = provider.vehicles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Engine Variant',
                style: AppTypography.h4.copyWith(color: AppColors.carbonBlack),
              ),
              const SizedBox(height: 4),
              Text(
                '${provider.manufacturer} ${provider.modelName} · ${vehicles.length} variants',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gunmetalGray,
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: vehicles.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.zinc200),
            itemBuilder: (context, index) {
              final v = vehicles[index];
              final isSelected =
                  provider.selectedVehicle?.vehicleId == v.vehicleId;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xs,
                  horizontal: AppSpacing.sm,
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.electricBlue.withValues(alpha: 0.15)
                        : AppColors.zinc100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.directions_car_outlined,
                    color: isSelected
                        ? AppColors.electricBlue
                        : AppColors.gunmetalGray,
                    size: 20,
                  ),
                ),
                title: Text(
                  v.typeEngineName,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: AppColors.carbonBlack,
                  ),
                ),
                subtitle: Text(
                  'ID: ${v.vehicleId}',
                  style: AppTypography.bodySmall.copyWith(
                    fontFamily: AppTypography.monoFontFamily,
                    color: AppColors.zinc500,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColors.electricBlue,
                        size: 22,
                      )
                    : const Icon(
                        Icons.chevron_right,
                        color: AppColors.zinc400,
                        size: 22,
                      ),
                onTap: () => provider.selectVehicle(v),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Parts result
// ─────────────────────────────────────────────────────────────

class _PartsResultView extends StatefulWidget {
  const _PartsResultView({super.key});

  @override
  State<_PartsResultView> createState() => _PartsResultViewState();
}

class _PartsResultViewState extends State<_PartsResultView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VinToPartsProvider>();
    final categories = provider.filteredCategories;

    return Column(
      children: [
        // Vehicle info header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.zinc200)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      provider.manufacturer,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.electricBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Change variant button
                  if (provider.vehicles.length > 1)
                    TextButton.icon(
                      onPressed: provider.showVehicleSelection,
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text('Change'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.electricBlue,
                        textStyle: AppTypography.bodySmall,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                provider.selectedVehicle?.typeEngineName ?? provider.modelName,
                style: AppTypography.h5.copyWith(
                  color: AppColors.carbonBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${provider.totalParts} parts · ${categories.length} categories',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.gunmetalGray,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // VIN badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.zinc100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'VIN: ${provider.vin}',
                  style: TextStyle(
                    fontFamily: AppTypography.monoFontFamily,
                    fontSize: 12,
                    color: AppColors.gunmetalGray,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: provider.setPartsSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search parts or OEM numbers...',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.zinc400,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.gunmetalGray,
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.zinc400,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        provider.setPartsSearchQuery('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                borderSide: const BorderSide(color: AppColors.zinc200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                borderSide: const BorderSide(color: AppColors.zinc200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                borderSide: const BorderSide(
                  color: AppColors.electricBlue,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),

        // Parts list
        Expanded(
          child: categories.isEmpty
              ? Center(
                  child: Text(
                    'No matching parts found',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.zinc400,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return _PartCategoryCard(category: cat);
                  },
                ),
        ),
      ],
    );
  }
}

/// Expandable card for a single part category
class _PartCategoryCard extends StatefulWidget {
  final TecDocPartCategory category;
  const _PartCategoryCard({required this.category});

  @override
  State<_PartCategoryCard> createState() => _PartCategoryCardState();
}

class _PartCategoryCardState extends State<_PartCategoryCard> {
  bool _expanded = false;

  IconData _iconForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('oil')) return Icons.opacity;
    if (lower.contains('air')) return Icons.air;
    if (lower.contains('fuel')) return Icons.local_gas_station;
    if (lower.contains('brake')) return Icons.do_not_disturb;
    if (lower.contains('filter')) return Icons.filter_alt_outlined;
    if (lower.contains('transmission')) return Icons.settings;
    if (lower.contains('engine')) return Icons.engineering;
    if (lower.contains('steering')) return Icons.swap_calls;
    if (lower.contains('hydraulic')) return Icons.water_drop;
    if (lower.contains('gasket') || lower.contains('seal'))
      return Icons.radio_button_unchecked;
    if (lower.contains('soot') || lower.contains('particulate'))
      return Icons.eco;
    if (lower.contains('hose') || lower.contains('intake'))
      return Icons.linear_scale;
    if (lower.contains('sump')) return Icons.inventory_2_outlined;
    if (lower.contains('rubber') ||
        lower.contains('buffer') ||
        lower.contains('holder'))
      return Icons.push_pin_outlined;
    return Icons.build_outlined;
  }

  @override
  void initState() {
    super.initState();
    // Trigger lazy image load on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VinToPartsProvider>().loadCategoryImage(
        widget.category.productName,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final provider = context.watch<VinToPartsProvider>();
    final imageUrl = provider.getCategoryImage(cat.productName);
    final isLoading = provider.isCategoryImageLoading(cat.productName);
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        elevation: 0,
        child: InkWell(
          onTap: () {
            setState(() => _expanded = !_expanded);
            if (!_expanded) return;
            // Lazy-load description on first expand
            context.read<VinToPartsProvider>().loadCategoryDescription(
              widget.category.productName,
            );
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              border: Border.all(color: AppColors.zinc200),
            ),
            child: Column(
              children: [
                // Header row
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      // Thumbnail or icon
                      _buildThumbnail(
                        hasImage,
                        isLoading,
                        imageUrl,
                        cat.productName,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.productName,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.carbonBlack,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${cat.count} OEM number${cat.count == 1 ? '' : 's'}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.gunmetalGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.zinc400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Expanded content: image + description + OEM numbers
                if (_expanded)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.zinc200)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Part image (larger) when expanded
                        if (hasImage)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.sm,
                              bottom: AppSpacing.md,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMedium,
                              ),
                              child: Image.network(
                                imageUrl,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                          ),

                        // AI-generated part description
                        _buildDescription(provider, cat.productName),

                        // OEM numbers
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: cat.oemNumbers.map((oem) {
                              return GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: oem));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Copied $oem'),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.zinc50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.zinc200,
                                    ),
                                  ),
                                  child: Text(
                                    oem,
                                    style: const TextStyle(
                                      fontFamily: AppTypography.monoFontFamily,
                                      fontSize: 12,
                                      color: AppColors.carbonBlack,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the 38x38 leading widget: image thumbnail, loading shimmer, or icon fallback
  Widget _buildThumbnail(
    bool hasImage,
    bool isLoading,
    String? imageUrl,
    String productName,
  ) {
    if (hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl!,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _iconFallback(productName),
        ),
      );
    }
    if (isLoading) {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.zinc100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricBlue),
            ),
          ),
        ),
      );
    }
    return _iconFallback(productName);
  }

  Widget _iconFallback(String productName) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.electricBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        _iconForCategory(productName),
        color: AppColors.electricBlue,
        size: 18,
      ),
    );
  }

  /// Builds the AI-generated description block (loading / text / nothing)
  Widget _buildDescription(VinToPartsProvider provider, String productName) {
    final desc = provider.getCategoryDescription(productName);
    final isLoading = provider.isCategoryDescriptionLoading(productName);

    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.only(
          top: AppSpacing.sm,
          bottom: AppSpacing.xs,
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.zinc400),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Loading description...',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.zinc400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    if (desc != null && desc.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(
          top: AppSpacing.sm,
          bottom: AppSpacing.xs,
        ),
        child: Text(
          desc,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.gunmetalGray,
            height: 1.4,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ─────────────────────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<VinToPartsProvider>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Lookup Failed',
              style: AppTypography.h4.copyWith(color: AppColors.carbonBlack),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              provider.errorMessage,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gunmetalGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: provider.reset,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricBlue,
                  foregroundColor: Colors.white,
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
    );
  }
}
