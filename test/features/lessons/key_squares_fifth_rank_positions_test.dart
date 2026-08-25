import 'package:endgame_mastery/features/lessons/data/pawn_endgame_positions.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_position_definition.dart';
import 'package:endgame_mastery/features/lessons/rules/fen_pawn_locator.dart';
import 'package:endgame_mastery/features/lessons/rules/key_squares_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Key Squares Lesson 2 position pack', () {
    test('uses Diagram 1-2 and only positions from its published variations', () {
      expect(keySquaresLesson02Positions.length, 4);

      expect(
        keySquaresLesson02Positions
            .where((position) => position.role == LessonPositionRole.learn)
            .single
            .fen,
        '1k6/8/1K6/1P6/8/8/8/8 w - - 0 1',
      );

      expect(
        keySquaresLesson02Positions
            .where((position) => position.role == LessonPositionRole.practice)
            .map((position) => position.fen)
            .toList(),
        <String>[
          '8/k7/2K5/1P6/8/8/8/8 w - - 0 1',
          'k7/2K5/8/1P6/8/8/8/8 w - - 0 1',
        ],
      );

      expect(
        keySquaresLesson02Positions
            .where((position) => position.role == LessonPositionRole.prove)
            .single
            .fen,
        '1k6/8/1K6/1P6/8/8/8/8 w - - 0 1',
      );
    });

    test('all positions are White-to-move theoretical wins', () {
      for (final position in keySquaresLesson02Positions) {
        expect(position.sideToMove, ChessSide.white);
        expect(position.theoreticalResult, TheoreticalResult.win);
      }
    });

    test('dynamic rule produces the six b5 key squares', () {
      const locator = FenPawnLocator();
      const rule = KeySquaresRule();

      for (final position in keySquaresLesson02Positions) {
        final pawns = locator.whitePawns(position.fen);

        expect(pawns, <String>['b5']);
        expect(rule.forWhitePawn(pawns.single), <String>{
          'a6',
          'b6',
          'c6',
          'a7',
          'b7',
          'c7',
        });
      }
    });

    test('practice positions preserve the two critical Diagram 1-2 lessons', () {
      final practice = keySquaresLesson02Positions
          .where((position) => position.role == LessonPositionRole.practice)
          .toList();

      expect(practice[0].teachingPoint, contains('inaccurate route Kc6'));
      expect(practice[1].teachingPoint, contains('avoid stalemate'));
    });
  });
}
