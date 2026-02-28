import 'dart:ui';

/// Static chart color palette for usage stats charts.
abstract final class StatsChartColors {
  static const List<Color> palette = [
    Color(0xFF800020), // burgundy (primary)
    Color(0xFF2E7D32), // green
    Color(0xFFED8B00), // amber
    Color(0xFF1565C0), // blue
    Color(0xFF6A1B9A), // purple
    Color(0xFFD84315), // deep orange
    Color(0xFF00838F), // teal
    Color(0xFF4E342E), // brown
  ];

  /// Returns the palette color at [index], or a faded fallback for overflow.
  static Color colorAt(int index) {
    if (index < palette.length) {
      return palette[index];
    }
    return const Color(0xFF9E9E9E);
  }
}
