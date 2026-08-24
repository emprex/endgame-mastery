import 'package:endgame_mastery/app/endgame_mastery_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: EndgameMasteryApp(),
    ),
  );
}
