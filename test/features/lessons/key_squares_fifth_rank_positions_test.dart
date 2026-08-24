import 'package:endgame_mastery/features/lessons/data/pawn_endgame_positions.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_position_definition.dart';
import 'package:endgame_mastery/features/lessons/rules/fen_pawn_locator.dart';
import 'package:endgame_mastery/features/lessons/rules/key_squares_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Key Squares Lesson 2 position pack', () {
    test('contains Learn, two Practice positions and Prove', () {
      expect(keySquaresLesson02Positions.length, 4);

      expect(
        keySquaresLesson02Positions
            .where((position) => position.role == LessonPositionRole.learn)
            .length,
        1,
      );

      expect(
        keySquaresLesson02Positions
            .where((position) => position.role == LessonPositionRole.practice)
            .length,
        2,
      );

      expect(
        keySquaresLesson02Positions
            .where((position) => position.role == LessonPositionRole.prove)
            .length,
        1,
      );
    });

    test('all positions are White-to-move theoretical wins', () {
      for (final position in keySquaresLesson02Positions) {
        expect(position.sideToMove, ChessSide.white);
        expect(position.theoreticalResult, TheoreticalResult.win);
      }
    });

    test('dynamic rule produces six key squares for every position', () {
      const locator = FenPawnLocator();
      const rule = KeySquaresRule();

      for (final position in keySquaresLesson02Positions) {
        final pawns = locator.whitePawns(position.fen);

        expect(pawns.length, 1);

        final keySquares = rule.forWhitePawn(pawns.single);

        expect(keySquares.length, 6);
      }
    });

    test('practice positions transfer the pattern across files', () {
      const rule = KeySquaresRule();

      expect(rule.forWhitePawn('f5'), <String>{
        'e6',
        'f6',
        'g6',
        'e7',
        'f7',
        'g7',
      });

      expect(rule.forWhitePawn('c5'), <String>{
        'b6',
        'c6',
        'd6',
        'b7',
        'c7',
        'd7',
      });
    });
  });
}
