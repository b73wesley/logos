import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/font_size.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/ui/widgets/app_font.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? textOverflow;
  final TextStyleTheme textStyleTheme;
  final FontWeight? fontWeight;
  final bool isDarkTheme;
  final bool isSecundary;
  final Color? color;

  const AppTypography(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.textOverflow,
    this.fontWeight,
    this.color,
    this.textStyleTheme = TextStyleTheme.bodyMedium,
    this.isDarkTheme = false,
    this.isSecundary = false,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle theme = AppFont().font.copyWith(
      color: _getTextColor(),
      fontWeight: fontWeight,
      fontSize: _getFontSize(),
    );

    return Text(text, textAlign: textAlign, maxLines: maxLines, overflow: textOverflow, style: theme);
  }

  Color _getTextColor() {
    return color ??
        (isDarkTheme
            ? (isSecundary ? AppColors.secundaryWhiteText : AppColors.whiteText)
            : (isSecundary ? AppColors.secundaryDarkText : AppColors.darkText));
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
}

class TitleText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? textOverflow;
  final TextStyleTheme textStyleTheme;
  final FontWeight? fontWeight;
  final bool isDarkTheme;

  const TitleText({
    super.key,
    required this.text,
    this.textAlign,
    this.maxLines,
    this.textOverflow,
    required this.textStyleTheme,
    this.fontWeight,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    var theme = AppFont().font;

    switch (textStyleTheme) {
      case TextStyleTheme.titleSmall:
        theme = theme.copyWith(fontSize: FontSize.titleSmall);
      case TextStyleTheme.titleMedium:
        theme = theme.copyWith(fontSize: FontSize.titleMedium);
      case TextStyleTheme.titleLarge:
        theme = theme.copyWith(fontSize: FontSize.titleLarge);
      default: // do nothing
    }
    theme = theme.copyWith(
      color: isDarkTheme ? AppColors.whiteText : AppColors.darkText,
      fontWeight: fontWeight,
    );

    return Text(text, textAlign: textAlign, maxLines: maxLines, overflow: textOverflow, style: theme);
  }
}

class Headline extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? textOverflow;
  final FontWeight? fontWeight;
  final TextStyleTheme textStyleTheme;
  final bool isDarkTheme;

  const Headline({
    super.key,
    required this.text,
    this.textAlign,
    this.maxLines,
    this.textOverflow,
    required this.textStyleTheme,
    this.fontWeight,
    this.isDarkTheme = false,
  });

  @override
  Widget build(BuildContext context) {
    var theme = AppFont().font.copyWith(
      color: isDarkTheme ? AppColors.whiteText : AppColors.darkText,
      fontWeight: fontWeight,
    );
    switch (textStyleTheme) {
      case TextStyleTheme.headlineSmall:
        theme = theme.copyWith(fontSize: FontSize.headlineSmall);
      case TextStyleTheme.headlineMedium:
        theme = theme.copyWith(fontSize: FontSize.headlineMedium);
      case TextStyleTheme.headlineLarge:
        theme = theme.copyWith(fontSize: FontSize.headlineLarge);
      default: // do nothing
    }
    return Text(text, textAlign: textAlign, maxLines: maxLines, overflow: textOverflow, style: theme);
  }
}

class Display extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? textOverflow;
  final TextStyleTheme textStyleTheme;

  const Display({
    super.key,
    required this.text,
    this.textAlign,
    this.maxLines,
    this.textOverflow,
    required this.textStyleTheme,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle? theme;
    switch (textStyleTheme) {
      case TextStyleTheme.displaySmall:
        theme = Theme.of(context).textTheme.displaySmall;
      case TextStyleTheme.displayMedium:
        theme = GoogleFonts.nunito();
      case TextStyleTheme.displayLarge:
        theme = Theme.of(context).textTheme.displayLarge;
      default:
        theme = Theme.of(context).textTheme.displayMedium;
    }
    theme = theme?.copyWith(color: AppColors.darkText);

    return Text(text, textAlign: textAlign, maxLines: maxLines, overflow: textOverflow, style: theme);
  }
}
