import 'package:flutter/material.dart';
import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/app_radius.dart';
import 'package:logos_app/core/design_tokens/font_size.dart';
import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/core/preferences.dart';
import 'package:logos_app/ui/widgets/app_typography.dart';

class ReaderSettingsBottomSheet extends StatefulWidget {
  final VerseDisplayMode currentMode;
  final VerseFontSize currentFontSize;
  final void Function(VerseDisplayMode) onModeChanged;
  final void Function(VerseFontSize) onFontSizeChanged;

  const ReaderSettingsBottomSheet({
    super.key,
    required this.currentMode,
    required this.currentFontSize,
    required this.onModeChanged,
    required this.onFontSizeChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required VerseDisplayMode currentMode,
    required VerseFontSize currentFontSize,
    required void Function(VerseDisplayMode) onModeChanged,
    required void Function(VerseFontSize) onFontSizeChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      // isScrollControlled so the sheet can expand enough for both sections
      isScrollControlled: true,
      builder: (_) => ReaderSettingsBottomSheet(
        currentMode: currentMode,
        currentFontSize: currentFontSize,
        onModeChanged: onModeChanged,
        onFontSizeChanged: onFontSizeChanged,
      ),
    );
  }

  @override
  State<ReaderSettingsBottomSheet> createState() => _ReaderSettingsBottomSheetState();
}

class _ReaderSettingsBottomSheetState extends State<ReaderSettingsBottomSheet> {
  // Local mirror so tapping feels instant — callbacks sync to the VM.
  late VerseDisplayMode _mode;
  late VerseFontSize _fontSize;

  @override
  void initState() {
    super.initState();
    _mode = widget.currentMode;
    _fontSize = widget.currentFontSize;
  }

  void _setMode(VerseDisplayMode mode) {
    setState(() => _mode = mode);
    widget.onModeChanged(mode);
  }

  void _setFontSize(VerseFontSize size) {
    setState(() => _fontSize = size);
    widget.onFontSizeChanged(size);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xs9)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: Spacing.xs6),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.darkText20,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.screenHorizontal,
                vertical: Spacing.xs6,
              ),
              child: AppTypography(
                'Configurações de leitura',
                textStyleTheme: TextStyleTheme.titleMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 1, color: AppColors.darkText10),

            // ── Font size section ────────────────────────────────────────
            _SectionLabel(label: 'Tamanho da fonte'),
            _FontSizeSelector(current: _fontSize, onChanged: _setFontSize),
            const SizedBox(height: Spacing.xs6),
            const Divider(height: 1, color: AppColors.darkText10),

            // ── Display mode section ─────────────────────────────────────
            _SectionLabel(label: 'Exibição dos versículos'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.screenHorizontal),
              child: Row(
                children: [
                  _ModeCard(
                    label: 'Forma de lista',
                    description: 'Cada versículo em sua própria linha',
                    icon: Icons.format_list_numbered_rounded,
                    isSelected: _mode == VerseDisplayMode.list,
                    onTap: () => _setMode(VerseDisplayMode.list),
                  ),
                  const SizedBox(width: Spacing.xs4),
                  _ModeCard(
                    label: 'Estilo bíblia',
                    description: 'Versículos em texto corrido',
                    icon: Icons.menu_book_rounded,
                    isSelected: _mode == VerseDisplayMode.bible,
                    onTap: () => _setMode(VerseDisplayMode.bible),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + Spacing.xxs3),
          ],
        ),
      ),
    );
  }
}

// ── Font size selector ─────────────────────────────────────────────────────

class _FontSizeSelector extends StatelessWidget {
  final VerseFontSize current;
  final void Function(VerseFontSize) onChanged;

  const _FontSizeSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Size buttons row
          Row(
            children: VerseFontSize.values.map((size) {
              final isSelected = size == current;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(size),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: Spacing.xs3),
                    padding: const EdgeInsets.symmetric(vertical: Spacing.xs5),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryBackgroundButton : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xs1),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.darkText10,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Aa',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: size.verseBodySize,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            color: isSelected ? AppColors.primary : AppColors.darkText60,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs1),
                        Text(
                          size.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: FontSize.labelSmall,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            color: isSelected ? AppColors.primaryTextButton : AppColors.darkText50,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: Spacing.xs6),
          // Live preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.xs8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xs1),
              border: Border.all(color: AppColors.darkText10),
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Text(
                        '1',
                        style: TextStyle(
                          fontSize: current.verseNumberSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          height: 1.85,
                        ),
                      ),
                    ),
                  ),
                  TextSpan(
                    text: 'No princípio, Deus criou os céus e a terra. ',
                    style: TextStyle(
                      fontSize: current.verseBodySize,
                      color: AppColors.darkText90,
                      height: 1.7,
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Text(
                        '2',
                        style: TextStyle(
                          fontSize: current.verseNumberSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          height: 1.85,
                        ),
                      ),
                    ),
                  ),
                  TextSpan(
                    text: 'A terra estava sem forma e vazia.',
                    style: TextStyle(
                      fontSize: current.verseBodySize,
                      color: AppColors.darkText90,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Display mode card ──────────────────────────────────────────────────────

class _ModeCard extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(Spacing.xs8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBackgroundButton : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xs3),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.darkText10,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 24, color: isSelected ? AppColors.primary : AppColors.darkText50),
              const SizedBox(height: Spacing.xs4),
              AppTypography(
                label,
                textStyleTheme: TextStyleTheme.bodyMedium,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primaryTextButton : AppColors.darkText,
              ),
              const SizedBox(height: Spacing.xs1),
              AppTypography(
                description,
                textStyleTheme: TextStyleTheme.labelMedium,
                color: isSelected ? AppColors.primaryText30 : AppColors.darkText50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.screenHorizontal,
        Spacing.xs6,
        Spacing.screenHorizontal,
        Spacing.xs4,
      ),
      child: AppTypography(
        label,
        textStyleTheme: TextStyleTheme.labelLarge,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText60,
      ),
    );
  }
}
