import 'package:flutter/material.dart';
import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/app_radius.dart';
import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/domain/bible/bible_models.dart';
import 'package:logos_app/ui/widgets/app_typography.dart';

/// Bottom sheet for selecting a Bible translation.
class TranslationSelectorBottomSheet extends StatelessWidget {
  final BibleTranslation current;
  final void Function(BibleTranslation) onSelect;

  const TranslationSelectorBottomSheet({super.key, required this.current, required this.onSelect});

  static Future<void> show(
    BuildContext context, {
    required BibleTranslation current,
    required void Function(BibleTranslation) onSelect,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => TranslationSelectorBottomSheet(current: current, onSelect: onSelect),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xs9)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: Spacing.xs6),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.darkText20, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.screenHorizontal, vertical: Spacing.xs6),
            child: AppTypography(
              'Tradução',
              textStyleTheme: TextStyleTheme.titleMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(height: 1, color: AppColors.darkText10),
          ...BibleTranslation.values.map(
            (t) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.screenHorizontal),
              title: AppTypography(
                t.abbreviation,
                textStyleTheme: TextStyleTheme.bodyLarge,
                fontWeight: FontWeight.w600,
              ),
              subtitle: AppTypography(
                t.fullName,
                textStyleTheme: TextStyleTheme.bodySmall,
                color: AppColors.darkText60,
              ),
              trailing: t == current
                  ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                Navigator.pop(context);
                onSelect(t);
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + Spacing.xs8),
        ],
      ),
    );
  }
}
