import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_state.dart';

void main() {
  testWidgets('descendant rebuilds when bloc state changes', (tester) async {
    final bloc = _FakeCurrentUserBloc();
    addTearDown(bloc.close);

    var buildCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<_FakeCurrentUserBloc>.value(
          value: bloc,
          child: _ProbeWidget(
            onBuild: () {
              buildCount += 1;
            },
          ),
        ),
      ),
    );

    final initialBuildCount = buildCount;

    bloc.emit(
      CurrentUserState.available(
        user: const UserDto(
          profilePicture: 'https://example.com/avatar/john.png',
          username: 'john',
          name: 'John',
        ),
        freshness: UserFreshness.fresh,
        cachedAtUtc: DateTime.utc(2026, 2, 16, 10),
        isSyncing: false,
      ),
    );
    await tester.pump();

    expect(buildCount, greaterThan(initialBuildCount));
  });
}

class _ProbeWidget extends StatelessWidget {
  const _ProbeWidget({required this.onBuild});

  final VoidCallback onBuild;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<_FakeCurrentUserBloc, CurrentUserState>(
      builder: (context, state) {
        onBuild();
        return Text(state.runtimeType.toString());
      },
    );
  }
}

final class _FakeCurrentUserBloc extends Cubit<CurrentUserState> {
  _FakeCurrentUserBloc() : super(const CurrentUserState.unauthenticated());
}
