import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Key Squares theoretical truth', () {
    const whiteToMoveFen = '8/3k4/8/3K4/3P4/8/8/8 w - - 0 1';

    const blackToMoveFen = '8/3k4/8/3K4/3P4/8/8/8 b - - 0 1';

    test('White to move is theoretically drawn', () {
      expect(
        keySquaresLesson01.theoreticalResultForFen(whiteToMoveFen),
        TheoreticalResult.draw,
      );
    });

    test('Black to move is theoretically winning for White', () {
      expect(
        keySquaresLesson01.theoreticalResultForFen(blackToMoveFen),
        TheoreticalResult.win,
      );
    });

    test('side to move is preserved as part of theoretical truth', () {
      expect(keySquaresLesson01.sideToMove, ChessSide.white);

      expect(
        keySquaresLesson01.comparisonOutcomes.single.sideToMove,
        ChessSide.black,
      );
    });

    test('both positions retain the same initial physical key squares', () {
      expect(keySquaresLesson01.initialKeySquares, <String>{'c6', 'd6', 'e6'});

      expect(keySquaresLesson01.initialKeySquares.contains('d5'), isFalse);
    });

    test('unknown FEN has no invented theoretical result', () {
      expect(
        keySquaresLesson01.theoreticalResultForFen(
          '8/3k4/8/3KP3/8/8/8/8 b - - 0 1',
        ),
        isNull,
      );
    });
  });
}
