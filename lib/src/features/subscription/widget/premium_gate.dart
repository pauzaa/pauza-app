import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_bloc.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_state.dart';

class PremiumGate extends StatelessWidget {
  const PremiumGate({required this.child, required this.lockedChild, super.key});

  final Widget child;
  final Widget lockedChild;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CurrentUserBloc, CurrentUserState, bool>(
      bloc: RootScope.of(context).currentUserBloc,
      selector: (state) => state.user?.subscription?.isActive == true,
      builder: (context, isPremium) => isPremium ? child : lockedChild,
    );
  }
}
