import 'package:logos_app/domain/annotation/annotation_models.dart';

abstract interface class AnnotationRepository {
  // ── Verse annotations ─────────────────────────────────────────────────────

  /// Returns all verse annotations for a given chapter.
  Future<Map<String, VerseAnnotation>> getVerseAnnotationsForChapter(int bookNumber, int chapter);

  /// Saves (creates or updates) a verse annotation. If [annotation.isEmpty],
  /// the annotation is deleted instead.
  Future<void> saveVerseAnnotation(VerseAnnotation annotation);

  /// Deletes a verse annotation by its id.
  Future<void> deleteVerseAnnotation(String annotationId);

  // ── Chapter notes ─────────────────────────────────────────────────────────

  /// Returns the note for a specific chapter, or null if none exists.
  Future<ChapterNote?> getChapterNote(int bookNumber, int chapter);

  /// Saves (creates or updates) a chapter note. If [note] is empty, deletes it.
  Future<void> saveChapterNote(int bookNumber, int chapter, String note);

  /// Deletes the chapter note.
  Future<void> deleteChapterNote(String noteId);
}
