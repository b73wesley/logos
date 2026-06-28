import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:logos_app/data/services/bible/bible_service.dart';
import 'package:logos_app/domain/bible/bible_models.dart';

/// Standard Bible book names indexed by book number (1–66).
const List<String> _bookNames = [
  '', // index 0 — unused
  'Genesis', // 1
  'Exodus', // 2
  'Leviticus', // 3
  'Numbers', // 4
  'Deuteronomy', // 5
  'Joshua', // 6
  'Judges', // 7
  'Ruth', // 8
  '1 Samuel', // 9
  '2 Samuel', // 10
  '1 Kings', // 11
  '2 Kings', // 12
  '1 Chronicles', // 13
  '2 Chronicles', // 14
  'Ezra', // 15
  'Nehemiah', // 16
  'Esther', // 17
  'Job', // 18
  'Psalms', // 19
  'Proverbs', // 20
  'Ecclesiastes', // 21
  'Song of Solomon', // 22
  'Isaiah', // 23
  'Jeremiah', // 24
  'Lamentations', // 25
  'Ezekiel', // 26
  'Daniel', // 27
  'Hosea', // 28
  'Joel', // 29
  'Amos', // 30
  'Obadiah', // 31
  'Jonah', // 32
  'Micah', // 33
  'Nahum', // 34
  'Habakkuk', // 35
  'Zephaniah', // 36
  'Haggai', // 37
  'Zechariah', // 38
  'Malachi', // 39
  'Matthew', // 40
  'Mark', // 41
  'Luke', // 42
  'John', // 43
  'Acts', // 44
  'Romans', // 45
  '1 Corinthians', // 46
  '2 Corinthians', // 47
  'Galatians', // 48
  'Ephesians', // 49
  'Philippians', // 50
  'Colossians', // 51
  '1 Thessalonians', // 52
  '2 Thessalonians', // 53
  '1 Timothy', // 54
  '2 Timothy', // 55
  'Titus', // 56
  'Philemon', // 57
  'Hebrews', // 58
  'James', // 59
  '1 Peter', // 60
  '2 Peter', // 61
  '1 John', // 62
  '2 John', // 63
  '3 John', // 64
  'Jude', // 65
  'Revelation', // 66
];

String bookName(int bookNumber) {
  if (bookNumber >= 1 && bookNumber <= 66) return _bookNames[bookNumber];
  return 'Unknown';
}

class BibleServiceImpl implements BibleService {
  @override
  Future<List<BibleBook>> parseTranslation(BibleTranslation translation) async {
    final raw = await rootBundle.loadString(translation.assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final rows = (json['resultset']['row'] as List<dynamic>);

    // Group verses by book then chapter
    final Map<int, Map<int, List<BibleVerse>>> grouped = {};

    for (final row in rows) {
      final fields = (row as Map<String, dynamic>)['field'] as List<dynamic>;
      final bookNum = fields[1] as int;
      final chapNum = fields[2] as int;
      final verseNum = fields[3] as int;
      final text = fields[4] as String;

      grouped.putIfAbsent(bookNum, () => {});
      grouped[bookNum]!.putIfAbsent(chapNum, () => []);
      grouped[bookNum]![chapNum]!.add(
        BibleVerse(bookNumber: bookNum, chapter: chapNum, verseNumber: verseNum, text: text),
      );
    }

    final books = grouped.entries.map((bookEntry) {
      final chapters = bookEntry.value.entries.map((chapEntry) {
        return BibleChapter(bookNumber: bookEntry.key, chapterNumber: chapEntry.key, verses: chapEntry.value);
      }).toList()..sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));

      return BibleBook(number: bookEntry.key, name: bookName(bookEntry.key), chapters: chapters);
    }).toList()..sort((a, b) => a.number.compareTo(b.number));

    return books;
  }
}
