import 'package:endgame_mastery/core/chess/played_move.dart';
import 'package:endgame_mastery/features/lessons/data/curriculum.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_hints.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_positions.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_position_definition.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_position_resolver.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_stage.dart';
import 'package:endgame_mastery/features/lessons/teaching/key_squares_move_assessment_rule.dart';
import 'package:endgame_mastery/features/lessons/teaching/pedagogical_move_assessment.dart';
import 'package:endgame_mastery/features/lessons/teaching/teaching_state_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Key Squares Lesson 3 — Diagram 1-3', () {
    const resolver = LessonPositionResolver();
    const builder = TeachingStateBuilder();
    const assessmentRule = KeySquaresMoveAssessmentRule();

    test('preserves the exact book position and key squares', () {
      expect(
        keySquaresLesson03.fen,
        '5k2/8/8/8/1P6/8/8/3K4 w - - 0 1',
      );
      expect(keySquaresLesson03.sideToMove, ChessSide.white);
      expect(keySquaresLesson03.theoreticalResult, TheoreticalResult.win);
      expect(keySquaresLesson03.initialKeySquares, <String>{'a6', 'b6', 'c6'});
    });

    test('teaches choosing the key square farthest from the enemy king', () {
      expect(keySquaresLesson03.learnText, contains('farthest'));
      expect(keySquaresLesson03.learnText, contains('a6'));
      expect(keySquaresLesson03Hints.concept, contains('defending king'));
      expect(keySquaresLesson03Hints.visual, contains('a6, b6, and c6'));
    });

    test('uses only the book position and a position from its published line', () {
      expect(keySquaresLesson03Positions.length, 3);

      final learn = keySquaresLesson03Positions.singleWhere(
        (position) => position.role == LessonPositionRole.learn,
      );
      final practice = keySquaresLesson03Positions.singleWhere(
        (position) => position.role == LessonPositionRole.practice,
      );
      final prove = keySquaresLesson03Positions.singleWhere(
        (position) => position.role == LessonPositionRole.prove,
      );

      expect(learn.fen, '5k2/8/8/8/1P6/8/8/3K4 w - - 0 1');
      expect(practice.fen, '8/8/3k4/8/1P6/1K6/8/8 w - - 0 1');
      expect(prove.fen, learn.fen);
    });

    test('resolver exposes the exact Lesson 3 practice and prove positions', () {
      expect(
        resolver.positionForStage(
          lesson: keySquaresLesson03,
          stage: LessonStage.practice,
        ).fen,
        '8/8/3k4/8/1P6/1K6/8/8 w - - 0 1',
      );
      expect(
        resolver.positionForStage(
          lesson: keySquaresLesson03,
          stage: LessonStage.prove,
        ).fen,
        '5k2/8/8/8/1P6/8/8/3K4 w - - 0 1',
      );
    });

    test('coaching reinforces the published route toward a6', () {
      const beforeFen = '8/8/3k4/8/1P6/1K6/8/8 w - - 0 1';
      const afterFen = '8/8/3k4/8/KP6/8/8/8 b - - 1 1';

      final assessment = assessmentRule.assess(
        move: PlayedMove(from: 'b3', to: 'a4'),
        before: builder.build(lesson: keySquaresLesson03, fen: beforeFen),
        after: builder.build(lesson: keySquaresLesson03, fen: afterFen),
      );

      expect(assessment, isNotNull);
      expect(assessment!.quality, PedagogicalMoveQuality.reinforcesConcept);
      expect(assessment.title, contains('a6'));
      expect(assessment.message, contains('farthest'));
    });

    test('coaching flags only the published Kc4 defensive resource', () {
      const beforeFen = '8/8/3k4/8/1P6/1K6/8/8 w - - 0 1';
      const afterFen = '8/8/3k4/8/1PK5/8/8/8 b - - 1 1';

      final assessment = assessmentRule.assess(
        move: PlayedMove(from: 'b3', to: 'c4'),
        before: builder.build(lesson: keySquaresLesson03, fen: beforeFen),
        after: builder.build(lesson: keySquaresLesson03, fen: afterFen),
      );

      expect(assessment, isNotNull);
      expect(assessment!.quality, PedagogicalMoveQuality.needsAttention);
      expect(assessment.message, contains('...Kc6'));
      expect(assessment.message, contains('a6'));
    });

    test('appears after Lessons 1 and 2 in the curriculum', () {
      expect(curriculum.length, greaterThanOrEqualTo(3));
      expect(curriculum[0].id, keySquaresLesson01.id);
      expect(curriculum[1].id, keySquaresLesson02.id);
      expect(curriculum[2].id, keySquaresLesson03.id);
    });
  });
}
