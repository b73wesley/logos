import 'package:flutter/material.dart';
import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/app_radius.dart';
import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/core/preferences.dart';
import 'package:logos_app/domain/bible/bible_models.dart';
import 'package:logos_app/ui/main/home/home_view_model.dart';
import 'package:logos_app/ui/main/home/widgets/book_selector_bottom_sheet.dart';
import 'package:logos_app/ui/main/home/widgets/reader_settings_bottom_sheet.dart';
import 'package:logos_app/ui/main/home/widgets/translation_selector_bottom_sheet.dart';
import 'package:logos_app/ui/widgets/app_empty_state_view.dart';
import 'package:logos_app/ui/widgets/app_typography.dart';
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
          onPageChanged: vm.onPageChanged,
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
                AppTypography(
                  '${chapter.chapterNumber}',
                  textStyleTheme: TextStyleTheme.headlineLarge,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.center,
                ),
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
              ? _VerseListSliver(chapter: chapter, fontSize: fontSize)
              : _VerseBibleStyleSliver(chapter: chapter, fontSize: fontSize),
        ),
      ],
    );
  }
}

// ── List mode ─────────────────────────────────────────────────────────────

/// One verse per row, with spacing between each.
class _VerseListSliver extends StatelessWidget {
  final BibleChapter chapter;
  final VerseFontSize fontSize;

  const _VerseListSliver({required this.chapter, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _VerseListItem(verse: chapter.verses[index], fontSize: fontSize),
        childCount: chapter.verses.length,
      ),
    );
  }
}

class _VerseListItem extends StatelessWidget {
  final BibleVerse verse;
  final VerseFontSize fontSize;

  const _VerseListItem({required this.verse, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xs6),
      child: RichText(
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
              style: TextStyle(fontSize: fontSize.verseBodySize, color: AppColors.darkText90, height: 1.7),
            ),
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

  const _VerseBibleStyleSliver({required this.chapter, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: _ContinuousChapterText(chapter: chapter, fontSize: fontSize),
    );
  }
}

class _ContinuousChapterText extends StatelessWidget {
  final BibleChapter chapter;
  final VerseFontSize fontSize;

  const _ContinuousChapterText({required this.chapter, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];

    for (final verse in chapter.verses) {
      // Verse number as inline superscript
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.top,
          child: Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Text(
              '${verse.verseNumber}',
              style: TextStyle(
                fontSize: fontSize.verseNumberSize,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                height: 1.85,
              ),
            ),
          ),
        ),
      );

      // Verse text — trailing space flows into the next verse number
      spans.add(
        TextSpan(
          text: '${verse.text} ',
          style: TextStyle(fontSize: fontSize.verseBodySize, color: AppColors.darkText90, height: 1.7),
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
