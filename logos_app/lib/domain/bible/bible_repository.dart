import 'package:logos_app/domain/bible/bible_models.dart';

abstract class BibleRepository {
  /// Loads all books of a given [translation]. Expensive — cache the result.
  Future<List<BibleBook>> loadBooks(BibleTranslation translation);

  /// Returns a specific book by [bookNumber] within the loaded translation.
  Future<BibleBook?> getBook(BibleTranslation translation, int bookNumber);
}
