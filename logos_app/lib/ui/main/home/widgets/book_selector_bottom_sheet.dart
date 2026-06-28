import 'package:flutter/material.dart';
import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/app_radius.dart';
import 'package:logos_app/core/design_tokens/font_size.dart';
import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/domain/bible/bible_models.dart';
import 'package:logos_app/ui/widgets/app_typography.dart';

/// Bottom sheet for selecting book + chapter.
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
  late int _selectedBookIndex;

  @override
  void initState() {
    super.initState();
    _selectedBookIndex = widget.currentBookIndex;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final book = widget.books[_selectedBookIndex];

    return Container(
      height: screenHeight * 0.75,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.screenHorizontal, vertical: Spacing.xs6),
            child: AppTypography(
              'Selecionar livro',
              textStyleTheme: TextStyleTheme.titleMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(height: 1, color: AppColors.darkText10),
          Expanded(
            child: Row(
              children: [
                // Book list (left)
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    itemCount: widget.books.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedBookIndex;
                      return InkWell(
                        onTap: () => setState(() => _selectedBookIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: Spacing.xs8, vertical: Spacing.xs5),
                          color: isSelected ? AppColors.primaryBackgroundButton : Colors.transparent,
                          child: AppTypography(
                            widget.books[index].name,
                            textStyleTheme: TextStyleTheme.bodyMedium,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppColors.primaryTextButton : AppColors.darkText,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const VerticalDivider(width: 1, color: AppColors.darkText10),
                // Chapter grid (right)
                Expanded(
                  flex: 2,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(Spacing.xs4),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: Spacing.xs2,
                      mainAxisSpacing: Spacing.xs2,
                      childAspectRatio: 1,
                    ),
                    itemCount: book.totalChapters,
                    itemBuilder: (context, chapIndex) {
                      final isCurrentChap =
                          _selectedBookIndex == widget.currentBookIndex &&
                          chapIndex == widget.currentChapterIndex;
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          widget.onSelect(_selectedBookIndex, chapIndex);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCurrentChap ? AppColors.primary : AppColors.darkText05,
                            borderRadius: BorderRadius.circular(AppRadius.xs1),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${chapIndex + 1}',
                            style: TextStyle(
                              fontSize: FontSize.bodySmall,
                              fontWeight: isCurrentChap ? FontWeight.w700 : FontWeight.w400,
                              color: isCurrentChap ? AppColors.whiteText : AppColors.darkText,
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
