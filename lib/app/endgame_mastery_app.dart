import 'package:endgame_mastery/features/coach/presentation/coach_home_screen.dart';
import 'package:flutter/material.dart';

class EndgameMasteryApp extends StatelessWidget {
  const EndgameMasteryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chess Coach',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF171717),
      ),
      home: const CoachHomeScreen(),
    );
  }
}
