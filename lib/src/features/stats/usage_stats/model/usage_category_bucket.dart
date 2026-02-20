import 'package:flutter/material.dart';

enum UsageCategoryBucket {
  social,
  productivity,
  other;

  Color getColorForFonutBucket(ColorScheme colorScheme) {
    return switch (this) {
      UsageCategoryBucket.social => colorScheme.primary,
      UsageCategoryBucket.productivity => colorScheme.onSurfaceVariant,
      UsageCategoryBucket.other => colorScheme.outline,
    };
  }

  factory UsageCategoryBucket.fromCategory(String? category) {
    if (category == null) {
      return UsageCategoryBucket.other;
    }
    final normalized = category.toLowerCase();

    if (normalized.contains('social') ||
        normalized.contains('communication') ||
        normalized.contains('messaging')) {
      return UsageCategoryBucket.social;
    }

    if (normalized.contains('productivity') ||
        normalized.contains('business') ||
        normalized.contains('education') ||
        normalized.contains('tools')) {
      return UsageCategoryBucket.productivity;
    }

    return UsageCategoryBucket.other;
  }
}
