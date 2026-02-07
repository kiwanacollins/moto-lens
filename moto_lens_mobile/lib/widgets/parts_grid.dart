import 'package:flutter/material.dart';
import '../../models/vehicle_viewer.dart';
import '../../styles/styles.dart';

/// Category filter chip list + grid of tappable parts.
///
/// Mirrors the PWA's `PartsGrid` — 42 universal parts,
/// category filters, and tap to inspect.
class PartsGrid extends StatelessWidget {
  final List<UniversalPart> parts;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<UniversalPart> onPartTapped;
  final bool loading;

  const PartsGrid({
    super.key,
    required this.parts,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onPartTapped,
    this.loading = false,
  });

  List<String> get _categories {
    final cats = parts.map((p) => p.category).toSet().toList()..sort();
    return ['All', ...cats];
  }

  IconData _iconFor(String iconName) {
    switch (iconName) {
      case 'directions_car':
        return Icons.directions_car;
      case 'settings':
        return Icons.settings;
      case 'oil_barrel':
        return Icons.oil_barrel;
      case 'air':
        return Icons.air;
      case 'bolt':
        return Icons.bolt;
      case 'local_gas_station':
        return Icons.local_gas_station;
      case 'disc_full':
        return Icons.album;
      case 'circle':
        return Icons.circle_outlined;
      case 'build':
        return Icons.build;
      case 'battery_full':
        return Icons.battery_full;
      case 'electric_bolt':
        return Icons.electric_bolt;
      case 'tune':
        return Icons.tune;
      case 'flash_on':
        return Icons.flash_on;
      case 'thermostat':
        return Icons.thermostat;
      case 'memory':
        return Icons.memory;
      case 'filter_list':
        return Icons.filter_list;
      case 'speed':
        return Icons.speed;
      default:
        return Icons.settings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warning.withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(width: 32, height: 2, color: AppColors.warning),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Vehicle Systems & Components',
                  style: AppTypography.h5.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Tap any system to view details, common issues, and parts info.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Category chips
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final selected = cat == selectedCategory;
              return FilterChip(
                label: Text(
                  cat,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                selected: selected,
                onSelected: (_) => onCategoryChanged(cat),
                selectedColor: AppColors.electricBlue,
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: selected ? AppColors.electricBlue : AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Parts grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.95,
            ),
            itemCount: parts.length,
            itemBuilder: (_, i) => _PartCard(
              part: parts[i],
              icon: _iconFor(parts[i].iconName),
              onTap: () => onPartTapped(parts[i]),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Part card
// ---------------------------------------------------------------------------

class _PartCard extends StatelessWidget {
  final UniversalPart part;
  final IconData icon;
  final VoidCallback onTap;

  const _PartCard({
    required this.part,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          child: Stack(
            children: [
              // Red dot indicator
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.warning,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Part content
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMedium,
                          ),
                          border: Border.all(
                            color: AppColors.electricBlue.withValues(
                              alpha: 0.2,
                            ),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: 22,
                          color: AppColors.electricBlue,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        part.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ],
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
