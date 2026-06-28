import 'package:logos_app/domain/bible/bible_models.dart';

abstract class BibleService {
  /// Parses and returns all books for the given [translation] asset.
  Future<List<BibleBook>> parseTranslation(BibleTranslation translation);
}
