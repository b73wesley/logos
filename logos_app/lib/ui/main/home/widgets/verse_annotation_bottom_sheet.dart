import 'package:flutter/material.dart';
import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/app_radius.dart';
import 'package:logos_app/core/design_tokens/font_size.dart';
import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/domain/annotation/annotation_models.dart';
import 'package:logos_app/domain/bible/bible_models.dart';
import 'package:logos_app/ui/main/home/annotation_view_model.dart';
import 'package:logos_app/ui/widgets/app_button.dart';
import 'package:logos_app/ui/widgets/app_text_field.dart';
import 'package:logos_app/core/design_tokens/app_text_field_type.dart';
import 'package:logos_app/ui/widgets/app_typography.dart';
import 'package:logos_app/ui/widgets/app_typography_md.dart';
import 'package:provider/provider.dart';

class VerseAnnotationBottomSheet extends StatefulWidget {
  final BibleVerse verse;
  final String bookName;
  final VerseAnnotation? existing;

  const VerseAnnotationBottomSheet({super.key, required this.verse, required this.bookName, this.existing});

  static Future<void> show(
    BuildContext context, {
    required BibleVerse verse,
    required String bookName,
    VerseAnnotation? existing,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VerseAnnotationBottomSheet(verse: verse, bookName: bookName, existing: existing),
    );
  }

  @override
  State<VerseAnnotationBottomSheet> createState() => _VerseAnnotationBottomSheetState();
}

class _VerseAnnotationBottomSheetState extends State<VerseAnnotationBottomSheet> {
  late final TextEditingController _commentController;
  HighlightColor? _selectedColor;
  HighlightMode _highlightMode = HighlightMode.background;
  bool _removeHighlight = false;
  bool _showCommentPreview = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.existing?.comment ?? '');
    _selectedColor = widget.existing?.highlightColor;
    _highlightMode = widget.existing?.highlightMode ?? HighlightMode.background;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleColor(HighlightColor color) {
    setState(() {
      if (_selectedColor == color) {
        // Deselect — mark for removal
        _selectedColor = null;
        _removeHighlight = true;
      } else {
        _selectedColor = color;
        _removeHighlight = false;
      }
    });
  }

  Future<void> _save() async {
    final vm = context.read<AnnotationViewModel>();
    await vm.saveVerseAnnotation(
      bookNumber: widget.verse.bookNumber,
      chapter: widget.verse.chapter,
      verseNumber: widget.verse.verseNumber,
      highlightColor: _selectedColor,
      highlightMode: _highlightMode,
      comment: _commentController.text,
      removeHighlight: _removeHighlight,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xs9)),
      ),
      padding: EdgeInsets.fromLTRB(
        Spacing.screenHorizontal,
        Spacing.xs6,
        Spacing.screenHorizontal,
        bottomInset + Spacing.xxs3,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkText20,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: Spacing.xs6),

            // Header
            AppTypography(
              '${widget.bookName} ${widget.verse.chapter}:${widget.verse.verseNumber}',
              textStyleTheme: TextStyleTheme.titleMedium,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: Spacing.xs3),

            // Verse text preview — updates live with color + mode selection
            Container(
              padding: const EdgeInsets.all(Spacing.xs8),
              decoration: BoxDecoration(
                color: (_selectedColor != null && _highlightMode == HighlightMode.background)
                    ? _selectedColor!.color
                    : AppColors.darkText05,
                borderRadius: BorderRadius.circular(AppRadius.xs1),
                border: _selectedColor != null
                    ? Border(left: BorderSide(color: _selectedColor!.borderColor, width: 3))
                    : null,
              ),
              child: Text(
                widget.verse.text,
                style: TextStyle(
                  fontSize: FontSize.bodyMedium,
                  color: (_selectedColor != null && _highlightMode == HighlightMode.textColor)
                      ? _selectedColor!.borderColor
                      : AppColors.darkText90,
                  height: 1.6,
                  fontWeight: (_selectedColor != null && _highlightMode == HighlightMode.textColor)
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: Spacing.xxs1),

            // Highlight color picker
            AppTypography(
              'Marcador',
              textStyleTheme: TextStyleTheme.labelLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText60,
            ),
            const SizedBox(height: Spacing.xs4),
            Row(
              children: HighlightColor.values.map((color) {
                final isSelected = _selectedColor == color;
                return Padding(
                  padding: const EdgeInsets.only(right: Spacing.xs5),
                  child: GestureDetector(
                    onTap: () => _toggleColor(color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? color.borderColor : AppColors.darkText20,
                          width: isSelected ? 3 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.borderColor.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(Icons.check_rounded, size: 18, color: color.borderColor)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: Spacing.xs4),

            // Highlight mode switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xs8, vertical: Spacing.xs3),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xs1),
                border: Border.all(color: AppColors.darkText10),
              ),
              child: Row(
                children: [
                  Icon(
                    _highlightMode == HighlightMode.textColor
                        ? Icons.format_color_text_rounded
                        : Icons.format_color_fill_rounded,
                    size: 18,
                    color: AppColors.darkText60,
                  ),
                  const SizedBox(width: Spacing.xs4),
                  Expanded(
                    child: AppTypography(
                      _highlightMode == HighlightMode.textColor ? 'Letra colorida' : 'Texto marcado',
                      textStyleTheme: TextStyleTheme.bodyMedium,
                      color: AppColors.darkText,
                    ),
                  ),
                  Switch.adaptive(
                    value: _highlightMode == HighlightMode.textColor,
                    onChanged: _selectedColor == null
                        ? null
                        : (on) => setState(() {
                            _highlightMode = on ? HighlightMode.textColor : HighlightMode.background;
                          }),
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary40,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.xxs1),

            // Comment field
            Row(
              children: [
                AppTypography(
                  'Comentário',
                  textStyleTheme: TextStyleTheme.labelLarge,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText60,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _showCommentPreview = !_showCommentPreview),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.xs4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _showCommentPreview ? 'Editar' : 'Prévia',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs4),
            if (_showCommentPreview)
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.all(Spacing.xs8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xs1),
                  border: Border.all(color: AppColors.darkText10),
                ),
                child: _commentController.text.trim().isEmpty
                    ? AppTypography(
                        'Nada para exibir ainda...',
                        textStyleTheme: TextStyleTheme.bodySmall,
                        color: AppColors.darkText40,
                      )
                    : AppTypographyMD(_commentController.text, textStyleTheme: TextStyleTheme.bodyMedium),
              )
            else
              AppTextField(
                controller: _commentController,
                title: 'Suporta markdown: **negrito**, *itálico*...',
                fieldType: AppTextFieldType.description,
              ),
            const SizedBox(height: Spacing.xxs1),

            // Save button
            Consumer<AnnotationViewModel>(
              builder: (context, vm, _) => AppButton('Salvar', isLoading: vm.isSaving, onPressed: _save),
            ),
          ],
        ),
      ),
    );
  }
}
