import 'package:endgame_mastery/core/chess/chess_controller.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_positions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Exact first six lesson positions', () {
    test('lesson 1 starts from the requested d-pawn position', () {
      const fen = '8/3k4/8/3P4/3K4/8/8/8 w - - 0 1';
      expect(keySquaresLesson01.fen, fen);

      final controller = ChessController(fen: fen);
      expect(controller.pieceVisualAt('d7')?.isWhite, isFalse);
      expect(controller.pieceVisualAt('d5')?.type, BoardPieceType.pawn);
      expect(controller.pieceVisualAt('d5')?.isWhite, isTrue);
      expect(controller.pieceVisualAt('d4')?.type, BoardPieceType.king);
      expect(controller.pieceVisualAt('d4')?.isWhite, isTrue);
      expect(controller.isWhiteToMove(), isTrue);
    });

    test('lesson 2 starts from Diagram 1-2: Kb6 Pb5 vs Kb8', () {
      const fen = '1k6/8/1K6/1P6/8/8/8/8 w - - 0 1';
      expect(keySquaresLesson02.fen, fen);

      final controller = ChessController(fen: fen);
      final blackKing = controller.pieceVisualAt('b8');
      final whiteKing = controller.pieceVisualAt('b6');
      final whitePawn = controller.pieceVisualAt('b5');

      expect(blackKing?.type, BoardPieceType.king);
      expect(blackKing?.isWhite, isFalse);
      expect(whiteKing?.type, BoardPieceType.king);
      expect(whiteKing?.isWhite, isTrue);
      expect(whitePawn?.type, BoardPieceType.pawn);
      expect(whitePawn?.isWhite, isTrue);
      expect(controller.isWhiteToMove(), isTrue);
    });

    test('lessons 3 to 6 preserve their exact starting FENs', () {
      expect(keySquaresLesson03.fen, '5k2/8/8/8/1P6/8/8/3K4 w - - 0 1');
      expect(keySquaresLesson04.fen, '2k5/8/8/7p/8/8/6P1/5K2 w - - 0 1');
      expect(pawnTragicomedyLesson05.fen, '8/8/3p4/3P4/5k2/3K4/8/8 w - - 0 1');
      expect(pawnTragicomedyLesson06.fen, '8/8/5pk1/5r2/R7/5K2/8/8 w - - 0 1');
    });

    test('lesson 2 prove returns to the exact Diagram 1-2 position', () {
      final prove = keySquaresLesson02Positions.singleWhere(
        (position) => position.id == 'pawn-key-squares-02d',
      );
      expect(prove.fen, '1k6/8/1K6/1P6/8/8/8/8 w - - 0 1');
    });
  });
}
