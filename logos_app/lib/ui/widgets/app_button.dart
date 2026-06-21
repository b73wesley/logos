import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/app_radius.dart';
import 'package:logos_app/core/design_tokens/button_style_theme.dart';
import 'package:logos_app/core/design_tokens/font_size.dart';
import 'package:logos_app/core/design_tokens/icon_size.dart';
import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/ui/widgets/app_font.dart';
import 'package:logos_app/ui/widgets/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// Button styles following Material 3 guidelines.
/// [text] is the text to be displayed.
/// [onPressed] is the callback function when the button is pressed.
/// [isLoading] is a boolean to show a loading indicator.
/// [icon] is the icon to be displayed.
/// [buttonStyleTheme] is the style of the button.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final ButtonStyleTheme buttonStyleTheme;
  final String? description;

  const AppButton(
    this.text, {
    super.key,
    this.buttonStyleTheme = ButtonStyleTheme.primary,
    this.description,
    this.icon,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return buttonStyleTheme == ButtonStyleTheme.link
        ? _LinkButton(text: text, onPressed: onPressed)
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getBackgroundColor(),
              foregroundColor: _getForegroundColor(),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xs1)),
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xs8, vertical: Spacing.xs6),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.xs1),
              child: Row(
                mainAxisAlignment: (icon == null) ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  if (icon != null) Icon(icon, size: IconSize.normal),
                  if (icon != null) const SizedBox(width: Spacing.xs5),
                  if (isLoading) const SizedBox(width: Spacing.screenHorizontal),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTypography(
                          text,
                          fontWeight: FontWeight.w600,
                          textStyleTheme: TextStyleTheme.bodyLarge,
                          color: _getTextColor(),
                        ),
                        if (description != null)
                          AppTypography(
                            description!,
                            fontWeight: FontWeight.w600,
                            color: _getSecondaryTextColor(),
                            textStyleTheme: TextStyleTheme.labelMedium,
                          ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.screenHorizontal),
                      child: SizedBox(
                        height: IconSize.small,
                        width: IconSize.small,
                        child: CircularProgressIndicator(strokeWidth: 2, color: _getTextColor()),
                      ),
                    ),
                ],
              ),
            ),
          );
  }

  Color _getBackgroundColor() {
    switch (buttonStyleTheme) {
      case ButtonStyleTheme.primary:
        return AppColors.primaryBackgroundButton;
      case ButtonStyleTheme.secondary:
        return AppColors.secondaryBackgroundButton;
      case ButtonStyleTheme.neutral:
        return AppColors.surface;
      default:
        return AppColors.primaryBackgroundButton;
    }
  }

  Color _getForegroundColor() {
    switch (buttonStyleTheme) {
      case ButtonStyleTheme.primary:
        return AppColors.primaryTextButton;
      case ButtonStyleTheme.secondary:
        return AppColors.secondaryTextButton;
      case ButtonStyleTheme.neutral:
        return AppColors.darkText;
      default:
        return AppColors.primaryTextButton;
    }
  }

  Color _getTextColor() {
    switch (buttonStyleTheme) {
      case ButtonStyleTheme.primary:
        return AppColors.primaryText;
      case ButtonStyleTheme.secondary:
        return AppColors.warning;
      case ButtonStyleTheme.neutral:
        return AppColors.darkText;
      default:
        return AppColors.primaryTextButton;
    }
  }

  Color _getSecondaryTextColor() {
    switch (buttonStyleTheme) {
      case ButtonStyleTheme.primary:
        return AppColors.primaryText20;
      case ButtonStyleTheme.secondary:
        return AppColors.warning20;
      case ButtonStyleTheme.neutral:
        return AppColors.darkText60;
      default:
        return AppColors.primaryTextButton;
    }
  }
}

class _LinkButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;

  const _LinkButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.only(bottom: Spacing.xxs6, top: Spacing.xs9),
        child: MarkdownBody(
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              color: AppColors.primaryTextButton,
              fontSize: FontSize.bodyMedium,
              fontFamily: AppFont().font.fontFamily,
            ),
          ),
          data: text,
        ),
      ),
    );
  }
}
