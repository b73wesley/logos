import 'package:logos_app/data/services/bible/bible_service.dart';
import 'package:logos_app/domain/bible/bible_models.dart';
import 'package:logos_app/domain/bible/bible_repository.dart';

class BibleRepositoryImpl implements BibleRepository {
  final BibleService _service;

  // In-memory cache per translation — avoids re-parsing 5MB JSON on every call.
  final Map<BibleTranslation, List<BibleBook>> _cache = {};

  BibleRepositoryImpl(this._service);

  @override
  Future<List<BibleBook>> loadBooks(BibleTranslation translation) async {
    if (_cache.containsKey(translation)) return _cache[translation]!;
    final books = await _service.parseTranslation(translation);
    _cache[translation] = books;
    return books;
  }

  @override
  Future<BibleBook?> getBook(BibleTranslation translation, int bookNumber) async {
    final books = await loadBooks(translation);
    try {
      return books.firstWhere((b) => b.number == bookNumber);
    } catch (_) {
      return null;
    }
  }
}
