import 'package:endgame_mastery/app/endgame_mastery_app.dart';
import 'package:endgame_mastery/core/chess/chess_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const promotionFen = '7k/4P3/8/8/8/8/8/4K3 w - - 0 1';

  const checkmateFen = '7k/6Q1/5K2/8/8/8/8/8 b - - 0 1';

  const stalemateFen = '7k/5Q2/6K1/8/8/8/8/8 b - - 0 1';

  const insufficientMaterialFen = '8/8/8/8/8/2k5/8/2K5 w - - 0 1';

  testWidgets('Chess Coach opens the PGN analysis home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EndgameMasteryApp());

    await tester.pumpAndSettle();

    expect(find.text('Chess Coach'), findsOneWidget);
    expect(find.text('Paste your game'), findsOneWidget);
    expect(find.text('Analyze Game'), findsOneWidget);
  });

  testWidgets('a pasted PGN is imported for analysis', (
    WidgetTester tester,
  ) async {
    const pgn = '''
[White "WhitePlayer"]
[Black "BlackPlayer"]
[Result "1-0"]

1. e4 e5 2. Nf3 Nc6 1-0
''';

    await tester.pumpWidget(const EndgameMasteryApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('coach-pgn-input')),
      pgn,
    );

    final analyzeButton = find.byKey(
      const ValueKey<String>('coach-analyze-button'),
    );

    await tester.ensureVisible(analyzeButton);
    await tester.tap(analyzeButton);
    await tester.pumpAndSettle();

    expect(find.text('Game imported'), findsOneWidget);
    expect(find.text('WhitePlayer vs BlackPlayer'), findsOneWidget);
    expect(find.text('2 moves'), findsOneWidget);
    expect(find.text('Ready for full analysis.'), findsOneWidget);
  });

  test('Dvoretsky position loads correctly', () {
    final controller = ChessController();

    expect(controller.pieceVisualAt('d5')?.type, BoardPieceType.king);

    expect(controller.pieceVisualAt('d4')?.type, BoardPieceType.pawn);

    expect(controller.pieceVisualAt('d7')?.type, BoardPieceType.king);

    expect(controller.isWhiteToMove(), isTrue);
  });

  test('e7-e8 requires explicit promotion', () {
    final controller = ChessController(fen: promotionFen);

    expect(controller.isPromotionMove(from: 'e7', to: 'e8'), isTrue);

    expect(controller.move(from: 'e7', to: 'e8'), isFalse);

    expect(controller.pieceVisualAt('e7')?.type, BoardPieceType.pawn);
  });

  test('explicit knight promotion works', () {
    final controller = ChessController(fen: promotionFen);

    expect(controller.move(from: 'e7', to: 'e8', promotion: 'n'), isTrue);

    expect(controller.pieceVisualAt('e8')?.type, BoardPieceType.knight);
  });

  test('explicit rook promotion works', () {
    final controller = ChessController(fen: promotionFen);

    expect(controller.move(from: 'e7', to: 'e8', promotion: 'r'), isTrue);

    expect(controller.pieceVisualAt('e8')?.type, BoardPieceType.rook);
  });

  test('explicit bishop promotion works', () {
    final controller = ChessController(fen: promotionFen);

    expect(controller.move(from: 'e7', to: 'e8', promotion: 'b'), isTrue);

    expect(controller.pieceVisualAt('e8')?.type, BoardPieceType.bishop);
  });

  test('explicit queen promotion works', () {
    final controller = ChessController(fen: promotionFen);

    expect(controller.move(from: 'e7', to: 'e8', promotion: 'q'), isTrue);

    expect(controller.pieceVisualAt('e8')?.type, BoardPieceType.queen);
  });

  test('checkmate is detected', () {
    final controller = ChessController(fen: checkmateFen);

    expect(controller.gameEndState(), GameEndState.checkmate);

    expect(controller.isGameOver(), isTrue);
  });

  test('stalemate is detected', () {
    final controller = ChessController(fen: stalemateFen);

    expect(controller.gameEndState(), GameEndState.stalemate);

    expect(controller.isGameOver(), isTrue);
  });

  test('insufficient material is detected as draw', () {
    final controller = ChessController(fen: insufficientMaterialFen);

    expect(controller.gameEndState(), GameEndState.draw);

    expect(controller.isGameOver(), isTrue);
  });
}
