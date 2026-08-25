import 'package:endgame_mastery/features/lessons/data/curriculum.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_hints.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_positions.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_position_definition.dart';
import 'package:endgame_mastery/features/lessons/rules/key_squares_rule.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_position_resolver.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_stage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Key Squares Lesson 4 - Diagram 1-4', () {
    const resolver = LessonPositionResolver();
    const rule = KeySquaresRule();

    test('preserves the corrected exact book position', () {
      expect(
        keySquaresLesson04.fen,
        '2k5/8/8/7p/8/8/6P1/5K2 w - - 0 1',
      );
      expect(keySquaresLesson04.sideToMove, ChessSide.white);
      expect(keySquaresLesson04.theoreticalResult, TheoreticalResult.win);
      expect(keySquaresLesson04.initialKeySquares, <String>{'f4', 'g4', 'h4'});
    });

    test('recalculates key squares when the white pawn moves from g2 to g3', () {
      expect(rule.forWhitePawn('g2'), <String>{'f4', 'g4', 'h4'});
      expect(rule.forWhitePawn('g3'), <String>{'f5', 'g5', 'h5'});
    });

    test('uses only the book position and positions from the published line', () {
      expect(keySquaresLesson04Positions.length, 4);

      final learn = keySquaresLesson04Positions.singleWhere(
        (position) => position.role == LessonPositionRole.learn,
      );
      final practice = keySquaresLesson04Positions
          .where((position) => position.role == LessonPositionRole.practice)
          .toList(growable: false);
      final prove = keySquaresLesson04Positions.singleWhere(
        (position) => position.role == LessonPositionRole.prove,
      );

      expect(learn.fen, '2k5/8/8/7p/8/8/6P1/5K2 w - - 0 1');
      expect(practice.length, 2);
      expect(practice[0].fen, '2k5/8/8/8/7p/8/5KP1/8 w - - 0 2');
      expect(practice[1].fen, '2k5/8/8/8/8/7p/6P1/6K1 w - - 0 3');
      expect(prove.fen, learn.fen);
    });

    test('resolver exposes both published practice checkpoints', () {
      final practice = resolver.practicePositionsFor(keySquaresLesson04);

      expect(practice.length, 2);
      expect(
        resolver.positionForStage(
          lesson: keySquaresLesson04,
          stage: LessonStage.practice,
        ).fen,
        practice.first.fen,
      );
      expect(
        resolver.positionForStage(
          lesson: keySquaresLesson04,
          stage: LessonStage.prove,
        ).fen,
        keySquaresLesson04.fen,
      );
    });

    test('teaches recalculation rather than a fixed key-square map', () {
      expect(keySquaresLesson04.learnText, contains('recalculate'));
      expect(keySquaresLesson04.learnText, contains('f5, g5, and h5'));
      expect(keySquaresLesson04Hints.concept, contains('current pawn structure'));
      expect(keySquaresLesson04Hints.visual, contains('f5, g5, and h5'));
    });

    test('appears after Diagram 1-3 in the curriculum', () {
      expect(curriculum.length, greaterThanOrEqualTo(4));
      expect(curriculum[0].id, keySquaresLesson01.id);
      expect(curriculum[1].id, keySquaresLesson02.id);
      expect(curriculum[2].id, keySquaresLesson03.id);
      expect(curriculum[3].id, keySquaresLesson04.id);
    });
  });
}
