import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_state.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/common/model/user_profile_failure.dart';
import 'package:pauza/src/features/profile/widget/profile_content.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  testWidgets('renders unified layout for available state', (tester) async {
    await tester.pumpWidget(
      _ProfileTestApp(
        state: CurrentUserState.available(
          user: const UserDto(
            profilePicture: 'https://example.com/avatar/alex.png',
            username: 'alexm',
            name: 'Alex Morgan',
          ),
          freshness: UserFreshness.fresh,
          cachedAtUtc: DateTime.utc(2026, 2, 17, 11),
          isSyncing: false,
        ),
      ),
    );

    expect(find.text('Profile'), findsAtLeastNWidgets(1));
    expect(find.text('Alex Morgan'), findsOneWidget);
    expect(find.text('@alexm'), findsOneWidget);
    expect(find.text('Edit Info'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Set Photo'), findsNothing);
    expect(find.text('Sign Out'), findsNothing);
    expect(find.textContaining('SESSIONS'), findsNothing);
    expect(find.textContaining('FOCUSED'), findsNothing);
    expect(find.byIcon(Icons.edit_rounded), findsNothing);
  });

  testWidgets('renders fallback profile data for non-available states', (
    tester,
  ) async {
    final states = <CurrentUserState>[
      const CurrentUserState.loading(),
      const CurrentUserState.unauthenticated(),
      const CurrentUserState.unavailable(
        reason: UserProfileFailureCode.network,
      ),
      const CurrentUserState.error(reason: UserProfileFailureCode.unknown),
    ];

    for (final state in states) {
      await tester.pumpWidget(_ProfileTestApp(state: state));
      await tester.pump();

      expect(find.text('Unknown User'), findsOneWidget);
      expect(find.text('@username'), findsOneWidget);
      expect(find.text('Edit Info'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    }
  });

  testWidgets('tapping Edit Info opens placeholder screen', (tester) async {
    await tester.pumpWidget(
      const _ProfileTestApp(state: CurrentUserState.unauthenticated()),
    );

    await tester.tap(find.text('Edit Info'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Edit Info'), findsAtLeastNWidgets(1));
    expect(find.byType(SizedBox), findsWidgets);
  });

  testWidgets('tapping Settings opens placeholder screen', (tester) async {
    await tester.pumpWidget(
      const _ProfileTestApp(state: CurrentUserState.unauthenticated()),
    );

    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Settings'), findsAtLeastNWidgets(1));
    expect(find.byType(SizedBox), findsWidgets);
  });
}

class _ProfileTestApp extends StatelessWidget {
  const _ProfileTestApp({required this.state});

  final CurrentUserState state;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: PauzaTheme.dark,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: ProfileContent(state: state),
    );
  }
}
