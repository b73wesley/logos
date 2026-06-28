/// Represents a single Bible verse.
class BibleVerse {
  final int bookNumber;
  final int chapter;
  final int verseNumber;
  final String text;

  const BibleVerse({
    required this.bookNumber,
    required this.chapter,
    required this.verseNumber,
    required this.text,
  });
}

/// Represents a chapter with all its verses.
class BibleChapter {
  final int bookNumber;
  final int chapterNumber;
  final List<BibleVerse> verses;

  const BibleChapter({required this.bookNumber, required this.chapterNumber, required this.verses});
}

/// Represents a Bible book with its chapters.
class BibleBook {
  final int number;
  final String name;
  final List<BibleChapter> chapters;

  const BibleBook({required this.number, required this.name, required this.chapters});

  int get totalChapters => chapters.length;
}

/// Available Bible translations bundled offline.
enum BibleTranslation {
  kjv('KJV', 'King James Version', 'assets/bible/kjv.json'),
  asv('ASV', 'American Standard Version', 'assets/bible/asv.json'),
  bbe('BBE', 'Bible in Basic English', 'assets/bible/bbe.json'),
  web('WEB', 'World English Bible', 'assets/bible/web.json'),
  ylt('YLT', "Young's Literal Translation", 'assets/bible/ylt.json');

  final String abbreviation;
  final String fullName;
  final String assetPath;

  const BibleTranslation(this.abbreviation, this.fullName, this.assetPath);
}
