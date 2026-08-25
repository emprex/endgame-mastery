import 'package:endgame_mastery/features/lessons/data/pawn_endgame_hints.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/rules/key_squares_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Key Squares — fifth rank lesson', () {
    const fen = '1k6/8/1K6/1P6/8/8/8/8 w - - 0 1';

    test('preserves Dvoretsky Diagram 1-2', () {
      expect(keySquaresLesson02.fen, fen);
      expect(keySquaresLesson02.sideToMove, ChessSide.white);
      expect(keySquaresLesson02.theoreticalResult, TheoreticalResult.win);
      expect(keySquaresLesson02.difficulty, 1);
    });

    test('defines the six fifth-rank key squares for the b5 pawn', () {
      expect(keySquaresLesson02.initialKeySquares, <String>{
        'a6',
        'b6',
        'c6',
        'a7',
        'b7',
        'c7',
      });
    });

    test('reuses KeySquaresRule for the b5 pawn', () {
      const rule = KeySquaresRule();

      expect(rule.forWhitePawn('b5'), <String>{
        'a6',
        'b6',
        'c6',
        'a7',
        'b7',
        'c7',
      });
    });

    test('hints recognize that the king already occupies a key square', () {
      expect(
        keySquaresLesson02Hints.visual,
        contains('a6, b6, c6, a7, b7, and c7'),
      );
      expect(keySquaresLesson02Hints.visual, contains('standing on b6'));

      for (final hint in <String>[
        keySquaresLesson02Hints.concept,
        keySquaresLesson02Hints.visual,
        keySquaresLesson02Hints.targeted,
      ]) {
        expect(hint, isNot(contains('Ka6')));
        expect(hint, isNot(contains('Kc6')));
      }
    });

    test('unknown positions do not inherit theoretical truth', () {
      expect(
        keySquaresLesson02.theoreticalResultForFen(
          '1k6/8/2K5/1P6/8/8/8/8 w - - 0 1',
        ),
        isNull,
      );
    });
  });
}
