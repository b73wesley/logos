extension StringX on String? {
  /// Checks if the string is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Checks if the string is not null and not empty.
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}
