class FontSize {
  // Title sizes
  static const double titleSmall = 16.0;
  static const double titleMedium = 18.0;
  static const double titleLarge = 20.0;

  // Body sizes
  static const double bodySmall = 12.0;
  static const double bodyMedium = 14.0;
  static const double bodyLarge = 16.0;

  // Headline sizes
  static const double headlineSmall = 22.0;
  static const double headlineMedium = 24.0;
  static const double headlineLarge = 26.0;

  // Label sizes
  static const double labelSmall = 10.0;
  static const double labelMedium = 12.0;
  static const double labelLarge = 14.0;

  // ── Verse-specific sizes ──────────────────────────────────────────────────
  // Used exclusively for Bible verse text and verse number superscripts.
  // Do NOT use these tokens outside of the reader widgets.

  static const double verseSmall = 13.0;
  static const double verseMedium = 15.0;
  static const double verseLarge = 17.0; // default — mirrors bodyLarge
  static const double verseLargeX = 19.0; // extra-large option

  // Verse number superscript — always proportionally smaller than verse body.
  static const double verseNumberSmall = 9.0;
  static const double verseNumberMedium = 10.0;
  static const double verseNumberLarge = 11.0; // default
  static const double verseNumberLargeX = 12.0;
}
