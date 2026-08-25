import 'package:endgame_mastery/core/chess/chess_controller.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_positions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Exact lesson start positions', () {
    test('lesson 1 always starts from the requested d-pawn position', () {
      const fen = '8/3k4/8/3P4/3K4/8/8/8 w - - 0 1';

      for (final position in keySquaresLesson01Positions) {
        expect(position.fen, fen);
      }

      final controller = ChessController(fen: fen);

      final blackKing = controller.pieceVisualAt('d7');
      final whitePawn = controller.pieceVisualAt('d5');
      final whiteKing = controller.pieceVisualAt('d4');

      expect(blackKing?.type, BoardPieceType.king);
      expect(blackKing?.isWhite, isFalse);
      expect(whitePawn?.type, BoardPieceType.pawn);
      expect(whitePawn?.isWhite, isTrue);
      expect(whiteKing?.type, BoardPieceType.king);
      expect(whiteKing?.isWhite, isTrue);
      expect(controller.isWhiteToMove(), isTrue);
    });

    test('lesson 2 always starts from the requested b-pawn position', () {
      const fen = '1k6/8/1P6/1K6/8/8/8/8 w - - 0 1';

      for (final position in keySquaresLesson02Positions) {
        expect(position.fen, fen);
      }

      final controller = ChessController(fen: fen);

      final blackKing = controller.pieceVisualAt('b8');
      final whitePawn = controller.pieceVisualAt('b6');
      final whiteKing = controller.pieceVisualAt('b5');

      expect(blackKing?.type, BoardPieceType.king);
      expect(blackKing?.isWhite, isFalse);
      expect(whitePawn?.type, BoardPieceType.pawn);
      expect(whitePawn?.isWhite, isTrue);
      expect(whiteKing?.type, BoardPieceType.king);
      expect(whiteKing?.isWhite, isTrue);
      expect(controller.isWhiteToMove(), isTrue);
    });
  });
}
