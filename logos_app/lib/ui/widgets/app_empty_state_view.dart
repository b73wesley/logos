import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/ui/widgets/app_button.dart';
import 'package:logos_app/ui/widgets/app_typography.dart';
import 'package:flutter/material.dart';

class AppEmptyStateView extends StatelessWidget {
  final String? imageAsset;
  final String? title;
  final String? description;
  final String? primaryActionText;
  final String? secondaryActionText;
  final void Function()? onPrimaryAction;
  final void Function()? onSecondaryAction;

  const AppEmptyStateView({
    super.key,
    this.imageAsset,
    this.title,
    this.description,
    this.primaryActionText,
    this.secondaryActionText,
    this.onPrimaryAction,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.screenHorizontal),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageAsset != null) Image.asset(imageAsset!, width: 200, height: 200),
            const SizedBox(height: Spacing.betweenElementsVX),
            AppTypography(title ?? 'No Data Available', textStyleTheme: TextStyleTheme.titleMedium),
            const SizedBox(height: Spacing.anchor),
            AppTypography(
              description ?? 'There is no data to display at the moment.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.xxs6),
            if (onPrimaryAction != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.xs8),
                  child: AppButton(primaryActionText ?? 'Confirm', onPressed: () => onPrimaryAction!()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
