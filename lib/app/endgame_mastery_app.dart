import 'package:endgame_mastery/features/lessons/presentation/lesson_experience_screen.dart';
import 'package:flutter/material.dart';

class EndgameMasteryApp extends StatelessWidget {
  const EndgameMasteryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Endgame Mastery',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF171717),
      ),
      home: const LessonExperienceScreen(),
    );
  }
}
