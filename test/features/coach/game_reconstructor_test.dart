import 'package:endgame_mastery/features/coach/data/game_reconstructor.dart';
import 'package:endgame_mastery/features/coach/data/pgn_game_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = PgnGameParser();
  const reconstructor = GameReconstructor();

  test('reconstructs every legal position in move order', () {
    final game = parser.parse('1. e4 e5 2. Nf3 Nc6 3. Bb5 a6');

    final moves = reconstructor.reconstruct(game);

    expect(moves, hasLength(6));
    expect(moves.first.ply, 1);
    expect(moves.first.san, 'e4');
    expect(moves.first.wasWhiteMove, isTrue);
    expect(moves.first.fenBefore.split(' ')[1], 'w');
    expect(moves.first.fenAfter.split(' ')[1], 'b');
    expect(moves.last.fullMoveNumber, 3);
  });

  test('fails closed when a SAN move is illegal', () {
    final game = parser.parse('1. e4 e5 2. Bh6');

    expect(
      () => reconstructor.reconstruct(game),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('Invalid move at ply 3'),
        ),
      ),
    );
  });
}
