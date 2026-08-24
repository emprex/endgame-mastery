import 'package:endgame_mastery/features/lessons/data/pawn_endgame_hints.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/rules/key_squares_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Key Squares — fifth rank lesson', () {
    const fen = '7k/8/8/3P4/3K4/8/8/8 w - - 0 1';

    test('preserves the verified lesson position', () {
      expect(keySquaresLesson02.fen, fen);
      expect(keySquaresLesson02.sideToMove, ChessSide.white);
      expect(keySquaresLesson02.theoreticalResult, TheoreticalResult.win);
      expect(keySquaresLesson02.difficulty, 1);
    });

    test('defines the six fifth-rank key squares', () {
      expect(keySquaresLesson02.initialKeySquares, <String>{
        'c6',
        'd6',
        'e6',
        'c7',
        'd7',
        'e7',
      });
    });

    test('reuses KeySquaresRule for the d5 pawn', () {
      const rule = KeySquaresRule();

      expect(rule.forWhitePawn('d5'), <String>{
        'c6',
        'd6',
        'e6',
        'c7',
        'd7',
        'e7',
      });
    });

    test('hints teach the six-square zone without giving a move', () {
      expect(
        keySquaresLesson02Hints.visual,
        contains('c6, d6, e6, c7, d7, and e7'),
      );

      for (final hint in <String>[
        keySquaresLesson02Hints.concept,
        keySquaresLesson02Hints.visual,
        keySquaresLesson02Hints.targeted,
      ]) {
        expect(hint, isNot(contains('Kc6')));
        expect(hint, isNot(contains('Kd6')));
        expect(hint, isNot(contains('Ke6')));
      }
    });

    test('unknown positions do not inherit theoretical truth', () {
      expect(
        keySquaresLesson02.theoreticalResultForFen(
          '7k/8/8/3P4/4K3/8/8/8 w - - 0 1',
        ),
        isNull,
      );
    });
  });
}
