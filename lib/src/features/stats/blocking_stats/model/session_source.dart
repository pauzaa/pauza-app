/// The trigger source that started a restriction session.
enum SessionSource {
  manual('manual'),
  schedule('schedule');

  const SessionSource(this.dbValue);

  /// The raw value stored in the `restriction_sessions.source` column.
  final String dbValue;

  /// Parses a database value into a [SessionSource], or returns `null`
  /// if the value is unrecognised.
  static SessionSource? fromDb(Object? value) {
    if (value is! String) return null;
    for (final source in values) {
      if (source.dbValue == value) return source;
    }
    return null;
  }
}
