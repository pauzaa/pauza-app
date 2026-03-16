import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/features/friends/find_and_requests/bloc/find_and_requests_bloc.dart';
import 'package:pauza/src/features/friends/find_and_requests/widget/find_and_requests_content.dart';

class FindAndRequestsScreen extends StatelessWidget {
  const FindAndRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FindAndRequestsBloc(friendsRepository: RootScope.of(context).friendsRepository)
            ..add(const FindAndRequestsLoadRequested()),
      child: const FindAndRequestsContent(),
    );
  }
}
