import 'package:flutter/material.dart';
import '../../models/tecdoc_models.dart';
import '../../services/tecdoc_service.dart';
import '../../styles/styles.dart';
import 'article_detail_screen.dart';

/// Displays part categories for a decoded vehicle.
///
/// User picks a category to see its article IDs, then can
/// drill into individual article details.
class PartsCategoryScreen extends StatefulWidget {
  final TecDocVehicle vehicle;

  const PartsCategoryScreen({super.key, required this.vehicle});

  @override
  State<PartsCategoryScreen> createState() => _PartsCategoryScreenState();
}

class _PartsCategoryScreenState extends State<PartsCategoryScreen> {
  final TecDocService _tecdoc = TecDocService();

  bool _isLoading = true;
  String? _error;
  List<TecDocCategory> _categories = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    if (widget.vehicle.vehicleId == null || widget.vehicle.manufacturerId == null) {
      setState(() {
        _error = 'Missing vehicle or manufacturer ID';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final cats = await _tecdoc.getCategories(
        vehicleId: widget.vehicle.vehicleId!,
        manufacturerId: widget.vehicle.manufacturerId!,
        typeId: widget.vehicle.typeId,
      );
      setState(() {
        _categories = cats;
        _isLoading = false;
      });
    } on TecDocException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load categories';
        _isLoading = false;
      });
    }
  }

  List<TecDocCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    final q = _searchQuery.toLowerCase();
    return _categories
        .where((c) => c.categoryName.toLowerCase().contains(q))
        .toList();
  }

  void _openArticle(int articleId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(
          articleId: articleId,
          vehicleName: widget.vehicle.displayName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Part Categories',
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
      body: Column(
        children: [
          // Vehicle summary bar
          _buildVehicleBanner(),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Filter categories...',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textDisabled),
                prefixIcon: const Icon(Icons.search, color: AppColors.gunmetalGray, size: 20),
                filled: true,
                fillColor: AppColors.surfaceElevated,
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
                  borderSide: BorderSide(color: AppColors.electricBlue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),

          // Content
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildVehicleBanner() {
    final v = widget.vehicle;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.electricBlue.withValues(alpha: 0.08),
      child: Row(
        children: [
          Icon(Icons.directions_car_outlined, color: AppColors.electricBlue, size: 20),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              v.displayName,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricBlue),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error!,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: _loadCategories,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final cats = _filteredCategories;
    if (cats.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty
              ? 'No categories found for this vehicle.'
              : 'No categories match your search.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      color: AppColors.electricBlue,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
        itemBuilder: (context, index) => _buildCategoryTile(cats[index]),
      ),
    );
  }

  Widget _buildCategoryTile(TecDocCategory cat) {
    final hasArticles = cat.articleIds.isNotEmpty;
    final hasChildren = cat.children.isNotEmpty;
    final articlesCount = cat.articleIds.length;

    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      elevation: 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        onTap: hasArticles
            ? () => _showArticleList(cat)
            : hasChildren
                ? () => _drillDown(cat)
                : null,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: Icon(
                  _categoryIcon(cat.categoryName),
                  color: AppColors.electricBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.categoryName,
                      style: AppTypography.h5.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (hasArticles)
                      Text(
                        '$articlesCount part${articlesCount == 1 ? '' : 's'}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    if (hasChildren && !hasArticles)
                      Text(
                        '${cat.children.length} subcategories',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
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
    );
  }

  void _showArticleList(TecDocCategory cat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXLarge)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.zinc300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                cat.categoryName,
                style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: cat.articleIds.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final id = cat.articleIds[index];
                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.electricBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      'Article #$id',
                      style: AppTypography.codeMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textDisabled),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _openArticle(id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _drillDown(TecDocCategory cat) {
    // Push a new category screen with the children as top-level
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SubCategoryScreen(
          parentName: cat.categoryName,
          categories: cat.children,
          vehicleName: widget.vehicle.displayName,
          onArticleTap: _openArticle,
        ),
      ),
    );
  }

  IconData _categoryIcon(String? name) {
    if (name == null) return Icons.category_outlined;
    final n = name.toLowerCase();
    if (n.contains('engine')) return Icons.settings_outlined;
    if (n.contains('brake')) return Icons.stop_circle_outlined;
    if (n.contains('suspension')) return Icons.airline_seat_recline_extra;
    if (n.contains('electr')) return Icons.electrical_services_outlined;
    if (n.contains('body')) return Icons.directions_car_outlined;
    if (n.contains('exhaust')) return Icons.air_outlined;
    if (n.contains('cool')) return Icons.thermostat_outlined;
    if (n.contains('fuel')) return Icons.local_gas_station_outlined;
    if (n.contains('steer')) return Icons.sports_esports_outlined;
    if (n.contains('transm') || n.contains('gear')) return Icons.settings_input_composite_outlined;
    if (n.contains('filter')) return Icons.filter_alt_outlined;
    if (n.contains('light') || n.contains('lamp')) return Icons.lightbulb_outline;
    if (n.contains('wiper')) return Icons.water_drop_outlined;
    return Icons.category_outlined;
  }
}

/// Simple sub-category drill-down screen.
class _SubCategoryScreen extends StatelessWidget {
  final String parentName;
  final List<TecDocCategory> categories;
  final String vehicleName;
  final void Function(int articleId) onArticleTap;

  const _SubCategoryScreen({
    required this.parentName,
    required this.categories,
    required this.vehicleName,
    required this.onArticleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          parentName,
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
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return ListTile(
            title: Text(
              cat.categoryName,
              style: AppTypography.h5.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: cat.articleIds.isNotEmpty
                ? Text('${cat.articleIds.length} parts')
                : cat.children.isNotEmpty
                    ? Text('${cat.children.length} subcategories')
                    : null,
            trailing: const Icon(Icons.chevron_right, color: AppColors.textDisabled),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            tileColor: AppColors.surfaceElevated,
            onTap: () {
              if (cat.articleIds.isNotEmpty) {
                // Show article list
                for (final id in cat.articleIds) {
                  onArticleTap(id);
                  break; // Open first, user can go back and pick more
                }
              } else if (cat.children.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _SubCategoryScreen(
                      parentName: cat.categoryName,
                      categories: cat.children,
                      vehicleName: vehicleName,
                      onArticleTap: onArticleTap,
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
