import '../domain/lesson_definition.dart';
import 'lesson_session_state.dart';
import 'lesson_stage.dart';

/// Resolves lesson progression inside an ordered curriculum.
///
/// This is pure domain/navigation logic.
/// It does not perform Flutter navigation and does not modify lesson sessions.
class LessonProgression {
  factory LessonProgression(Iterable<LessonDefinition> lessons) {
    final normalizedLessons = List<LessonDefinition>.unmodifiable(lessons);

    if (normalizedLessons.isEmpty) {
      throw ArgumentError('Lesson progression requires at least one lesson.');
    }

    final knownIds = <String>{};

    for (final lesson in normalizedLessons) {
      if (!knownIds.add(lesson.id)) {
        throw ArgumentError('Lesson progression requires unique lesson IDs.');
      }
    }

    return LessonProgression._(normalizedLessons);
  }

  const LessonProgression._(this.lessons);

  /// Curriculum order is significant.
  final List<LessonDefinition> lessons;

  LessonDefinition get firstLesson => lessons.first;

  /// Returns whether the completed session has another curriculum lesson.
  ///
  /// Calling this before the session is completed is invalid.
  bool hasNextLesson(LessonSessionState session) {
    return nextLessonFor(session) != null;
  }

  /// Resolves the next curriculum lesson for a completed session.
  ///
  /// Returns null when the current lesson is the final curriculum lesson.
  ///
  /// The current lesson is matched by its stable curriculum ID rather than
  /// object identity.
  LessonDefinition? nextLessonFor(LessonSessionState session) {
    if (session.stage != LessonStage.completed) {
      throw StateError(
        'The next lesson can only be resolved after the current lesson '
        'session is completed.',
      );
    }

    final currentIndex = lessons.indexWhere(
      (lesson) => lesson.id == session.lesson.id,
    );

    if (currentIndex == -1) {
      throw StateError(
        'Lesson "${session.lesson.id}" is not part of this curriculum.',
      );
    }

    final nextIndex = currentIndex + 1;

    if (nextIndex >= lessons.length) {
      return null;
    }

    return lessons[nextIndex];
  }
}
