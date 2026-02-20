import 'package:flutter/material.dart';
import '../../models/tecdoc_models.dart';
import '../../services/tecdoc_service.dart';
import '../../styles/styles.dart';

/// Displays full details and images for a single TecDoc article (part).
class ArticleDetailScreen extends StatefulWidget {
  final int articleId;
  final String vehicleName;

  const ArticleDetailScreen({
    super.key,
    required this.articleId,
    required this.vehicleName,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final TecDocService _tecdoc = TecDocService();

  bool _isLoading = true;
  String? _error;
  TecDocArticle? _article;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final article = await _tecdoc.getArticleDetails(widget.articleId);
      setState(() {
        _article = article;
        _isLoading = false;
      });
    } on TecDocException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load part details';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _article?.articleName ?? 'Part Details',
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
      body: _buildBody(),
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
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: _loadArticle,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final a = _article!;

    return RefreshIndicator(
      onRefresh: _loadArticle,
      color: AppColors.electricBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images
            if (a.images.isNotEmpty) _buildImageGallery(a.images),

            // Part name & article number
            _buildInfoCard(a),

            const SizedBox(height: AppSpacing.sm),

            // OEM numbers
            if (a.oemNumbers.isNotEmpty) _buildOemNumbers(a.oemNumbers),

            const SizedBox(height: AppSpacing.sm),

            // Description / raw data
            if (a.description != null && a.description!.isNotEmpty)
              _buildDescriptionCard(a.description!),

            const SizedBox(height: AppSpacing.sm),

            // Supplier
            if (a.supplierName != null) _buildSupplierCard(a.supplierName!),

            const SizedBox(height: AppSpacing.lg),

            // Vehicle context
            _buildVehicleContext(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(List<TecDocMedia> images) {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        child: PageView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) {
            final img = images[index];
            if (img.url.isEmpty) {
              return Container(
                color: AppColors.zinc100,
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: AppColors.textDisabled,
                  ),
                ),
              );
            }
            return Container(
              color: AppColors.zinc50,
              child: Image.network(
                img.url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.zinc100,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: AppColors.textDisabled,
                    ),
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
            );
          },
        ),
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

  Widget _buildDescriptionCard(String description) {
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
              'Description',
              style: AppTypography.h6.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
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

  Widget _buildVehicleContext() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.zinc50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      child: Row(
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              widget.vehicleName,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
