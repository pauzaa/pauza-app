extension IterableModifiers<A> on Iterable<A> {
  /// Inserts [element] between elements of this [Iterable].
  Iterable<A> interleaved(A element) sync* {
    var index = 0;
    for (final current in this) {
      yield current;
      if (index++ != length - 1) yield element;
    }
  }
}
