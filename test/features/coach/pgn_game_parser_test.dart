import 'package:endgame_mastery/features/coach/application/pgn_game_parser.dart';
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
