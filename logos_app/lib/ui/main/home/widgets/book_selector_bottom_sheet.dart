import 'package:flutter/material.dart';
import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/app_radius.dart';
import 'package:logos_app/core/design_tokens/font_size.dart';
import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/domain/bible/bible_models.dart';
import 'package:logos_app/ui/widgets/app_font.dart';
import 'package:logos_app/ui/widgets/app_typography.dart';

/// Expandable book/chapter selector.
///
/// Shows a searchable list of books. Tapping a book expands it inline to
/// reveal a chapter grid. Tapping a chapter number confirms the selection.
///
/// [onSelect] receives (bookIndex, chapterIndex).
class BookSelectorBottomSheet extends StatefulWidget {
  final List<BibleBook> books;
  final int currentBookIndex;
  final int currentChapterIndex;
  final void Function(int bookIndex, int chapterIndex) onSelect;

  const BookSelectorBottomSheet({
    super.key,
    required this.books,
    required this.currentBookIndex,
    required this.currentChapterIndex,
    required this.onSelect,
  });

  static Future<void> show(
    BuildContext context, {
    required List<BibleBook> books,
    required int currentBookIndex,
    required int currentChapterIndex,
    required void Function(int bookIndex, int chapterIndex) onSelect,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookSelectorBottomSheet(
        books: books,
        currentBookIndex: currentBookIndex,
        currentChapterIndex: currentChapterIndex,
        onSelect: onSelect,
      ),
    );
  }

  @override
  State<BookSelectorBottomSheet> createState() => _BookSelectorBottomSheetState();
}

class _BookSelectorBottomSheetState extends State<BookSelectorBottomSheet> {
  // Index of the currently expanded book (-1 = none).
  late int _expandedIndex;

  late final TextEditingController _searchController;
  late final ScrollController _listController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Start with current book expanded.
    _expandedIndex = widget.currentBookIndex;
    _searchController = TextEditingController();
    _listController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToExpanded());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<({BibleBook book, int originalIndex})> get _filteredBooks {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return widget.books.indexed.map((e) => (book: e.$2, originalIndex: e.$1)).toList();
    }
    return widget.books.indexed
        .where((e) => e.$2.name.toLowerCase().contains(q))
        .map((e) => (book: e.$2, originalIndex: e.$1))
        .toList();
  }

  void _scrollToExpanded() {
    if (!_listController.hasClients) return;
    final filtered = _filteredBooks;
    final idx = filtered.indexWhere((e) => e.originalIndex == _expandedIndex);
    if (idx < 0) return;
    // Approximate row height — book row is ~48px, chapter grid varies.
    // Scroll so the expanded book is near the top with some breathing room.
    const approxRowHeight = 48.0;
    final offset = (idx * approxRowHeight - 60).clamp(0.0, double.infinity);
    _listController.animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _confirm(int bookIndex, int chapterIndex) {
    Navigator.pop(context);
    widget.onSelect(bookIndex, chapterIndex);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final filtered = _filteredBooks;

    return Container(
      height: screenHeight * 0.82,
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xs9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Handle ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: Spacing.xs6),
            child: Center(
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

          // ── Title + search ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.screenHorizontal,
              Spacing.xs6,
              Spacing.screenHorizontal,
              Spacing.xs4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTypography(
                  'Selecionar',
                  textStyleTheme: TextStyleTheme.titleMedium,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: Spacing.xs6),
                _SearchField(
                  controller: _searchController,
                  query: _query,
                  onChanged: (v) {
                    setState(() {
                      _query = v;
                      // When filtering, expand the first match automatically.
                      if (v.isNotEmpty) {
                        final results = _filteredBooks;
                        if (results.isNotEmpty) {
                          _expandedIndex = results.first.originalIndex;
                        }
                      }
                    });
                  },
                  onClear: () {
                    _searchController.clear();
                    setState(() => _query = '');
                    _scrollToExpanded();
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.darkText10),

          // ── List ───────────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: AppTypography(
                      'Nenhum livro encontrado',
                      textStyleTheme: TextStyleTheme.bodyMedium,
                      color: AppColors.darkText40,
                    ),
                  )
                : ListView.builder(
                    controller: _listController,
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final entry = filtered[i];
                      final isExpanded = entry.originalIndex == _expandedIndex;
                      final isCurrentBook = entry.originalIndex == widget.currentBookIndex;

                      return _BookRow(
                        book: entry.book,
                        bookIndex: entry.originalIndex,
                        isExpanded: isExpanded,
                        isCurrentBook: isCurrentBook,
                        currentChapterIndex: widget.currentChapterIndex,
                        query: _query,
                        onBookTap: () {
                          setState(() {
                            _expandedIndex = isExpanded ? -1 : entry.originalIndex;
                          });
                        },
                        onChapterTap: (chapIdx) => _confirm(entry.originalIndex, chapIdx),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Book row with expandable chapter grid ──────────────────────────────────

class _BookRow extends StatelessWidget {
  final BibleBook book;
  final int bookIndex;
  final bool isExpanded;
  final bool isCurrentBook;
  final int currentChapterIndex;
  final String query;
  final VoidCallback onBookTap;
  final void Function(int chapterIndex) onChapterTap;

  const _BookRow({
    required this.book,
    required this.bookIndex,
    required this.isExpanded,
    required this.isCurrentBook,
    required this.currentChapterIndex,
    required this.query,
    required this.onBookTap,
    required this.onChapterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Book header row ───────────────────────────────────────────────
        InkWell(
          onTap: onBookTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.screenHorizontal, vertical: Spacing.xs5),
            color: isExpanded ? AppColors.primaryBackgroundButton : Colors.transparent,
            child: Row(
              children: [
                Expanded(
                  child: query.isEmpty
                      ? AppTypography(
                          book.name,
                          textStyleTheme: TextStyleTheme.bodyMedium,
                          fontWeight: isExpanded || isCurrentBook ? FontWeight.w600 : FontWeight.w400,
                          color: isExpanded
                              ? AppColors.primaryTextButton
                              : isCurrentBook
                              ? AppColors.primary
                              : AppColors.darkText,
                        )
                      : _HighlightedText(text: book.name, query: query, isSelected: isExpanded),
                ),
                Icon(
                  isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 18,
                  color: isExpanded ? AppColors.primaryTextButton : AppColors.darkText40,
                ),
              ],
            ),
          ),
        ),

        // ── Chapter grid (animated expand/collapse) ───────────────────────
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: _ChapterGrid(
            book: book,
            bookIndex: bookIndex,
            isCurrentBook: isCurrentBook,
            currentChapterIndex: currentChapterIndex,
            onChapterTap: onChapterTap,
          ),
          secondChild: const SizedBox.shrink(),
        ),

        const Divider(height: 1, color: AppColors.darkText05),
      ],
    );
  }
}

// ── Chapter grid ───────────────────────────────────────────────────────────

class _ChapterGrid extends StatelessWidget {
  final BibleBook book;
  final int bookIndex;
  final bool isCurrentBook;
  final int currentChapterIndex;
  final void Function(int chapterIndex) onChapterTap;

  const _ChapterGrid({
    required this.book,
    required this.bookIndex,
    required this.isCurrentBook,
    required this.currentChapterIndex,
    required this.onChapterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.screenHorizontal,
        Spacing.xs3,
        Spacing.screenHorizontal,
        Spacing.xs6,
      ),
      child: Wrap(
        spacing: Spacing.xs3,
        runSpacing: Spacing.xs3,
        children: List.generate(book.totalChapters, (ci) {
          final chapNum = ci + 1;
          final isCurrent = isCurrentBook && ci == currentChapterIndex;
          return GestureDetector(
            onTap: () => onChapterTap(ci),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCurrent ? AppColors.primary : AppColors.darkText05,
                borderRadius: BorderRadius.circular(AppRadius.xs1),
              ),
              alignment: Alignment.center,
              child: Text(
                '$chapNum',
                style: TextStyle(
                  fontFamily: AppFont().font.fontFamily,
                  fontSize: FontSize.bodySmall,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent ? AppColors.whiteText : AppColors.darkText70,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Search field ───────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: false,
      textInputAction: TextInputAction.search,
      style: TextStyle(
        fontFamily: AppFont().font.fontFamily,
        fontSize: FontSize.bodyMedium,
        color: AppColors.darkText,
      ),
      decoration: InputDecoration(
        hintText: 'Buscar livro...',
        hintStyle: TextStyle(
          fontFamily: AppFont().font.fontFamily,
          fontSize: FontSize.bodyMedium,
          color: AppColors.darkText40,
        ),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.darkText40, size: 20),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.darkText40),
                onPressed: onClear,
              )
            : null,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.xs8, vertical: Spacing.xs5),
        filled: true,
        fillColor: AppColors.darkText05,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs2),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs2),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs2),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

// ── Highlighted text ───────────────────────────────────────────────────────

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final bool isSelected;

  const _HighlightedText({required this.text, required this.query, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final q = query.toLowerCase();
    final lower = text.toLowerCase();
    final start = lower.indexOf(q);

    if (start < 0) {
      return Text(
        text,
        style: TextStyle(
          fontFamily: AppFont().font.fontFamily,
          fontSize: FontSize.bodyMedium,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppColors.primaryTextButton : AppColors.darkText,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final end = start + q.length;
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: TextStyle(
          fontFamily: AppFont().font.fontFamily,
          fontSize: FontSize.bodyMedium,
          color: isSelected ? AppColors.primaryTextButton : AppColors.darkText,
        ),
        children: [
          if (start > 0)
            TextSpan(
              text: text.substring(0, start),
              style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400),
            ),
          TextSpan(
            text: text.substring(start, end),
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
          if (end < text.length)
            TextSpan(
              text: text.substring(end),
              style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400),
            ),
        ],
      ),
    );
  }
}
