import 'dart:convert';

import 'package:logos_app/data/services/annotation/annotation_service.dart';
import 'package:logos_app/domain/annotation/annotation_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists verse annotations and chapter notes as JSON in SharedPreferences.
///
/// Key scheme:
///   verse_annotation_{bookNumber}_{chapter}_{verseNumber}  → VerseAnnotation JSON
///   chapter_note_{bookNumber}_{chapter}                    → ChapterNote JSON
class AnnotationServiceImpl implements AnnotationService {
  static const _versePrefix = 'verse_annotation_';
  static const _chapterPrefix = 'chapter_note_';

  // Lazy-loaded SharedPreferences instance.
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _storage async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ── Verse annotations ─────────────────────────────────────────────────────

  @override
  Future<Map<String, VerseAnnotation>> getVerseAnnotationsForChapter(int bookNumber, int chapter) async {
    final prefs = await _storage;
    final prefix = '$_versePrefix${bookNumber}_${chapter}_';
    final keys = prefs.getKeys().where((k) => k.startsWith(prefix));

    final result = <String, VerseAnnotation>{};
    for (final key in keys) {
      final raw = prefs.getString(key);
      if (raw == null) continue;
      try {
        final annotation = VerseAnnotation.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        result[annotation.id] = annotation;
      } catch (_) {
        // Corrupt entry — skip silently.
      }
    }
    return result;
  }

  @override
  Future<void> saveVerseAnnotation(VerseAnnotation annotation) async {
    final prefs = await _storage;
    final key = '$_versePrefix${annotation.id}';
    await prefs.setString(key, jsonEncode(annotation.toJson()));
  }

  @override
  Future<void> deleteVerseAnnotation(String annotationId) async {
    final prefs = await _storage;
    await prefs.remove('$_versePrefix$annotationId');
  }

  // ── Chapter notes ─────────────────────────────────────────────────────────

  @override
  Future<ChapterNote?> getChapterNote(int bookNumber, int chapter) async {
    final prefs = await _storage;
    final key = '$_chapterPrefix${bookNumber}_$chapter';
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      return ChapterNote.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveChapterNote(ChapterNote note) async {
    final prefs = await _storage;
    final key = '$_chapterPrefix${note.id}';
    await prefs.setString(key, jsonEncode(note.toJson()));
  }

  @override
  Future<void> deleteChapterNote(String noteId) async {
    final prefs = await _storage;
    await prefs.remove('$_chapterPrefix$noteId');
  }
}
