import 'package:logos_app/core/design_tokens/font_size.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This class will handle user preferences
// For example, theme settings, language preferences, etc.
class Preferences {
  // Singleton instance
  static final Preferences _instance = Preferences._internal();

  late SharedPreferences _prefs;

  factory Preferences() {
    return _instance;
  }

  Preferences._internal();

  // Initialize SharedPreferences
  static Future<void> init() async {
    _instance._prefs = await SharedPreferences.getInstance();
  }

  // ── Keys ──────────────────────────────────────────────────────────────────

  static const _keyVerseDisplayMode = 'verse_display_mode';
  static const _keyVerseFontSize = 'verse_font_size';

  // ── Verse display mode ────────────────────────────────────────────────────

  /// Returns the stored verse display mode. Defaults to [VerseDisplayMode.list].
  VerseDisplayMode get verseDisplayMode {
    final stored = _prefs.getString(_keyVerseDisplayMode);
    return VerseDisplayMode.values.firstWhere((m) => m.name == stored, orElse: () => VerseDisplayMode.list);
  }

  Future<void> setVerseDisplayMode(VerseDisplayMode mode) async {
    await _prefs.setString(_keyVerseDisplayMode, mode.name);
  }

  // ── Verse font size ───────────────────────────────────────────────────────

  /// Returns the stored verse font size. Defaults to [VerseFontSize.large].
  VerseFontSize get verseFontSize {
    final stored = _prefs.getString(_keyVerseFontSize);
    return VerseFontSize.values.firstWhere((s) => s.name == stored, orElse: () => VerseFontSize.large);
  }

  Future<void> setVerseFontSize(VerseFontSize size) async {
    await _prefs.setString(_keyVerseFontSize, size.name);
  }

  // Method to reset preferences to default values
  Future<void> resetPreferences() async {
    await _prefs.clear();
  }
}

// ── Enums ─────────────────────────────────────────────────────────────────

enum VerseDisplayMode {
  /// Each verse on its own line with spacing between them.
  list,

  /// All verses flow as continuous prose — numbers inline as superscripts.
  bible,
}

enum VerseFontSize {
  small,
  medium,
  large,
  largeX;

  String get label {
    switch (this) {
      case VerseFontSize.small:
        return 'Pequena';
      case VerseFontSize.medium:
        return 'Média';
      case VerseFontSize.large:
        return 'Grande';
      case VerseFontSize.largeX:
        return 'Extra';
    }
  }

  /// Font size for verse body text.
  double get verseBodySize {
    switch (this) {
      case VerseFontSize.small:
        return FontSize.verseSmall;
      case VerseFontSize.medium:
        return FontSize.verseMedium;
      case VerseFontSize.large:
        return FontSize.verseLarge;
      case VerseFontSize.largeX:
        return FontSize.verseLargeX;
    }
  }

  /// Font size for inline verse number superscripts.
  double get verseNumberSize {
    switch (this) {
      case VerseFontSize.small:
        return FontSize.verseNumberSmall;
      case VerseFontSize.medium:
        return FontSize.verseNumberMedium;
      case VerseFontSize.large:
        return FontSize.verseNumberLarge;
      case VerseFontSize.largeX:
        return FontSize.verseNumberLargeX;
    }
  }
}
