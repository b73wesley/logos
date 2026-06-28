import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/font_size.dart';
import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/ui/widgets/app_font.dart';

/// Drop-in replacement for [AppTypography] when the text may contain Markdown.
///
/// Supports the same [textStyleTheme], [fontWeight], [color], [isDarkTheme] and
/// [isSecundary] parameters as [AppTypography], so it can be swapped without
/// changing call-sites.
///
/// Renders with [MarkdownBody] from `flutter_markdown_plus`, styled via
/// [MarkdownStyleSheet] built from the app design tokens, keeping full
/// typographic consistency with the rest of the app.
///
/// Use cases:
/// - Notes and comments where the user may write **bold**, *italic*, lists, etc.
/// - Any content that comes from a source that may contain Markdown.
///
/// When the content is guaranteed plain text, prefer [AppTypography].
class AppTypographyMD extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final TextStyleTheme textStyleTheme;
  final FontWeight? fontWeight;
  final bool isDarkTheme;
  final bool isSecundary;
  final Color? color;

  /// Whether to shrink-wrap the content. Pass [false] when this widget is
  /// inside a scrollable parent that already provides unbounded height.
  final bool shrinkWrap;

  const AppTypographyMD(
    this.text, {
    super.key,
    this.textAlign,
    this.fontWeight,
    this.color,
    this.textStyleTheme = TextStyleTheme.bodyMedium,
    this.isDarkTheme = false,
    this.isSecundary = false,
    this.shrinkWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor =
        color ??
        (isDarkTheme
            ? (isSecundary ? AppColors.secundaryWhiteText : AppColors.whiteText)
            : (isSecundary ? AppColors.secundaryDarkText : AppColors.darkText));

    final baseFontSize = _getFontSize();
    final fontFamily = AppFont().font.fontFamily;

    // Local helper — named without underscore to satisfy the linter.
    TextStyle styled({double? size, FontWeight? weight, Color? c, FontStyle? style}) => TextStyle(
      fontFamily: fontFamily,
      fontSize: size ?? baseFontSize,
      fontWeight: weight ?? fontWeight,
      color: c ?? resolvedColor,
      fontStyle: style,
    );

    final styleSheet = MarkdownStyleSheet(
      // ── Paragraphs ────────────────────────────────────────────────────────
      p: styled(),
      pPadding: const EdgeInsets.only(bottom: Spacing.xs4),

      // ── Inline emphasis ───────────────────────────────────────────────────
      strong: styled(weight: FontWeight.w700),
      em: styled(style: FontStyle.italic),
      del: styled(c: resolvedColor.withValues(alpha: 0.5)),

      // ── Headings — map to app title tokens ────────────────────────────────
      h1: styled(size: FontSize.titleLarge, weight: FontWeight.w700),
      h2: styled(size: FontSize.titleMedium, weight: FontWeight.w700),
      h3: styled(size: FontSize.titleSmall, weight: FontWeight.w600),
      h4: styled(size: FontSize.bodyLarge, weight: FontWeight.w600),
      h5: styled(size: FontSize.bodyMedium, weight: FontWeight.w600),
      h6: styled(size: FontSize.bodySmall, weight: FontWeight.w600),
      h1Padding: const EdgeInsets.only(bottom: Spacing.xs6),
      h2Padding: const EdgeInsets.only(bottom: Spacing.xs5),
      h3Padding: const EdgeInsets.only(bottom: Spacing.xs4),

      // ── Inline code ───────────────────────────────────────────────────────
      code: styled(
        c: AppColors.primaryTextButton,
      ).copyWith(backgroundColor: AppColors.primaryBackgroundButton, fontFamily: 'monospace'),

      // ── Code block ────────────────────────────────────────────────────────
      codeblockDecoration: BoxDecoration(
        color: AppColors.primaryBackgroundButton,
        borderRadius: BorderRadius.circular(4),
      ),
      codeblockPadding: const EdgeInsets.all(Spacing.xs8),

      // ── Block quote ───────────────────────────────────────────────────────
      blockquote: styled(c: resolvedColor.withValues(alpha: 0.7), style: FontStyle.italic),
      blockquoteDecoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
      ),
      blockquotePadding: const EdgeInsets.symmetric(horizontal: Spacing.xs8, vertical: Spacing.xs2),

      // ── Lists ─────────────────────────────────────────────────────────────
      listBullet: styled(),
      listBulletPadding: const EdgeInsets.only(right: Spacing.xs4),
      listIndent: Spacing.xxs1,

      // ── Horizontal rule ───────────────────────────────────────────────────
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: resolvedColor.withValues(alpha: 0.2), width: 1)),
      ),

      // ── Links ─────────────────────────────────────────────────────────────
      a: styled(
        c: AppColors.primary,
      ).copyWith(decoration: TextDecoration.underline, decorationColor: AppColors.primary),

      // ── Tables ───────────────────────────────────────────────────────────
      tableHead: styled(weight: FontWeight.w700),
      tableBody: styled(),
      tableBorder: TableBorder.all(color: resolvedColor.withValues(alpha: 0.15)),
      tableColumnWidth: const FlexColumnWidth(),
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: Spacing.xs6, vertical: Spacing.xs3),

      // ── Text alignment ────────────────────────────────────────────────────
      textAlign: _toWrapAlignment(textAlign),
    );

    return MarkdownBody(
      data: text,
      styleSheet: styleSheet,
      shrinkWrap: shrinkWrap,
      // Soft line breaks (\n) rendered as line breaks, matching plain Text behavior.
      softLineBreak: true,
    );
  }

  double _getFontSize() {
    switch (textStyleTheme) {
      case TextStyleTheme.bodySmall:
        return FontSize.bodySmall;
      case TextStyleTheme.bodyMedium:
        return FontSize.bodyMedium;
      case TextStyleTheme.bodyLarge:
        return FontSize.bodyLarge;
      case TextStyleTheme.headlineSmall:
        return FontSize.headlineSmall;
      case TextStyleTheme.headlineMedium:
        return FontSize.headlineMedium;
      case TextStyleTheme.headlineLarge:
        return FontSize.headlineLarge;
      case TextStyleTheme.labelSmall:
        return FontSize.labelSmall;
      case TextStyleTheme.labelMedium:
        return FontSize.labelMedium;
      case TextStyleTheme.labelLarge:
        return FontSize.labelLarge;
      case TextStyleTheme.titleSmall:
        return FontSize.titleSmall;
      case TextStyleTheme.titleMedium:
        return FontSize.titleMedium;
      case TextStyleTheme.titleLarge:
        return FontSize.titleLarge;
      default:
        return FontSize.bodyMedium;
    }
  }

  WrapAlignment _toWrapAlignment(TextAlign? align) {
    switch (align) {
      case TextAlign.center:
        return WrapAlignment.center;
      case TextAlign.end:
      case TextAlign.right:
        return WrapAlignment.end;
      case TextAlign.justify:
        return WrapAlignment.spaceAround;
      default:
        return WrapAlignment.start;
    }
  }
}
