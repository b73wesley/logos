import 'package:flutter/material.dart';

/// How the highlight color is applied to verse text.
enum HighlightMode {
  /// Color fills the text background (default).
  background,

  /// Color is applied to the text itself — colored font.
  textColor,
}

/// Available highlight colors for verse markers.
enum HighlightColor {
  yellow,
  green,
  blue,
  pink,
  orange;

  Color get color {
    switch (this) {
      case HighlightColor.yellow:
        return const Color(0xFFFFEE58); // stronger yellow
      case HighlightColor.green:
        return const Color(0xFF81C784); // stronger green
      case HighlightColor.blue:
        return const Color(0xFF4FC3F7); // stronger blue
      case HighlightColor.pink:
        return const Color(0xFFF48FB1); // stronger pink
      case HighlightColor.orange:
        return const Color(0xFFFFB74D); // stronger orange
    }
  }

  Color get borderColor {
    switch (this) {
      case HighlightColor.yellow:
        return const Color(0xFFF9A825);
      case HighlightColor.green:
        return const Color(0xFF388E3C);
      case HighlightColor.blue:
        return const Color(0xFF0288D1);
      case HighlightColor.pink:
        return const Color(0xFFC2185B);
      case HighlightColor.orange:
        return const Color(0xFFE65100);
    }
  }
}

/// Annotation on a specific verse — optional highlight color and/or comment.
class VerseAnnotation {
  /// Unique key: "{bookNumber}_{chapter}_{verseNumber}"
  final String id;
  final int bookNumber;
  final int chapter;
  final int verseNumber;
  final HighlightColor? highlightColor;

  /// Whether the color paints the background or the text.
  final HighlightMode highlightMode;
  final String? comment;
  final DateTime updatedAt;

  const VerseAnnotation({
    required this.id,
    required this.bookNumber,
    required this.chapter,
    required this.verseNumber,
    this.highlightColor,
    this.highlightMode = HighlightMode.background,
    this.comment,
    required this.updatedAt,
  });

  static String buildId(int bookNumber, int chapter, int verseNumber) =>
      '${bookNumber}_${chapter}_$verseNumber';

  bool get hasHighlight => highlightColor != null;
  bool get hasComment => comment != null && comment!.trim().isNotEmpty;
  bool get isEmpty => !hasHighlight && !hasComment;

  VerseAnnotation copyWith({
    HighlightColor? highlightColor,
    HighlightMode? highlightMode,
    Object? comment = _sentinel,
    DateTime? updatedAt,
  }) {
    return VerseAnnotation(
      id: id,
      bookNumber: bookNumber,
      chapter: chapter,
      verseNumber: verseNumber,
      highlightColor: highlightColor ?? this.highlightColor,
      highlightMode: highlightMode ?? this.highlightMode,
      comment: comment == _sentinel ? this.comment : comment as String?,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  VerseAnnotation removeHighlight() => VerseAnnotation(
    id: id,
    bookNumber: bookNumber,
    chapter: chapter,
    verseNumber: verseNumber,
    highlightColor: null,
    highlightMode: HighlightMode.background,
    comment: comment,
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookNumber': bookNumber,
    'chapter': chapter,
    'verseNumber': verseNumber,
    'highlightColor': highlightColor?.name,
    'highlightMode': highlightMode.name,
    'comment': comment,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory VerseAnnotation.fromJson(Map<String, dynamic> json) {
    final colorName = json['highlightColor'] as String?;
    final modeName = json['highlightMode'] as String?;
    return VerseAnnotation(
      id: json['id'] as String,
      bookNumber: json['bookNumber'] as int,
      chapter: json['chapter'] as int,
      verseNumber: json['verseNumber'] as int,
      highlightColor: colorName == null
          ? null
          : HighlightColor.values.firstWhere((c) => c.name == colorName, orElse: () => HighlightColor.yellow),
      highlightMode: modeName == null
          ? HighlightMode.background
          : HighlightMode.values.firstWhere(
              (m) => m.name == modeName,
              orElse: () => HighlightMode.background,
            ),
      comment: json['comment'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Comment on a full chapter.
class ChapterNote {
  /// Unique key: "{bookNumber}_{chapter}"
  final String id;
  final int bookNumber;
  final int chapter;
  final String note;
  final DateTime updatedAt;

  const ChapterNote({
    required this.id,
    required this.bookNumber,
    required this.chapter,
    required this.note,
    required this.updatedAt,
  });

  static String buildId(int bookNumber, int chapter) => '${bookNumber}_$chapter';

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookNumber': bookNumber,
    'chapter': chapter,
    'note': note,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ChapterNote.fromJson(Map<String, dynamic> json) => ChapterNote(
    id: json['id'] as String,
    bookNumber: json['bookNumber'] as int,
    chapter: json['chapter'] as int,
    note: json['note'] as String,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

// Internal sentinel to distinguish null from "not provided" in copyWith.
const Object _sentinel = Object();
