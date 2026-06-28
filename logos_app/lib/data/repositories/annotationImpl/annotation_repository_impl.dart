import 'package:logos_app/data/services/annotation/annotation_service.dart';
import 'package:logos_app/domain/annotation/annotation_models.dart';
import 'package:logos_app/domain/annotation/annotation_repository.dart';

class AnnotationRepositoryImpl implements AnnotationRepository {
  final AnnotationService _service;

  AnnotationRepositoryImpl(this._service);

  @override
  Future<Map<String, VerseAnnotation>> getVerseAnnotationsForChapter(int bookNumber, int chapter) =>
      _service.getVerseAnnotationsForChapter(bookNumber, chapter);

  @override
  Future<void> saveVerseAnnotation(VerseAnnotation annotation) async {
    if (annotation.isEmpty) {
      await _service.deleteVerseAnnotation(annotation.id);
    } else {
      await _service.saveVerseAnnotation(annotation);
    }
  }

  @override
  Future<void> deleteVerseAnnotation(String annotationId) => _service.deleteVerseAnnotation(annotationId);

  @override
  Future<ChapterNote?> getChapterNote(int bookNumber, int chapter) =>
      _service.getChapterNote(bookNumber, chapter);

  @override
  Future<void> saveChapterNote(int bookNumber, int chapter, String note) async {
    if (note.trim().isEmpty) {
      await _service.deleteChapterNote(ChapterNote.buildId(bookNumber, chapter));
    } else {
      await _service.saveChapterNote(
        ChapterNote(
          id: ChapterNote.buildId(bookNumber, chapter),
          bookNumber: bookNumber,
          chapter: chapter,
          note: note.trim(),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<void> deleteChapterNote(String noteId) => _service.deleteChapterNote(noteId);
}
