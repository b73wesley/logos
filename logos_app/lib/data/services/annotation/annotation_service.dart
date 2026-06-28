import 'package:logos_app/domain/annotation/annotation_models.dart';

abstract interface class AnnotationService {
  Future<Map<String, VerseAnnotation>> getVerseAnnotationsForChapter(int bookNumber, int chapter);

  Future<void> saveVerseAnnotation(VerseAnnotation annotation);

  Future<void> deleteVerseAnnotation(String annotationId);

  Future<ChapterNote?> getChapterNote(int bookNumber, int chapter);

  Future<void> saveChapterNote(ChapterNote note);

  Future<void> deleteChapterNote(String noteId);
}
