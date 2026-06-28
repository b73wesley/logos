import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/app_radius.dart';
import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/core/preferences.dart';
import 'package:logos_app/domain/annotation/annotation_models.dart';
import 'package:logos_app/domain/bible/bible_models.dart';
import 'package:logos_app/ui/main/home/annotation_view_model.dart';
import 'package:logos_app/ui/main/home/home_view_model.dart';
import 'package:logos_app/ui/main/home/widgets/book_selector_bottom_sheet.dart';
import 'package:logos_app/ui/main/home/widgets/chapter_note_bottom_sheet.dart';
import 'package:logos_app/ui/main/home/widgets/reader_settings_bottom_sheet.dart';
import 'package:logos_app/ui/main/home/widgets/translation_selector_bottom_sheet.dart';
import 'package:logos_app/ui/main/home/widgets/verse_annotation_bottom_sheet.dart';
import 'package:logos_app/ui/widgets/app_empty_state_view.dart';
import 'package:logos_app/ui/widgets/app_typography.dart';
import 'package:logos_app/ui/widgets/app_typography_md.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: _ReaderAppBar(vm: vm),
          ),
          body: vm.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : vm.errorMessage != null
              ? AppEmptyStateView(title: 'Erro ao carregar', description: vm.errorMessage)
              : _ReaderBody(vm: vm),
        );
      },
    );
  }
}

// ── AppBar ─────────────────────────────────────────────────────────────────

class _ReaderAppBar extends StatelessWidget {
  final HomeViewModel vm;

  const _ReaderAppBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    final book = vm.currentBook;

    return SafeArea(
      child: Container(
        height: 56,
        color: AppColors.backgroundLight,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xs4),
        child: Row(
          children: [
            _ControlChip(
              label: vm.selectedTranslation.abbreviation,
              onTap: () => TranslationSelectorBottomSheet.show(
                context,
                current: vm.selectedTranslation,
                onSelect: vm.selectTranslation,
              ),
            ),
            const SizedBox(width: Spacing.xs3),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (vm.books.isEmpty) return;
                  _openBookSelector(context, vm);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.xs6, vertical: Spacing.xs2),
                  decoration: BoxDecoration(
                    color: AppColors.darkText05,
                    borderRadius: BorderRadius.circular(AppRadius.xs1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: AppTypography(
                          book != null ? '${book.name} ${vm.selectedChapterIndex + 1}' : '—',
                          textStyleTheme: TextStyleTheme.bodyLarge,
                          fontWeight: FontWeight.w600,
                          maxLines: 1,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: Spacing.xs2),
                      const Icon(Icons.expand_more_rounded, size: 18, color: AppColors.darkText60),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: Spacing.xs3),
            _IconBtn(icon: Icons.search_rounded, onTap: () {}),
            _IconBtn(
              icon: Icons.settings_outlined,
              onTap: () => ReaderSettingsBottomSheet.show(
                context,
                currentMode: vm.verseDisplayMode,
                currentFontSize: vm.verseFontSize,
                onModeChanged: vm.setVerseDisplayMode,
                onFontSizeChanged: vm.setVerseFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _openBookSelector(BuildContext context, HomeViewModel vm) {
  BookSelectorBottomSheet.show(
    context,
    books: vm.books,
    currentBookIndex: vm.selectedBookIndex,
    currentChapterIndex: vm.selectedChapterIndex,
    onSelect: (bookIdx, chapIdx) {
      vm.selectBook(bookIdx);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.selectChapter(chapIdx);
      });
    },
  );
}

class _ControlChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ControlChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xs6, vertical: Spacing.xs2),
        decoration: BoxDecoration(
          color: AppColors.primaryBackgroundButton,
          borderRadius: BorderRadius.circular(AppRadius.xs1),
        ),
        child: AppTypography(
          label,
          textStyleTheme: TextStyleTheme.labelLarge,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryTextButton,
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.darkText70, size: 22),
      padding: const EdgeInsets.all(Spacing.xs2),
      constraints: const BoxConstraints(),
    );
  }
}

// ── Body ───────────────────────────────────────────────────────────────────

class _ReaderBody extends StatelessWidget {
  final HomeViewModel vm;

  const _ReaderBody({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: vm.pageController,
          itemCount: vm.currentBook?.totalChapters ?? 0,
          onPageChanged: (page) {
            vm.onPageChanged(page);
            // Load annotations for the new chapter.
            final book = vm.currentBook;
            if (book != null && page < book.chapters.length) {
              final chapter = book.chapters[page];
              context.read<AnnotationViewModel>().loadChapter(chapter.bookNumber, chapter.chapterNumber);
            }
          },
          itemBuilder: (context, chapterIndex) {
            final book = vm.currentBook;
            if (book == null || chapterIndex >= book.chapters.length) {
              return const SizedBox.shrink();
            }
            final chapter = book.chapters[chapterIndex];
            return _ChapterPage(
              book: book,
              chapter: chapter,
              displayMode: vm.verseDisplayMode,
              fontSize: vm.verseFontSize,
            );
          },
        ),
        Positioned(left: 0, right: 0, bottom: 0, child: _NavigationBar(vm: vm)),
      ],
    );
  }
}

// ── Chapter page ───────────────────────────────────────────────────────────

class _ChapterPage extends StatelessWidget {
  final BibleBook book;
  final BibleChapter chapter;
  final VerseDisplayMode displayMode;
  final VerseFontSize fontSize;

  const _ChapterPage({
    required this.book,
    required this.chapter,
    required this.displayMode,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AnnotationViewModel>(
      builder: (context, annotationVm, _) {
        final chapterNote = annotationVm.chapterNote;
        final hasNote = annotationVm.chapterHasNote(chapter.bookNumber, chapter.chapterNumber);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.screenHorizontal,
                  Spacing.xxs3,
                  Spacing.screenHorizontal,
                  Spacing.xxs1,
                ),
                child: Column(
                  children: [
                    AppTypography(
                      'CAPÍTULO',
                      textStyleTheme: TextStyleTheme.labelSmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText50,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.xs2),
                    // Tap on chapter number to add/edit chapter note
                    GestureDetector(
                      onTap: () => ChapterNoteBottomSheet.show(
                        context,
                        bookNumber: chapter.bookNumber,
                        bookName: book.name,
                        chapter: chapter.chapterNumber,
                        existing: chapterNote,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          AppTypography(
                            '${chapter.chapterNumber}',
                            textStyleTheme: TextStyleTheme.headlineLarge,
                            fontWeight: FontWeight.w700,
                            textAlign: TextAlign.center,
                          ),
                          if (hasNote)
                            Positioned(
                              right: -20,
                              top: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.warning,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Show note preview if exists
                    if (hasNote && chapterNote != null) ...[
                      const SizedBox(height: Spacing.xs3),
                      GestureDetector(
                        onTap: () => ChapterNoteBottomSheet.show(
                          context,
                          bookNumber: chapter.bookNumber,
                          bookName: book.name,
                          chapter: chapter.chapterNumber,
                          existing: chapterNote,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: Spacing.xs8, vertical: Spacing.xs4),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBackgroundButton,
                            borderRadius: BorderRadius.circular(AppRadius.xs1),
                            border: Border.all(color: AppColors.warning30),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(Icons.edit_note_rounded, size: 16, color: AppColors.warning),
                              ),
                              const SizedBox(width: Spacing.xs3),
                              Expanded(
                                child: AppTypographyMD(
                                  chapterNote.note,
                                  textStyleTheme: TextStyleTheme.bodySmall,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: Spacing.xxs3),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.screenHorizontal,
                0,
                Spacing.screenHorizontal,
                96, // space for nav bar
              ),
              sliver: displayMode == VerseDisplayMode.list
                  ? _VerseListSliver(
                      chapter: chapter,
                      fontSize: fontSize,
                      bookName: book.name,
                      annotationVm: annotationVm,
                    )
                  : _VerseBibleStyleSliver(
                      chapter: chapter,
                      fontSize: fontSize,
                      bookName: book.name,
                      annotationVm: annotationVm,
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ── List mode ─────────────────────────────────────────────────────────────

/// One verse per row, with spacing between each.
class _VerseListSliver extends StatelessWidget {
  final BibleChapter chapter;
  final VerseFontSize fontSize;
  final String bookName;
  final AnnotationViewModel annotationVm;

  const _VerseListSliver({
    required this.chapter,
    required this.fontSize,
    required this.bookName,
    required this.annotationVm,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final verse = chapter.verses[index];
        final annotation = annotationVm.annotationForVerse(
          verse.bookNumber,
          verse.chapter,
          verse.verseNumber,
        );
        return _VerseListItem(verse: verse, fontSize: fontSize, bookName: bookName, annotation: annotation);
      }, childCount: chapter.verses.length),
    );
  }
}

class _VerseListItem extends StatelessWidget {
  final BibleVerse verse;
  final VerseFontSize fontSize;
  final String bookName;
  final VerseAnnotation? annotation;

  const _VerseListItem({
    required this.verse,
    required this.fontSize,
    required this.bookName,
    required this.annotation,
  });

  @override
  Widget build(BuildContext context) {
    final highlight = annotation?.highlightColor;
    final hasComment = annotation?.hasComment ?? false;

    return GestureDetector(
      onTap: () =>
          VerseAnnotationBottomSheet.show(context, verse: verse, bookName: bookName, existing: annotation),
      child: Container(
        margin: const EdgeInsets.only(bottom: Spacing.xs6),
        decoration: highlight != null
            ? BoxDecoration(
                color: highlight.color,
                borderRadius: BorderRadius.circular(AppRadius.xs1),
                border: Border(left: BorderSide(color: highlight.borderColor, width: 3)),
              )
            : null,
        padding: highlight != null
            ? const EdgeInsets.symmetric(horizontal: Spacing.xs6, vertical: Spacing.xs3)
            : EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.top,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: Text(
                        '${verse.verseNumber}',
                        style: TextStyle(
                          fontSize: fontSize.verseNumberSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          height: 1.85,
                        ),
                      ),
                    ),
                  ),
                  TextSpan(
                    text: verse.text,
                    style: TextStyle(
                      fontSize: fontSize.verseBodySize,
                      color: AppColors.darkText90,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
            if (hasComment) ...[
              const SizedBox(height: Spacing.xs2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 12,
                      color: highlight != null ? highlight.borderColor : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs2),
                  Expanded(
                    child: AppTypographyMD(
                      annotation!.comment!,
                      textStyleTheme: TextStyleTheme.bodySmall,
                      color: highlight != null ? highlight.borderColor : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Bible style mode ──────────────────────────────────────────────────────

/// All verses flow as a single continuous block of text.
class _VerseBibleStyleSliver extends StatelessWidget {
  final BibleChapter chapter;
  final VerseFontSize fontSize;
  final String bookName;
  final AnnotationViewModel annotationVm;

  const _VerseBibleStyleSliver({
    required this.chapter,
    required this.fontSize,
    required this.bookName,
    required this.annotationVm,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: _ContinuousChapterText(
        chapter: chapter,
        fontSize: fontSize,
        bookName: bookName,
        annotationVm: annotationVm,
      ),
    );
  }
}

/// Stateful so TapGestureRecognizers are properly disposed.
class _ContinuousChapterText extends StatefulWidget {
  final BibleChapter chapter;
  final VerseFontSize fontSize;
  final String bookName;
  final AnnotationViewModel annotationVm;

  const _ContinuousChapterText({
    required this.chapter,
    required this.fontSize,
    required this.bookName,
    required this.annotationVm,
  });

  @override
  State<_ContinuousChapterText> createState() => _ContinuousChapterTextState();
}

class _ContinuousChapterTextState extends State<_ContinuousChapterText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dispose old recognizers before rebuilding.
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final spans = <InlineSpan>[];

    for (final verse in widget.chapter.verses) {
      final annotation = widget.annotationVm.annotationForVerse(
        verse.bookNumber,
        verse.chapter,
        verse.verseNumber,
      );
      final highlight = annotation?.highlightColor;

      // Create a recognizer per verse — tap opens the annotation sheet.
      final recognizer = TapGestureRecognizer()
        ..onTap = () => VerseAnnotationBottomSheet.show(
          context,
          verse: verse,
          bookName: widget.bookName,
          existing: annotation,
        );
      _recognizers.add(recognizer);

      // Verse number superscript — pure TextSpan, no WidgetSpan.
      spans.add(
        TextSpan(
          text: '${verse.verseNumber}',
          recognizer: recognizer,
          style: TextStyle(
            fontSize: widget.fontSize.verseNumberSize,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            height: 1.85,
          ),
        ),
      );

      // Comment indicator — shown only when the verse has a comment.
      if (annotation?.hasComment == true) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.top,
            child: GestureDetector(
              onTap: recognizer.onTap,
              child: Padding(
                padding: const EdgeInsets.only(left: 1),
                child: Icon(
                  Icons.edit_outlined,
                  size: widget.fontSize.verseNumberSize + 1,
                  color: AppColors.primary.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
        );
      }

      // Verse body — backgroundColor applies the highlight without breaking flow.
      spans.add(
        TextSpan(
          text: ' ${verse.text} ',
          recognizer: recognizer,
          style: TextStyle(
            fontSize: widget.fontSize.verseBodySize,
            color: AppColors.darkText90,
            height: 1.7,
            backgroundColor: highlight?.color,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }
}

// ── Navigation bar ─────────────────────────────────────────────────────────

class _NavigationBar extends StatelessWidget {
  final HomeViewModel vm;

  const _NavigationBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    final isFirst = vm.selectedBookIndex == 0 && vm.selectedChapterIndex == 0;
    final isLast =
        vm.selectedBookIndex == vm.books.length - 1 && vm.selectedChapterIndex == vm.totalChapters - 1;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundLight.withValues(alpha: 0),
            AppColors.backgroundLight.withValues(alpha: 0.95),
            AppColors.backgroundLight,
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        Spacing.xxs3,
        Spacing.xxs3,
        Spacing.xxs3,
        MediaQuery.of(context).padding.bottom + Spacing.xs6,
      ),
      child: Row(
        children: [
          _NavButton(
            icon: Icons.chevron_left_rounded,
            label: 'Anterior',
            onTap: isFirst ? null : vm.previousChapter,
          ),
          const SizedBox(width: Spacing.xs4),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (vm.books.isEmpty) return;
                _openBookSelector(context, vm);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: Spacing.xs5),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xs1),
                  boxShadow: [
                    BoxShadow(color: AppColors.darkText10, blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTypography(
                      vm.currentBook?.name ?? '',
                      textStyleTheme: TextStyleTheme.labelMedium,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText60,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                    AppTypography(
                      'Capítulo ${vm.selectedChapterIndex + 1}',
                      textStyleTheme: TextStyleTheme.bodyMedium,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: Spacing.xs4),
          _NavButton(
            icon: Icons.chevron_right_rounded,
            label: 'Próximo',
            onTap: isLast ? null : vm.nextChapter,
            iconOnRight: true,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool iconOnRight;

  const _NavButton({required this.icon, required this.label, required this.onTap, this.iconOnRight = false});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = enabled ? AppColors.primaryTextButton : AppColors.darkText30;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xs6, vertical: Spacing.xs5),
        decoration: BoxDecoration(
          color: enabled ? AppColors.primaryBackgroundButton : AppColors.darkText05,
          borderRadius: BorderRadius.circular(AppRadius.xs1),
          boxShadow: enabled
              ? [BoxShadow(color: AppColors.darkText10, blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!iconOnRight) Icon(icon, color: color, size: 20),
            AppTypography(
              label,
              textStyleTheme: TextStyleTheme.labelLarge,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            if (iconOnRight) Icon(icon, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
