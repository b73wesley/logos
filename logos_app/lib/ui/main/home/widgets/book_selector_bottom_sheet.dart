import 'package:flutter/material.dart';
import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/app_radius.dart';
import 'package:logos_app/core/design_tokens/font_size.dart';
import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/domain/bible/bible_models.dart';
import 'package:logos_app/ui/widgets/app_font.dart';
import 'package:logos_app/ui/widgets/app_typography.dart';

/// Three-column navigator: Book → Chapter → Verse.
///
/// [onSelect] receives the chosen (bookIndex, chapterIndex, verseNumber).
/// [verseNumber] is 1-based; null means "go to start of chapter".
class BookSelectorBottomSheet extends StatefulWidget {
  final List<BibleBook> books;
  final int currentBookIndex;
  final int currentChapterIndex;
  final int? currentVerseNumber;
  final void Function(int bookIndex, int chapterIndex, int? verseNumber) onSelect;

  const BookSelectorBottomSheet({
    super.key,
    required this.books,
    required this.currentBookIndex,
    required this.currentChapterIndex,
    this.currentVerseNumber,
    required this.onSelect,
  });

  static Future<void> show(
    BuildContext context, {
    required List<BibleBook> books,
    required int currentBookIndex,
    required int currentChapterIndex,
    int? currentVerseNumber,
    required void Function(int bookIndex, int chapterIndex, int? verseNumber) onSelect,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookSelectorBottomSheet(
        books: books,
        currentBookIndex: currentBookIndex,
        currentChapterIndex: currentChapterIndex,
        currentVerseNumber: currentVerseNumber,
        onSelect: onSelect,
      ),
    );
  }

  @override
  State<BookSelectorBottomSheet> createState() => _BookSelectorBottomSheetState();
}

class _BookSelectorBottomSheetState extends State<BookSelectorBottomSheet> {
  late int _bookIndex;
  // null = no chapter selected yet (verse column hidden)
  int? _chapIndex;

  late final TextEditingController _searchController;
  late final ScrollController _bookListController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _bookIndex = widget.currentBookIndex;
    // Start with the current chapter already selected so verse column is visible.
    _chapIndex = widget.currentChapterIndex;
    _searchController = TextEditingController();
    _bookListController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBook());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bookListController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Parsed reference from the search field.
  /// Format: "Book", "Book, chapter", "Book, chapter, verse"
  /// Parts are separated by comma or colon.
  _ParsedRef? get _parsedRef {
    final raw = _query.trim();
    if (raw.isEmpty) return null;

    // Split on commas, colons, or semicolons.
    final parts = raw.split(RegExp(r'[,;:]')).map((p) => p.trim()).toList();

    // First part is the book name (may be partial).
    final bookQuery = parts[0].toLowerCase();
    if (bookQuery.isEmpty) return null;

    final bookMatch = widget.books.indexed
        .where((e) => e.$2.name.toLowerCase().startsWith(bookQuery))
        .toList();

    if (bookMatch.isEmpty) return null;

    final bookIdx = bookMatch.first.$1;
    final book = bookMatch.first.$2;

    // Second part: chapter (1-based input → 0-based index).
    int? chapIdx;
    if (parts.length >= 2) {
      final chapNum = int.tryParse(parts[1]);
      if (chapNum != null && chapNum >= 1 && chapNum <= book.totalChapters) {
        chapIdx = chapNum - 1;
      }
    }

    // Third part: verse (1-based).
    int? verseNum;
    if (chapIdx != null && parts.length >= 3) {
      final vNum = int.tryParse(parts[2]);
      final totalVerses = book.chapters[chapIdx].verses.length;
      if (vNum != null && vNum >= 1 && vNum <= totalVerses) {
        verseNum = vNum;
      }
    }

    return _ParsedRef(bookIndex: bookIdx, chapIndex: chapIdx, verseNumber: verseNum);
  }

  List<({BibleBook book, int originalIndex})> get _filteredBooks {
    final ref = _parsedRef;
    if (ref != null) {
      // Show only the matched book when a structured reference is typed.
      return [(book: widget.books[ref.bookIndex], originalIndex: ref.bookIndex)];
    }
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return widget.books.indexed.map((e) => (book: e.$2, originalIndex: e.$1)).toList();
    }
    return widget.books.indexed
        .where((e) => e.$2.name.toLowerCase().contains(q))
        .map((e) => (book: e.$2, originalIndex: e.$1))
        .toList();
  }

  BibleBook get _selectedBook => widget.books[_bookIndex];

  int get _totalVerses {
    final ci = _chapIndex;
    if (ci == null || ci >= _selectedBook.chapters.length) return 0;
    return _selectedBook.chapters[ci].verses.length;
  }

  void _scrollToBook() {
    if (!_bookListController.hasClients) return;
    final idx = _filteredBooks.indexWhere((e) => e.originalIndex == _bookIndex);
    if (idx < 0) return;
    const rowHeight = 36.0;
    final offset = (idx * rowHeight - 80).clamp(0.0, double.infinity);
    _bookListController.animateTo(offset, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  void _confirm(int? verseNumber) {
    Navigator.pop(context);
    widget.onSelect(_bookIndex, _chapIndex ?? 0, verseNumber);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final filtered = _filteredBooks;

    // Keep selected book in sync with filtered list.
    final bookEntry = filtered.any((e) => e.originalIndex == _bookIndex)
        ? filtered.firstWhere((e) => e.originalIndex == _bookIndex)
        : filtered.isNotEmpty
        ? filtered.first
        : null;

    return Container(
      height: screenHeight * 0.82,
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xs9)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: Spacing.xs6),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.darkText20, borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // Title + search
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
                      // Sync columns with parsed reference — but never auto-confirm.
                      // The user taps the banner to confirm when ready.
                      final ref = _parsedRef;
                      if (ref != null) {
                        _bookIndex = ref.bookIndex;
                        _chapIndex = ref.chapIndex;
                      } else {
                        final results = _filteredBooks;
                        if (results.isNotEmpty && !results.any((e) => e.originalIndex == _bookIndex)) {
                          _bookIndex = results.first.originalIndex;
                          _chapIndex = null;
                        }
                      }
                    });
                  },
                  onClear: () {
                    _searchController.clear();
                    setState(() => _query = '');
                    _scrollToBook();
                  },
                ),

                // Quick-confirm banner — appears when ref has book + chapter resolved.
                Builder(
                  builder: (ctx) {
                    final ref = _parsedRef;
                    if (ref == null || ref.chapIndex == null) return const SizedBox.shrink();
                    final book = widget.books[ref.bookIndex];
                    final chapNum = ref.chapIndex! + 1;
                    final verseLabel = ref.verseNumber != null ? ':${ref.verseNumber}' : '';
                    final hasVerse = ref.verseNumber != null;
                    return Padding(
                      padding: const EdgeInsets.only(top: Spacing.xs4),
                      child: GestureDetector(
                        onTap: () => _confirm(ref.verseNumber),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: Spacing.xs8, vertical: Spacing.xs5),
                          decoration: BoxDecoration(
                            color: hasVerse ? AppColors.primary : AppColors.primaryBackgroundButton,
                            borderRadius: BorderRadius.circular(AppRadius.xs1),
                            border: Border.all(color: hasVerse ? AppColors.primary : AppColors.primary30),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: hasVerse ? AppColors.whiteText : AppColors.primary,
                              ),
                              const SizedBox(width: Spacing.xs3),
                              Expanded(
                                child: AppTypography(
                                  'Ir para ${book.name} $chapNum$verseLabel',
                                  textStyleTheme: TextStyleTheme.bodyMedium,
                                  fontWeight: FontWeight.w600,
                                  color: hasVerse ? AppColors.whiteText : AppColors.primaryTextButton,
                                ),
                              ),
                              Icon(
                                Icons.touch_app_rounded,
                                size: 16,
                                color: hasVerse
                                    ? AppColors.whiteText.withValues(alpha: 0.7)
                                    : AppColors.primary.withValues(alpha: 0.6),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Column headers
          const Divider(height: 1, color: AppColors.darkText10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.xs2, vertical: Spacing.xs2),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: AppTypography(
                    'Livro',
                    textStyleTheme: TextStyleTheme.labelMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText40,
                  ),
                ),
                const SizedBox(width: 1),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: AppTypography(
                      'Capítulo',
                      textStyleTheme: TextStyleTheme.labelMedium,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText40,
                    ),
                  ),
                ),
                const SizedBox(width: 1),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: AppTypography(
                      'Versículo',
                      textStyleTheme: TextStyleTheme.labelMedium,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText40,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.darkText10),

          // 3-column body
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: AppTypography(
                      'Nenhum livro encontrado',
                      textStyleTheme: TextStyleTheme.bodyMedium,
                      color: AppColors.darkText40,
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Column 1: Books ──────────────────────────────────
                      Expanded(
                        flex: 5,
                        child: ListView.builder(
                          controller: _bookListController,
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final entry = filtered[i];
                            final isSelected = entry.originalIndex == _bookIndex;
                            return InkWell(
                              onTap: () {
                                if (entry.originalIndex == _bookIndex) {
                                  // Tap on already-selected book → confirm book + ch1
                                  _chapIndex = 0;
                                  _confirm(null);
                                } else {
                                  setState(() {
                                    _bookIndex = entry.originalIndex;
                                    _chapIndex = null;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.xs8,
                                  vertical: Spacing.xs5,
                                ),
                                color: isSelected ? AppColors.primaryBackgroundButton : Colors.transparent,
                                child: _query.isEmpty
                                    ? AppTypography(
                                        entry.book.name,
                                        textStyleTheme: TextStyleTheme.bodyMedium,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        color: isSelected ? AppColors.primaryTextButton : AppColors.darkText,
                                        maxLines: 1,
                                        textOverflow: TextOverflow.ellipsis,
                                      )
                                    : _HighlightedText(
                                        text: entry.book.name,
                                        query: _query,
                                        isSelected: isSelected,
                                      ),
                              ),
                            );
                          },
                        ),
                      ),

                      const VerticalDivider(width: 1, color: AppColors.darkText10),

                      // ── Column 2: Chapters ───────────────────────────────
                      Expanded(
                        flex: 3,
                        child: bookEntry == null
                            ? const SizedBox.shrink()
                            : ListView.builder(
                                itemCount: bookEntry.book.totalChapters,
                                itemBuilder: (context, ci) {
                                  final isSelected = ci == _chapIndex;
                                  final isCurrent =
                                      bookEntry.originalIndex == widget.currentBookIndex &&
                                      ci == widget.currentChapterIndex;
                                  return InkWell(
                                    onTap: () {
                                      if (ci == _chapIndex) {
                                        // Tap same chapter → confirm, no verse
                                        _confirm(null);
                                      } else {
                                        setState(() => _chapIndex = ci);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: Spacing.xs5),
                                      color: isSelected
                                          ? AppColors.primaryBackgroundButton
                                          : Colors.transparent,
                                      child: Center(
                                        child: Text(
                                          '${ci + 1}',
                                          style: TextStyle(
                                            fontFamily: AppFont().font.fontFamily,
                                            fontSize: FontSize.bodyMedium,
                                            fontWeight: isSelected || isCurrent
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                            color: isCurrent && !isSelected
                                                ? AppColors.primary
                                                : isSelected
                                                ? AppColors.primaryTextButton
                                                : AppColors.darkText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      const VerticalDivider(width: 1, color: AppColors.darkText10),

                      // ── Column 3: Verses ─────────────────────────────────
                      Expanded(
                        flex: 3,
                        child: _chapIndex == null
                            ? Center(
                                child: AppTypography(
                                  '←',
                                  textStyleTheme: TextStyleTheme.titleLarge,
                                  color: AppColors.darkText20,
                                ),
                              )
                            : ListView.builder(
                                itemCount: _totalVerses,
                                itemBuilder: (context, vi) {
                                  final verseNumber = vi + 1;
                                  final isCurrent =
                                      _bookIndex == widget.currentBookIndex &&
                                      _chapIndex == widget.currentChapterIndex &&
                                      verseNumber == widget.currentVerseNumber;
                                  return InkWell(
                                    onTap: () => _confirm(verseNumber),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: Spacing.xs5),
                                      color: isCurrent
                                          ? AppColors.primaryBackgroundButton
                                          : Colors.transparent,
                                      child: Center(
                                        child: Text(
                                          '$verseNumber',
                                          style: TextStyle(
                                            fontFamily: AppFont().font.fontFamily,
                                            fontSize: FontSize.bodyMedium,
                                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                                            color: isCurrent
                                                ? AppColors.primaryTextButton
                                                : AppColors.darkText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          ),
        ],
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

// ── Parsed reference ───────────────────────────────────────────────────────

/// Result of parsing a free-text Bible reference such as "Romans, 1, 1".
class _ParsedRef {
  /// 0-based index into the [BibleBook] list.
  final int bookIndex;

  /// 0-based chapter index, or null if not yet specified.
  final int? chapIndex;

  /// 1-based verse number, or null if not yet specified.
  final int? verseNumber;

  const _ParsedRef({required this.bookIndex, this.chapIndex, this.verseNumber});
}
