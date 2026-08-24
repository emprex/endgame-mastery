import 'package:endgame_mastery/core/engine/engine_move.dart';

/// Parses Stockfish UCI `bestmove` responses.
///
/// Supported examples:
///
/// bestmove d7c7
/// bestmove e2e1q
/// bestmove d7c7 ponder e1e2
///
/// A response such as:
///
/// bestmove (none)
///
/// means that Stockfish has no legal move to return.
class UciBestMoveParser {
  const UciBestMoveParser._();

  static EngineMove? parse(
    String line,
  ) {
    final normalized = line.trim();

    if (!normalized.startsWith(
      'bestmove ',
    )) {
      return null;
    }

    final parts =
        normalized.split(
      RegExp(r'\s+'),
    );

    if (parts.length < 2) {
      return null;
    }

    final uciMove = parts[1];

    if (uciMove == '(none)' ||
        uciMove == '0000') {
      return null;
    }

    return parseUciMove(
      uciMove,
    );
  }

  /// Parses one UCI move token.
  ///
  /// Normal move:
  /// d7c7
  ///
  /// Promotion:
  /// e2e1q
  static EngineMove? parseUciMove(
    String uciMove,
  ) {
    final normalized =
        uciMove.trim().toLowerCase();

    if (normalized.length != 4 &&
        normalized.length != 5) {
      return null;
    }

    final from =
        normalized.substring(0, 2);

    final to =
        normalized.substring(2, 4);

    if (!_isSquare(from) ||
        !_isSquare(to)) {
      return null;
    }

    String? promotion;

    if (normalized.length == 5) {
      promotion =
          normalized.substring(4);

      if (!_isPromotionPiece(
        promotion,
      )) {
        return null;
      }
    }

    return EngineMove(
      from: from,
      to: to,
      promotion: promotion,
    );
  }

  static bool _isSquare(
    String square,
  ) {
    if (square.length != 2) {
      return false;
    }

    final file = square[0];

    final rank = square[1];

    return 'abcdefgh'.contains(
          file,
        ) &&
        '12345678'.contains(
          rank,
        );
  }

  static bool _isPromotionPiece(
    String piece,
  ) {
    return piece == 'q' ||
        piece == 'r' ||
        piece == 'b' ||
        piece == 'n';
  }
}
