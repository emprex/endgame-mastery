import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Key Squares theoretical truth', () {
    const whiteToMoveFen = '8/3k4/8/3K4/3P4/8/8/8 w - - 0 1';
    const blackToMoveFen = '8/3k4/8/3K4/3P4/8/8/8 b - - 0 1';

    test('Diagram 1-1 with White to move is theoretically drawn', () {
      expect(
        keySquaresLesson01.theoreticalResultForFen(whiteToMoveFen),
        TheoreticalResult.draw,
      );
    });

    test('same geometry with Black to move is a White win', () {
      expect(
        keySquaresLesson01.theoreticalResultForFen(blackToMoveFen),
        TheoreticalResult.win,
      );
    });

    test('side to move is preserved', () {
      expect(keySquaresLesson01.sideToMove, ChessSide.white);
    });

    test('pawn on d4 uses the three book key squares', () {
      expect(keySquaresLesson01.initialKeySquares, <String>{'c6', 'd6', 'e6'});
    });

    test('unknown FEN has no invented theoretical result', () {
      expect(
        keySquaresLesson01.theoreticalResultForFen(
          '8/3k4/8/4K3/3P4/8/8/8 w - - 0 1',
        ),
        isNull,
      );
    });
  });
}
