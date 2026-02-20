import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:pauza/src/core/localization/l10n.dart';

@immutable
final class ModeIcon {
  const ModeIcon({required this.id, required this.icon});

  factory ModeIcon.fromToken(String token) {
    return ModeIconCatalog._resolveToken(token);
  }

  final String id;
  final IconData icon;
  String get token => '${ModeIconCatalog._tokenPrefix}$id';

  String localizedLabel(AppLocalizations l10n) {
    return switch (id) {
      'tune' => l10n.modeIconLabelTune,
      'psychology' => l10n.modeIconLabelPsychology,
      'timer' => l10n.modeIconLabelTimer,
      'bolt' => l10n.modeIconLabelBolt,
      'rocket_launch' => l10n.modeIconLabelRocketLaunch,
      'self_improvement' => l10n.modeIconLabelSelfImprovement,
      'fitness_center' => l10n.modeIconLabelFitnessCenter,
      'school' => l10n.modeIconLabelSchool,
      'work' => l10n.modeIconLabelWork,
      'menu_book' => l10n.modeIconLabelMenuBook,
      'music_note' => l10n.modeIconLabelMusicNote,
      'nightlight' => l10n.modeIconLabelNightlight,
      _ => l10n.modeIconLabelTune,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModeIcon &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          icon == other.icon;

  @override
  int get hashCode => Object.hash(id, icon);
}

abstract final class ModeIconCatalog {
  static const String _tokenPrefix = 'ms:v1:';
  static const String _defaultIconId = 'tune';

  static const String defaultToken = '$_tokenPrefix$_defaultIconId';
  static const ModeIcon defaultIcon = ModeIcon(id: 'tune', icon: Symbols.tune);

  static const List<ModeIcon> entries = <ModeIcon>[
    ModeIcon(id: 'tune', icon: Symbols.tune),
    ModeIcon(id: 'psychology', icon: Symbols.psychology),
    ModeIcon(id: 'timer', icon: Symbols.timer),
    ModeIcon(id: 'bolt', icon: Symbols.bolt),
    ModeIcon(id: 'rocket_launch', icon: Symbols.rocket_launch),
    ModeIcon(id: 'self_improvement', icon: Symbols.self_improvement),
    ModeIcon(id: 'fitness_center', icon: Symbols.fitness_center),
    ModeIcon(id: 'school', icon: Symbols.school),
    ModeIcon(id: 'work', icon: Symbols.work),
    ModeIcon(id: 'menu_book', icon: Symbols.menu_book),
    ModeIcon(id: 'music_note', icon: Symbols.music_note),
    ModeIcon(id: 'nightlight', icon: Symbols.nightlight),
  ];

  static final Map<String, ModeIcon> _entriesByToken = <String, ModeIcon>{
    for (final entry in entries) entry.token: entry,
  };

  static bool isValidToken(String token) => _entriesByToken.containsKey(token);

  static String normalizeToken(String? token) {
    if (token == null) {
      return defaultToken;
    }
    final trimmed = token.trim();
    if (trimmed.isEmpty) {
      return defaultToken;
    }
    return isValidToken(trimmed) ? trimmed : defaultToken;
  }

  static ModeIcon _resolveToken(String? token) =>
      _entriesByToken[normalizeToken(token)] ?? defaultIcon;
}
