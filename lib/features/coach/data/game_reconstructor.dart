import 'package:chess/chess.dart' as chess_lib;
import 'package:endgame_mastery/features/coach/domain/coach_game.dart';
import 'package:endgame_mastery/features/coach/domain/reconstructed_move.dart';

class GameReconstructor {
  const GameReconstructor();

  List<ReconstructedMove> reconstruct(CoachGame game) {
    final board = chess_lib.Chess();
    final reconstructed = <ReconstructedMove>[];

    for (var index = 0; index < game.moves.length; index++) {
      final san = game.moves[index];
      final fenBefore = board.fen;
      final accepted = board.move(san);

      if (!accepted) {
        throw FormatException(
          'Invalid move at ply ${index + 1}: $san',
        );
      }

      reconstructed.add(
        ReconstructedMove(
          ply: index + 1,
          san: san,
          fenBefore: fenBefore,
          fenAfter: board.fen,
        ),
      );
    }

    return List.unmodifiable(reconstructed);
  }
}
