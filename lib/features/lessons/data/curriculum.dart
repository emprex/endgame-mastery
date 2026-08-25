import '../domain/lesson_definition.dart';
import 'pawn_endgame_lessons.dart';

/// Current Endgame Mastery curriculum.
///
/// Lessons are added incrementally only after their pedagogical theory,
/// position data and tests have been verified.
final List<LessonDefinition> curriculum = List<LessonDefinition>.unmodifiable(
  <LessonDefinition>[
    keySquaresLesson01,
    keySquaresLesson02,
    keySquaresLesson03,
    keySquaresLesson04,
    pawnTragicomedyLesson05,
    pawnTragicomedyLesson06,
  ],
);
