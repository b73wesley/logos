import 'package:flutter/material.dart';
import 'package:logos_app/domain/annotation/annotation_models.dart';
import 'package:logos_app/domain/annotation/annotation_repository.dart';

class AnnotationViewModel extends ChangeNotifier {
  final AnnotationRepository _repository;

  AnnotationViewModel(this._repository);

  // ── State ─────────────────────────────────────────────────────────────────

  // Annotations for the currently visible chapter, keyed by annotation id.
  Map<String, VerseAnnotation> _verseAnnotations = {};

  // Chapter note for the currently visible chapter.
  ChapterNote? _chapterNote;

  bool _isSaving = false;

  // ── Derived ───────────────────────────────────────────────────────────────

  bool get isSaving => _isSaving;

  ChapterNote? get chapterNote => _chapterNote;

  /// Returns the annotation for a specific verse, or null if none.
  VerseAnnotation? annotationForVerse(int bookNumber, int chapter, int verseNumber) {
    final id = VerseAnnotation.buildId(bookNumber, chapter, verseNumber);
    return _verseAnnotations[id];
  }

  bool chapterHasNote(int bookNumber, int chapter) => _chapterNote != null;

  // ── Load ──────────────────────────────────────────────────────────────────

  /// Call this whenever the reader navigates to a different chapter.
  Future<void> loadChapter(int bookNumber, int chapter) async {
    final results = await Future.wait([
      _repository.getVerseAnnotationsForChapter(bookNumber, chapter),
      _repository.getChapterNote(bookNumber, chapter),
    ]);
    _verseAnnotations = results[0] as Map<String, VerseAnnotation>;
    _chapterNote = results[1] as ChapterNote?;
    notifyListeners();
  }

  // ── Verse actions ─────────────────────────────────────────────────────────

  Future<void> saveVerseAnnotation({
    required int bookNumber,
    required int chapter,
    required int verseNumber,
    HighlightColor? highlightColor,
    required String comment,
    required bool removeHighlight,
  }) async {
    _isSaving = true;
    notifyListeners();

    final id = VerseAnnotation.buildId(bookNumber, chapter, verseNumber);
    final existing = _verseAnnotations[id];

    final updated = VerseAnnotation(
      id: id,
      bookNumber: bookNumber,
      chapter: chapter,
      verseNumber: verseNumber,
      highlightColor: removeHighlight ? null : (highlightColor ?? existing?.highlightColor),
      comment: comment.trim().isEmpty ? null : comment.trim(),
      updatedAt: DateTime.now(),
    );

    await _repository.saveVerseAnnotation(updated);

    if (updated.isEmpty) {
      _verseAnnotations.remove(id);
    } else {
      _verseAnnotations[id] = updated;
    }

    _isSaving = false;
    notifyListeners();
  }

  // ── Chapter note actions ──────────────────────────────────────────────────

  Future<void> saveChapterNote({required int bookNumber, required int chapter, required String note}) async {
    _isSaving = true;
    notifyListeners();

    await _repository.saveChapterNote(bookNumber, chapter, note);

    if (note.trim().isEmpty) {
      _chapterNote = null;
    } else {
      _chapterNote = ChapterNote(
        id: ChapterNote.buildId(bookNumber, chapter),
        bookNumber: bookNumber,
        chapter: chapter,
        note: note.trim(),
        updatedAt: DateTime.now(),
      );
    }

    _isSaving = false;
    notifyListeners();
  }
}
