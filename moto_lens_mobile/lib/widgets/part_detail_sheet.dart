import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/vehicle_viewer.dart';
import '../../styles/styles.dart';

/// Modal bottom sheet that shows AI-enriched part details
/// with SerpAPI image — mirrors the PWA's `PartDetailModal`.
class PartDetailSheet extends StatelessWidget {
  final PartDetailsResponse details;
  final bool loading;

  const PartDetailSheet({
    super.key,
    required this.details,
    this.loading = false,
  });

  /// Show as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required PartDetailsResponse details,
    bool loading = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PartDetailSheet(details: details, loading: loading),
    );
  }

  /// Show a loading state bottom sheet while fetching part details.
  static Future<void> showLoading(
    BuildContext context, {
    required String partName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (_) => PartDetailSheet(
        details: PartDetailsResponse(partId: '', partName: partName),
        loading: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Electric Blue header
              _buildHeader(context),

              // Scrollable content
              Expanded(
                child: loading
                    ? _buildLoadingContent()
                    : _buildContent(context, scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.electricBlue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              loading ? 'Loading Part Details...' : details.partName,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Material(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(8),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: List.generate(
          4,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Container(
              height: i == 0 ? 180 : 20 + (i * 10).toDouble(),
              decoration: BoxDecoration(
                color: AppColors.zinc100,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ScrollController scrollController,
  ) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Part image from SerpAPI
        if (details.image != null) ...[
          _buildImage(),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Part number chip
        if (details.partNumber != null && details.partNumber!.isNotEmpty) ...[
          _buildPartNumber(context),
          const SizedBox(height: AppSpacing.lg),
        ],

        // AI description
        if (details.description != null && details.description!.isNotEmpty) ...[
          _sectionTitle('Function & Description'),
          const SizedBox(height: AppSpacing.xs),
          _buildParsedDescription(details.description!),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Function
        if (details.function != null && details.function!.isNotEmpty) ...[
          _sectionTitle('How It Works'),
          const SizedBox(height: AppSpacing.xs),
          Text(
            details.function!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Common symptoms
        if (details.symptoms.isNotEmpty) ...[
          _sectionTitle('Common Symptoms When Faulty'),
          const SizedBox(height: AppSpacing.xs),
          ...details.symptoms.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 7),
                    decoration: const BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _cleanMarkdown(s),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-widgets
  // ---------------------------------------------------------------------------

  Widget _buildImage() {
    final img = details.image!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.zinc50,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        child: CachedNetworkImage(
          imageUrl: img.url,
          fit: BoxFit.contain,
          placeholder: (_, __) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricBlue),
              strokeWidth: 2,
            ),
          ),
          errorWidget: (_, __, ___) => const Icon(
            Icons.broken_image_outlined,
            color: AppColors.zinc400,
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildPartNumber(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.electricBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            border: Border.all(
              color: AppColors.electricBlue.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tag, size: 14, color: AppColors.electricBlue),
              const SizedBox(width: 4),
              Text(
                details.partNumber!,
                style: AppTypography.codeSmall.copyWith(
                  color: AppColors.electricBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: details.partNumber!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Part number copied'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Icon(
                  Icons.copy,
                  size: 14,
                  color: AppColors.electricBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Parses markdown-like AI descriptions into structured widgets.
  Widget _buildParsedDescription(String description) {
    final lines = description.split('\n');
    final widgets = <Widget>[];
    String? currentHeader;
    List<String> currentBullets = [];

    void flush() {
      if (currentBullets.isNotEmpty) {
        if (currentHeader != null) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                currentHeader!,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.electricBlue,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }
        for (final b in currentBullets) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _cleanMarkdown(b),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          );
        }
        currentBullets = [];
        currentHeader = null;
      }
    }

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) {
        flush();
        continue;
      }

      // Skip stray dollar-number markers (e.g. "$1", "\$1")
      if (RegExp(r'^\\\$\d+\s*$|^\$\d+\s*$').hasMatch(line)) {
        continue;
      }

      // Header: **Title** or **Title:**
      final headerOnly = RegExp(r'^\*\*([^*]+)\*\*:?\s*$').firstMatch(line);
      if (headerOnly != null) {
        flush();
        currentHeader = _cleanMarkdown(headerOnly.group(1)!);
        continue;
      }

      // Inline header: **Title:** content
      final headerInline = RegExp(
        r'^\*\*([^*]+)\*\*\s*:?\s*(.+)$',
      ).firstMatch(line);
      if (headerInline != null) {
        flush();
        currentHeader = _cleanMarkdown(headerInline.group(1)!);
        currentBullets.add(headerInline.group(2)!);
        continue;
      }

      // Bullet
      final bulletStripped = line.replaceFirst(
        RegExp(r'^([*\-•]|\d+\.)\s+'),
        '',
      );
      currentBullets.add(bulletStripped);
    }
    flush();

    if (widgets.isEmpty) {
      return Text(
        _cleanMarkdown(description),
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
          height: 1.6,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  String _cleanMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1')
        .replaceAll(RegExp(r'\*([^*]+)\*'), r'$1')
        .replaceAll(RegExp(r'`([^`]+)`'), r'$1')
        .replaceFirst(RegExp(r'^\s*[*\-•]\s*'), '')
        .replaceAll(RegExp(r'^\\\$\d+\s*$'), '')
        .replaceAll(RegExp(r'^\$\d+\s*$'), '')
        .trim();
  }
}
