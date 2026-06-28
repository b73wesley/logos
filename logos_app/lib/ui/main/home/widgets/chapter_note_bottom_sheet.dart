import 'package:flutter/material.dart';
import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/app_radius.dart';
import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/domain/annotation/annotation_models.dart';
import 'package:logos_app/ui/main/home/annotation_view_model.dart';
import 'package:logos_app/ui/widgets/app_button.dart';
import 'package:logos_app/ui/widgets/app_text_field.dart';
import 'package:logos_app/core/design_tokens/app_text_field_type.dart';
import 'package:logos_app/ui/widgets/app_typography.dart';
import 'package:logos_app/ui/widgets/app_typography_md.dart';
import 'package:provider/provider.dart';

class ChapterNoteBottomSheet extends StatefulWidget {
  final int bookNumber;
  final String bookName;
  final int chapter;
  final ChapterNote? existing;

  const ChapterNoteBottomSheet({
    super.key,
    required this.bookNumber,
    required this.bookName,
    required this.chapter,
    this.existing,
  });

  static Future<void> show(
    BuildContext context, {
    required int bookNumber,
    required String bookName,
    required int chapter,
    ChapterNote? existing,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChapterNoteBottomSheet(
        bookNumber: bookNumber,
        bookName: bookName,
        chapter: chapter,
        existing: existing,
      ),
    );
  }

  @override
  State<ChapterNoteBottomSheet> createState() => _ChapterNoteBottomSheetState();
}

class _ChapterNoteBottomSheetState extends State<ChapterNoteBottomSheet> {
  late final TextEditingController _noteController;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.existing?.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final vm = context.read<AnnotationViewModel>();
    await vm.saveChapterNote(
      bookNumber: widget.bookNumber,
      chapter: widget.chapter,
      note: _noteController.text,
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

            // Header + preview toggle
            Row(
              children: [
                const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: Spacing.xs3),
                Expanded(
                  child: AppTypography(
                    'Notas — ${widget.bookName} ${widget.chapter}',
                    textStyleTheme: TextStyleTheme.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Edit / Preview toggle
                TextButton(
                  onPressed: () => setState(() => _showPreview = !_showPreview),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.xs4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _showPreview ? 'Editar' : 'Prévia',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xxs1),

            // Note field OR markdown preview
            if (_showPreview)
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 80),
                padding: const EdgeInsets.all(Spacing.xs8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xs1),
                  border: Border.all(color: AppColors.darkText10),
                ),
                child: _noteController.text.trim().isEmpty
                    ? AppTypography(
                        'Nada para exibir ainda...',
                        textStyleTheme: TextStyleTheme.bodySmall,
                        color: AppColors.darkText40,
                      )
                    : AppTypographyMD(_noteController.text, textStyleTheme: TextStyleTheme.bodyMedium),
              )
            else
              AppTextField(
                controller: _noteController,
                title: 'Suporta markdown: **negrito**, *itálico*, - listas...',
                fieldType: AppTextFieldType.description,
              ),
            const SizedBox(height: Spacing.xxs1),

            // Delete note button (only shown if there's an existing note)
            if (widget.existing != null) ...[
              Consumer<AnnotationViewModel>(
                builder: (context, vm, _) => TextButton.icon(
                  onPressed: vm.isSaving
                      ? null
                      : () async {
                          _noteController.clear();
                          await _save();
                        },
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Excluir nota'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error, padding: EdgeInsets.zero),
                ),
              ),
              const SizedBox(height: Spacing.xs4),
            ],

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
