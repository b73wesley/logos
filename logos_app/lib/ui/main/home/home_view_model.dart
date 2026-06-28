import 'package:flutter/material.dart';
import 'package:logos_app/core/preferences.dart';
import 'package:logos_app/domain/bible/bible_models.dart';
import 'package:logos_app/domain/bible/bible_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final BibleRepository _repository;
  final Preferences _prefs;

  HomeViewModel(this._repository, this._prefs) {
    _init();
  }

  // ── State ──────────────────────────────────────────────────────────────────

  bool isLoading = true;
  String? errorMessage;

  BibleTranslation selectedTranslation = BibleTranslation.kjv;

  List<BibleBook> books = [];
  int selectedBookIndex = 0;
  int selectedChapterIndex = 0;

  // PageController is created fresh whenever the book/translation changes so
  // the PageView resets to page 0.
  PageController pageController = PageController();

  // Verse display mode — persisted via SharedPreferences.
  late VerseDisplayMode verseDisplayMode;

  // Verse font size — persisted via SharedPreferences.
  late VerseFontSize verseFontSize;

  // ── Derived ───────────────────────────────────────────────────────────────

  BibleBook? get currentBook => books.isNotEmpty ? books[selectedBookIndex] : null;

  BibleChapter? get currentChapter {
    final book = currentBook;
    if (book == null || book.chapters.isEmpty) return null;
    return book.chapters[selectedChapterIndex];
  }

  int get totalChapters => currentBook?.totalChapters ?? 0;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> _init() async {
    verseDisplayMode = _prefs.verseDisplayMode;
    verseFontSize = _prefs.verseFontSize;
    await _loadTranslation();
  }

  Future<void> _loadTranslation() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      books = await _repository.loadBooks(selectedTranslation);
      selectedBookIndex = 0;
      _resetPageController();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void selectTranslation(BibleTranslation translation) {
    if (translation == selectedTranslation) return;
    selectedTranslation = translation;
    _loadTranslation();
  }

  void selectBook(int bookIndex) {
    if (bookIndex == selectedBookIndex) return;
    selectedBookIndex = bookIndex;
    selectedChapterIndex = 0;
    _resetPageController();
    notifyListeners();
  }

  void selectChapter(int chapterIndex) {
    if (chapterIndex < 0 || chapterIndex >= totalChapters) return;
    selectedChapterIndex = chapterIndex;
    pageController.jumpToPage(chapterIndex);
    notifyListeners();
  }

  void onPageChanged(int page) {
    selectedChapterIndex = page;
    notifyListeners();
  }

  void nextChapter() {
    if (selectedChapterIndex < totalChapters - 1) {
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      // Advance to next book, chapter 1
      if (selectedBookIndex < books.length - 1) {
        selectedBookIndex++;
        selectedChapterIndex = 0;
        _resetPageController();
        notifyListeners();
      }
    }
  }

  void previousChapter() {
    if (selectedChapterIndex > 0) {
      pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      // Go back to last chapter of previous book
      if (selectedBookIndex > 0) {
        selectedBookIndex--;
        selectedChapterIndex = currentBook!.totalChapters - 1;
        _resetPageController(initialPage: selectedChapterIndex);
        notifyListeners();
      }
    }
  }

  void _resetPageController({int initialPage = 0}) {
    pageController.dispose();
    pageController = PageController(initialPage: initialPage);
  }

  Future<void> setVerseDisplayMode(VerseDisplayMode mode) async {
    if (mode == verseDisplayMode) return;
    verseDisplayMode = mode;
    await _prefs.setVerseDisplayMode(mode);
    notifyListeners();
  }

  Future<void> setVerseFontSize(VerseFontSize size) async {
    if (size == verseFontSize) return;
    verseFontSize = size;
    await _prefs.setVerseFontSize(size);
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
