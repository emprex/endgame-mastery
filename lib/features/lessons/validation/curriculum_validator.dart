import '../domain/lesson_definition.dart';
import 'curriculum_validation.dart';

/// Validates curriculum consistency before lessons reach the UI.
///
/// LessonDefinition already prevents many malformed objects.
/// This validator adds cross-lesson and pedagogical consistency checks.
class CurriculumValidator {
  const CurriculumValidator();

  CurriculumValidationResult validate(Iterable<LessonDefinition> lessons) {
    final issues = <CurriculumValidationIssue>[];

    final lessonIds = <String>{};

    for (final lesson in lessons) {
      if (!lessonIds.add(lesson.id)) {
        issues.add(
          CurriculumValidationIssue(
            lessonId: lesson.id,
            message: 'Lesson id must be unique.',
          ),
        );
      }

      _validateLesson(lesson, issues);
    }

    return CurriculumValidationResult(issues: issues);
  }

  void _validateLesson(
    LessonDefinition lesson,
    List<CurriculumValidationIssue> issues,
  ) {
    // The initial position must always resolve to the lesson's
    // declared theoretical result.
    final initialResult = lesson.theoreticalResultForFen(lesson.fen);

    if (initialResult != lesson.theoreticalResult) {
      issues.add(
        CurriculumValidationIssue(
          lessonId: lesson.id,
          message: 'Initial FEN does not resolve to its declared theoretical result.',
        ),
      );
    }

    // Key Squares lessons must contain at least one initial key square.
    if (lesson.concept == LessonConcept.keySquares &&
        lesson.initialKeySquares.isEmpty) {
      issues.add(
        CurriculumValidationIssue(
          lessonId: lesson.id,
          message: 'Key Squares lesson must define initial key squares.',
        ),
      );
    }

    final knownFens = <String>{lesson.fen};

    for (final outcome in lesson.comparisonOutcomes) {
      if (!knownFens.add(outcome.fen)) {
        issues.add(
          CurriculumValidationIssue(
            lessonId: lesson.id,
            message: 'The same theoretical FEN appears more than once.',
          ),
        );
      }

      // A comparison position should actually differ from the
      // main lesson position in at least one complete FEN field.
      if (outcome.fen == lesson.fen) {
        issues.add(
          CurriculumValidationIssue(
            lessonId: lesson.id,
            message: 'Comparison outcome duplicates the initial FEN.',
          ),
        );
      }
    }
  }
}
