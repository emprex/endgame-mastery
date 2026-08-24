import '../domain/lesson_definition.dart';
import 'pawn_endgame_lessons.dart';

/// Current Endgame Mastery curriculum.
///
/// Keep this list intentionally small while the lesson architecture
/// is still being built and validated.
final List<LessonDefinition> curriculum = List<LessonDefinition>.unmodifiable(
  <LessonDefinition>[keySquaresLesson01],
);
