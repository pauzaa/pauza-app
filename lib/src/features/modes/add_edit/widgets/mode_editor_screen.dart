import 'package:flutter/material.dart';

class ModeEditorScreen extends StatelessWidget {
  const ModeEditorScreen({required this.modeId, super.key});

  factory ModeEditorScreen.create() => const ModeEditorScreen(modeId: null);

  factory ModeEditorScreen.edit({required String modeId}) => ModeEditorScreen(modeId: modeId);

  final String? modeId;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
