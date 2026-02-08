import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../styles/styles.dart';

/// Pretty-renders markdown text from AI responses inside chat bubbles.
///
/// Handles **bold**, *italic*, `code`, bullet lists, numbered lists,
/// headings, and horizontal rules using the app design system.
class FormattedMarkdown extends StatelessWidget {
  /// The raw markdown string to render.
  final String data;

  /// Text colour (switches between light-on-dark and dark-on-light).
  final Color textColor;

  /// Secondary text colour for less-prominent elements.
  final Color secondaryColor;

  /// Accent colour for links and code block decoration.
  final Color accentColor;

  const FormattedMarkdown({
    super.key,
    required this.data,
    this.textColor = AppColors.textPrimary,
    this.secondaryColor = AppColors.textSecondary,
    this.accentColor = AppColors.electricBlue,
  });

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      selectable: true,
      softLineBreak: true,
      styleSheet: _buildStyleSheet(context),
      // Prevent link launches – we're in a chat bubble
      onTapLink: (_, href, __) {},
    );
  }

  MarkdownStyleSheet _buildStyleSheet(BuildContext context) {
    final baseText = AppTypography.bodyMedium.copyWith(
      color: textColor,
      height: 1.55,
    );

    return MarkdownStyleSheet(
      // --- Body / paragraphs ---
      p: baseText,
      pPadding: const EdgeInsets.only(bottom: 6),

      // --- Headings ---
      h1: baseText.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
      h1Padding: const EdgeInsets.only(top: 8, bottom: 4),
      h2: baseText.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
      h2Padding: const EdgeInsets.only(top: 6, bottom: 4),
      h3: baseText.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
      h3Padding: const EdgeInsets.only(top: 4, bottom: 2),
      h4: baseText.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      h5: baseText.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
      h6: baseText.copyWith(fontSize: 12, fontWeight: FontWeight.w600),

      // --- Bold / italic ---
      strong: baseText.copyWith(fontWeight: FontWeight.w700),
      em: baseText.copyWith(fontStyle: FontStyle.italic),

      // --- Inline code ---
      code: TextStyle(
        fontFamily: AppTypography.monoFontFamily,
        fontSize: 12.5,
        color: accentColor,
        backgroundColor: accentColor.withValues(alpha: 0.08),
      ),

      // --- Code blocks ---
      codeblockDecoration: BoxDecoration(
        color: AppColors.zinc100,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(color: AppColors.border),
      ),
      codeblockPadding: const EdgeInsets.all(AppSpacing.sm),

      // --- Bullet / ordered lists ---
      listBullet: baseText.copyWith(color: accentColor),
      listBulletPadding: const EdgeInsets.only(right: 6),
      listIndent: 16,

      // --- Blockquote ---
      blockquote: baseText.copyWith(
        color: secondaryColor,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: accentColor, width: 3)),
      ),
      blockquotePadding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),

      // --- Horizontal rule ---
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),

      // --- Links ---
      a: baseText.copyWith(
        color: accentColor,
        decoration: TextDecoration.underline,
        decorationColor: accentColor,
      ),

      // --- Table ---
      tableHead: baseText.copyWith(fontWeight: FontWeight.w600),
      tableBody: baseText,
      tableBorder: TableBorder.all(color: AppColors.border, width: 0.5),
      tableHeadAlign: TextAlign.left,
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
