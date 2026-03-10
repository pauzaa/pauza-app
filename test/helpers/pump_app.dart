import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget child, {ThemeData? theme, List<Widget>? providers, Size? surfaceSize}) async {
    if (surfaceSize == null) {
      await binding.setSurfaceSize(null);
    } else {
      await binding.setSurfaceSize(surfaceSize);
      addTearDown(() async => binding.setSurfaceSize(null));
    }

    final Widget home;
    if (providers != null) {
      final blocProviders = providers.whereType<BlocProvider<StateStreamableSource<Object?>>>().toList();
      assert(
        blocProviders.length == providers.length,
        'pumpApp providers must be BlocProvider widgets when using the providers parameter.',
      );
      home = MultiBlocProvider(providers: blocProviders, child: child);
    } else {
      home = child;
    }

    await pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: theme ?? PauzaTheme.light,
        home: home,
      ),
    );

    await pump();
  }
}
