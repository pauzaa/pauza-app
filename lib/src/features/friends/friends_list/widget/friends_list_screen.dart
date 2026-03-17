import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/features/friends/friends_list/bloc/friends_list_bloc.dart';
import 'package:pauza/src/features/friends/friends_list/widget/friends_list_content.dart';

class FriendsListScreen extends StatelessWidget {
  const FriendsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FriendsListBloc(friendsRepository: RootScope.of(context).friendsRepository)
            ..add(const FriendsListLoadRequested()),
      child: const FriendsListContent(),
    );
  }
}
