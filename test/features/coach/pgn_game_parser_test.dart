import 'package:endgame_mastery/features/coach/data/pgn_game_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = PgnGameParser();

  test('parses Chess.com style headers and main-line moves', () {
    const pgn = '''
[Site "Chess.com"]
[Date "2026-09-08"]
[White "Maci195701"]
[Black "emprexer"]
[Result "1/2-1/2"]
[WhiteElo "1362"]
[BlackElo "1376"]
[TimeControl "600"]

1. d4 d5 2. e3 c6 3. c4 Nf6 4. Nc3 e6 5. a3 Nbd7 1/2-1/2
''';

    final game = parser.parse(pgn);

    expect(game.white, 'Maci195701');
    expect(game.black, 'emprexer');
    expect(game.whiteElo, '1362');
    expect(game.blackElo, '1376');
    expect(game.result, '1/2-1/2');
    expect(game.timeControl, '600');
    expect(game.moves, [
      'd4',
      'd5',
      'e3',
      'c6',
      'c4',
      'Nf6',
      'Nc3',
      'e6',
      'a3',
      'Nbd7',
    ]);
    expect(game.fullMoveCount, 5);
  });

  test('removes comments, NAGs and side variations', () {
    const pgn = '''
1. e4 {main idea} e5 2. Nf3 Nc6 (2... Nf6 3. Nxe5) 3. Bb5 \$1 a6 1-0
''';

    final game = parser.parse(pgn);

    expect(game.moves, ['e4', 'e5', 'Nf3', 'Nc6', 'Bb5', 'a6']);
  });

  test('accepts compact move numbers', () {
    final game = parser.parse('1.e4 e5 2.Nf3 Nc6 3.Bb5 a6');

    expect(game.moves, ['e4', 'e5', 'Nf3', 'Nc6', 'Bb5', 'a6']);
  });

  test('rejects empty input', () {
    expect(() => parser.parse('   '), throwsFormatException);
  });

  test('rejects PGN headers without moves', () {
    expect(
      () => parser.parse('[White "Player"]\n[Black "Opponent"]'),
      throwsFormatException,
    );
  });
}
