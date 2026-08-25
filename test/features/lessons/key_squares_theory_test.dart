import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Key Squares theoretical truth', () {
    const correctedFen = '8/3k4/8/3P4/3K4/8/8/8 w - - 0 1';

    test('corrected first position is theoretically drawn', () {
      expect(
        keySquaresLesson01.theoreticalResultForFen(correctedFen),
        TheoreticalResult.draw,
      );
    });

    test('side to move is preserved', () {
      expect(keySquaresLesson01.sideToMove, ChessSide.white);
    });

    test('fifth-rank pawn uses six physical key squares', () {
      expect(keySquaresLesson01.initialKeySquares, <String>{
        'c6', 'd6', 'e6', 'c7', 'd7', 'e7',
      });
    });

    test('unknown FEN has no invented theoretical result', () {
      expect(
        keySquaresLesson01.theoreticalResultForFen(
          '8/3k4/8/3P4/4K3/8/8/8 w - - 0 1',
        ),
        isNull,
      );
    });
  });
}
