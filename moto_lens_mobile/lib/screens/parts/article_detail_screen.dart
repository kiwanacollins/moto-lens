import 'package:flutter/material.dart';
import '../../models/tecdoc_models.dart';
import '../../services/tecdoc_service.dart';
import '../../styles/styles.dart';

/// Displays full details and images for a single TecDoc article (part).
class ArticleDetailScreen extends StatefulWidget {
  final TecDocArticle article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final TecDocService _tecdoc = TecDocService();

  bool _isLoading = true;
  String? _error;
  List<TecDocMedia> _media = [];
  String? _categoryName;

  @override
  void initState() {
    super.initState();
    _loadExtra();
  }

  Future<void> _loadExtra() async {
    if (widget.article.articleId == 0) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final details = await _tecdoc.getArticleDetails(widget.article.articleId);
      setState(() {
        _media = details.images;
        _categoryName = details.articleName;
        _isLoading = false;
      });
    } on TecDocException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not load additional details';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          a.articleName ?? 'Part Details',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image from search results
            if (a.imageUrl != null && a.imageUrl!.isNotEmpty)
              _buildHeroImage(a.imageUrl!),

            // Media gallery from article API
            if (!_isLoading && _media.isNotEmpty) _buildMediaGallery(),

            // Loading indicator for extra data
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.electricBlue,
                    ),
                  ),
                ),
              ),

            // Error (non-blocking)
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  _error!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

            // Part info card
            _buildInfoCard(a),
            const SizedBox(height: AppSpacing.sm),

            // Category
            if (_categoryName != null && _categoryName!.isNotEmpty)
              _buildCategoryCard(_categoryName!),
            if (_categoryName != null) const SizedBox(height: AppSpacing.sm),

            // Supplier
            if (a.supplierName != null) _buildSupplierCard(a.supplierName!),

            // OEM numbers
            if (a.oemNumbers.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildOemNumbers(a.oemNumbers),
            ],

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage(String url) {
    return Container(
      height: 220,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        child: Container(
          color: AppColors.zinc50,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 48,
                color: AppColors.textDisabled,
              ),
            ),
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                      : null,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.electricBlue,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMediaGallery() {
    final validMedia = _media.where((m) => m.url.isNotEmpty).toList();
    if (validMedia.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 140,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: validMedia.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final img = validMedia[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            child: Container(
              width: 140,
              color: AppColors.zinc50,
              child: Image.network(
                img.url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 32,
                    color: AppColors.textDisabled,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(TecDocArticle a) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      elevation: 0.5,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (a.articleName != null)
              Text(
                a.articleName!,
                style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
              ),
            if (a.articleNumber.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxs),
              Row(
                children: [
                  Text(
                    'Article #  ',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(a.articleNumber, style: AppTypography.partNumber),
                ],
              ),
            ],
            if (a.articleId != 0) ...[
              const SizedBox(height: AppSpacing.xxs),
              Row(
                children: [
                  Text(
                    'ID  ',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    a.articleId.toString(),
                    style: AppTypography.codeMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      elevation: 0.5,
      child: Container(
        width: double.infinity,
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
              child: const Icon(
                Icons.category_outlined,
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
                    'Category',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    category,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierCard(String supplier) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      elevation: 0.5,
      child: Container(
        width: double.infinity,
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
                color: AppColors.zinc100,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                color: AppColors.gunmetalGray,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Supplier',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    supplier,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOemNumbers(List<String> oems) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      elevation: 0.5,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OEM Numbers',
              style: AppTypography.h6.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xxs,
              children: oems.map((oem) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    border: Border.all(
                      color: AppColors.electricBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    oem,
                    style: AppTypography.codeMedium.copyWith(
                      color: AppColors.electricBlue,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
