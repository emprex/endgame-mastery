import 'package:endgame_mastery/app/endgame_mastery_app.dart';
import 'package:endgame_mastery/core/chess/chess_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const promotionFen =
      '7k/4P3/8/8/8/8/8/4K3 w - - 0 1';

  const checkmateFen =
      '7k/6Q1/5K2/8/8/8/8/8 b - - 0 1';

  const stalemateFen =
      '7k/5Q2/6K1/8/8/8/8/8 b - - 0 1';

  const insufficientMaterialFen =
      '8/8/8/8/8/2k5/8/2K5 w - - 0 1';

  // ---------------------------------------------------------------------------
  // APP / BOARD
  // ---------------------------------------------------------------------------

  testWidgets(
    'Endgame Mastery board loads',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const EndgameMasteryApp(),
      );

      // BoardScreen now initializes the chess engine asynchronously.
      //
      // The first frame may legitimately display:
      //
      //   Preparing engine…
      //
      // Give the initialization Future time to complete and then
      // render the resulting state.
      await tester.pumpAndSettle();

      expect(
        find.text('ENDGAME MASTERY'),
        findsOneWidget,
      );

      expect(
        find.text('White to move'),
        findsOneWidget,
      );
    },
  );

  // ---------------------------------------------------------------------------
  // DEFAULT DVORETSKY POSITION
  // ---------------------------------------------------------------------------

  test(
    'Dvoretsky position loads correctly',
    () {
      final controller =
          ChessController();

      expect(
        controller
            .pieceVisualAt('d5')
            ?.type,
        BoardPieceType.king,
      );

      expect(
        controller
            .pieceVisualAt('d4')
            ?.type,
        BoardPieceType.pawn,
      );

      expect(
        controller
            .pieceVisualAt('d7')
            ?.type,
        BoardPieceType.king,
      );

      expect(
        controller.isWhiteToMove(),
        isTrue,
      );
    },
  );

  // ---------------------------------------------------------------------------
  // PROMOTION
  // ---------------------------------------------------------------------------

  test(
    'e7-e8 requires explicit promotion',
    () {
      final controller =
          ChessController(
        fen: promotionFen,
      );

      expect(
        controller.isPromotionMove(
          from: 'e7',
          to: 'e8',
        ),
        isTrue,
      );

      expect(
        controller.move(
          from: 'e7',
          to: 'e8',
        ),
        isFalse,
      );

      expect(
        controller
            .pieceVisualAt('e7')
            ?.type,
        BoardPieceType.pawn,
      );
    },
  );

  test(
    'explicit knight promotion works',
    () {
      final controller =
          ChessController(
        fen: promotionFen,
      );

      expect(
        controller.move(
          from: 'e7',
          to: 'e8',
          promotion: 'n',
        ),
        isTrue,
      );

      expect(
        controller
            .pieceVisualAt('e8')
            ?.type,
        BoardPieceType.knight,
      );
    },
  );

  test(
    'explicit rook promotion works',
    () {
      final controller =
          ChessController(
        fen: promotionFen,
      );

      expect(
        controller.move(
          from: 'e7',
          to: 'e8',
          promotion: 'r',
        ),
        isTrue,
      );

      expect(
        controller
            .pieceVisualAt('e8')
            ?.type,
        BoardPieceType.rook,
      );
    },
  );

  test(
    'explicit bishop promotion works',
    () {
      final controller =
          ChessController(
        fen: promotionFen,
      );

      expect(
        controller.move(
          from: 'e7',
          to: 'e8',
          promotion: 'b',
        ),
        isTrue,
      );

      expect(
        controller
            .pieceVisualAt('e8')
            ?.type,
        BoardPieceType.bishop,
      );
    },
  );

  test(
    'explicit queen promotion works',
    () {
      final controller =
          ChessController(
        fen: promotionFen,
      );

      expect(
        controller.move(
          from: 'e7',
          to: 'e8',
          promotion: 'q',
        ),
        isTrue,
      );

      expect(
        controller
            .pieceVisualAt('e8')
            ?.type,
        BoardPieceType.queen,
      );
    },
  );

  // ---------------------------------------------------------------------------
  // GAME END STATES
  // ---------------------------------------------------------------------------

  test(
    'checkmate is detected',
    () {
      final controller =
          ChessController(
        fen: checkmateFen,
      );

      expect(
        controller.gameEndState(),
        GameEndState.checkmate,
      );

      expect(
        controller.isGameOver(),
        isTrue,
      );
    },
  );

  test(
    'stalemate is detected',
    () {
      final controller =
          ChessController(
        fen: stalemateFen,
      );

      expect(
        controller.gameEndState(),
        GameEndState.stalemate,
      );

      expect(
        controller.isGameOver(),
        isTrue,
      );
    },
  );

  test(
    'insufficient material is detected as draw',
    () {
      final controller =
          ChessController(
        fen: insufficientMaterialFen,
      );

      expect(
        controller.gameEndState(),
        GameEndState.draw,
      );

      expect(
        controller.isGameOver(),
        isTrue,
      );
    },
  );
}
