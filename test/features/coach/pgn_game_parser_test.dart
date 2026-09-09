import 'package:endgame_mastery/features/coach/application/pgn_game_parser.dart';
import 'package:endgame_mastery/features/coach/domain/game_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = PgnGameParser();

  const pgn = '''
[Event "Rapid Game"]
[Site "Chess.com"]
[Date "2026.09.08"]
[White "WhitePlayer"]
[Black "BlackPlayer"]
[Result "1-0"]

1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 1-0
''';

  test('parses a complete PGN into coach input data', () {
    final game = parser.parse(pgn);

    expect(game.white, 'WhitePlayer');
    expect(game.black, 'BlackPlayer');
    expect(game.result, '1-0');
    expect(game.event, 'Rapid Game');
    expect(game.date, '2026.09.08');
    expect(game.moves, <String>['e4', 'e5', 'Nf3', 'Nc6', 'Bb5', 'a6']);
    expect(game.plyCount, 6);
    expect(game.fullMoveCount, 3);
    expect(game.analysisPositionCount, 6);
  });

  test('builds an exact FEN timeline for every half-move', () {
    final game = parser.parse(pgn);

    expect(game.positions, hasLength(6));

    final first = game.positions.first;
    expect(first.ply, 1);
    expect(first.moveNumber, 1);
    expect(first.side, CoachGameSide.white);
    expect(first.san, 'e4');
    expect(first.moveLabel, '1. e4');
    expect(first.fenBefore, game.initialFen);
    expect(first.fenAfter, isNot(first.fenBefore));

    final second = game.positions[1];
    expect(second.ply, 2);
    expect(second.moveNumber, 1);
    expect(second.side, CoachGameSide.black);
    expect(second.san, 'e5');
    expect(second.moveLabel, '1... e5');
    expect(second.fenBefore, first.fenAfter);

    expect(game.positions.last.fenAfter, game.finalFen);
  });

  test('rejects empty PGN input', () {
    expect(
      () => parser.parse('   '),
      throwsA(
        isA<PgnParseException>().having(
          (error) => error.message,
          'message',
          'Paste a chess game in PGN format first.',
        ),
      ),
    );
  });
}
