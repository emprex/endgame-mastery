import 'package:chess/chess.dart' as chess_lib;
import 'package:endgame_mastery/features/coach/domain/coach_game.dart';
import 'package:endgame_mastery/features/coach/domain/reconstructed_move.dart';

class GameReconstructor {
  const GameReconstructor();

  List<ReconstructedMove> reconstruct(CoachGame game) {
    final setupFen = game.headers['SetUp'] == '1' ? game.headers['FEN'] : null;
    final board = setupFen == null
        ? chess_lib.Chess()
        : chess_lib.Chess.fromFEN(setupFen);
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

      final playedMove = board.history.last.move;
      final promotion = _promotionSuffix(playedMove.promotion);
      final uci = '${playedMove.fromAlgebraic}${playedMove.toAlgebraic}$promotion';

      reconstructed.add(
        ReconstructedMove(
          ply: index + 1,
          san: san,
          uci: uci,
          fenBefore: fenBefore,
          fenAfter: board.fen,
        ),
      );
    }

    return List.unmodifiable(reconstructed);
  }

  String _promotionSuffix(chess_lib.PieceType? promotion) {
    if (promotion == chess_lib.PieceType.QUEEN) return 'q';
    if (promotion == chess_lib.PieceType.ROOK) return 'r';
    if (promotion == chess_lib.PieceType.BISHOP) return 'b';
    if (promotion == chess_lib.PieceType.KNIGHT) return 'n';
    return '';
  }
}
