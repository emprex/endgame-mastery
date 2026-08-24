import 'package:endgame_mastery/features/lessons/data/curriculum.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_progression.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_outcome.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_state.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_stage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LessonDefinition testLesson(String id) {
    return LessonDefinition(
      id: id,
      title: 'Test Lesson',
      fen: '8/3k4/8/3K4/3P4/8/8/8 w - - 0 1',
      concept: LessonConcept.keySquares,
      objective: 'Navigation test only.',
      learnText: 'Navigation test only.',
      userSide: ChessSide.white,
      initialKeySquares: const <String>{'c6', 'd6', 'e6'},
      theoreticalResult: TheoreticalResult.draw,
      difficulty: 1,
    );
  }

  LessonSessionState completedSessionFor(LessonDefinition lesson) {
    return LessonSessionState(
      lesson: lesson,
      stage: LessonStage.completed,
      outcome: LessonSessionOutcome.draw,
    );
  }

  group('LessonProgression', () {
    test('rejects an empty curriculum', () {
      expect(
        () => LessonProgression(const <LessonDefinition>[]),
        throwsArgumentError,
      );
    });

    test('rejects duplicate lesson IDs', () {
      final first = testLesson('duplicate-id');
      final second = testLesson('duplicate-id');

      expect(
        () => LessonProgression(<LessonDefinition>[first, second]),
        throwsArgumentError,
      );
    });

    test('firstLesson returns the first curriculum lesson', () {
      final progression = LessonProgression(curriculum);

      expect(progression.firstLesson, same(keySquaresLesson01));
    });

    test('current real curriculum has no next lesson yet', () {
      final progression = LessonProgression(curriculum);

      final session = completedSessionFor(keySquaresLesson01);

      expect(progression.hasNextLesson(session), isFalse);
      expect(progression.nextLessonFor(session), isNull);
    });

    test('resolves the next lesson by curriculum order', () {
      final first = testLesson('test-lesson-01');
      final second = testLesson('test-lesson-02');

      final progression = LessonProgression(<LessonDefinition>[first, second]);

      final session = completedSessionFor(first);

      expect(progression.hasNextLesson(session), isTrue);
      expect(progression.nextLessonFor(session), same(second));
    });

    test('final lesson returns null', () {
      final first = testLesson('test-lesson-01');
      final second = testLesson('test-lesson-02');

      final progression = LessonProgression(<LessonDefinition>[first, second]);

      final session = completedSessionFor(second);

      expect(progression.hasNextLesson(session), isFalse);
      expect(progression.nextLessonFor(session), isNull);
    });

    test('Next is rejected before session completion', () {
      final progression = LessonProgression(curriculum);

      for (final stage in <LessonStage>[
        LessonStage.learn,
        LessonStage.practice,
        LessonStage.prove,
        LessonStage.result,
      ]) {
        final state = stage == LessonStage.result
            ? LessonSessionState(
                lesson: keySquaresLesson01,
                stage: stage,
                outcome: LessonSessionOutcome.draw,
              )
            : LessonSessionState(lesson: keySquaresLesson01, stage: stage);

        expect(() => progression.nextLessonFor(state), throwsStateError);
      }
    });

    test('rejects a completed lesson outside the curriculum', () {
      final progression = LessonProgression(curriculum);

      final outsideLesson = testLesson('outside-curriculum');

      final session = completedSessionFor(outsideLesson);

      expect(() => progression.nextLessonFor(session), throwsStateError);
    });

    test('matches current lesson by stable ID, not object identity', () {
      final first = testLesson('test-lesson-01');
      final second = testLesson('test-lesson-02');

      final progression = LessonProgression(<LessonDefinition>[first, second]);

      final equivalentFirst = testLesson('test-lesson-01');

      final session = completedSessionFor(equivalentFirst);

      expect(progression.nextLessonFor(session), same(second));
    });
  });
}
