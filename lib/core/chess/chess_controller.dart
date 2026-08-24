import 'package:chess/chess.dart' as chess;

enum BoardPieceType {
  king,
  queen,
  rook,
  bishop,
  knight,
  pawn,
}

class BoardPieceVisual {
  const BoardPieceVisual({
    required this.type,
    required this.isWhite,
  });

  final BoardPieceType type;
  final bool isWhite;
}

enum GameEndState {
  none,
  checkmate,
  stalemate,
  draw,
}

class ChessController {
  static const String defaultFen =
      '8/3k4/8/3K4/3P4/8/8/8 w - - 0 1';

  final String initialFen;

  late chess.Chess game;

  ChessController({
    String? fen,
  }) : initialFen = fen ?? defaultFen {
    reset();
  }

  void reset() {
    game = chess.Chess.fromFEN(initialFen);
  }

  bool isWhiteToMove() {
    return game.turn == chess.Color.WHITE;
  }

  bool isInCheck() {
    return game.in_check;
  }

  bool isPromotionMove({
    required String from,
    required String to,
  }) {
    final piece = game.get(from);

    if (piece == null) {
      return false;
    }

    if (piece.type != chess.PieceType.PAWN) {
      return false;
    }

    final targetRank = to.substring(1);

    if (piece.color == chess.Color.WHITE) {
      return targetRank == '8';
    }

    return targetRank == '1';
  }

  String turnText() {
    final endState = gameEndState();

    switch (endState) {
      case GameEndState.checkmate:
        return 'Checkmate';

      case GameEndState.stalemate:
        return 'Stalemate';

      case GameEndState.draw:
        return 'Draw';

      case GameEndState.none:
        break;
    }

    final base =
        isWhiteToMove()
            ? 'White to move'
            : 'Black to move';

    if (isInCheck()) {
      return '$base • Check!';
    }

    return base;
  }

  GameEndState gameEndState() {
    if (game.in_checkmate) {
      return GameEndState.checkmate;
    }

    if (game.in_stalemate) {
      return GameEndState.stalemate;
    }

    if (game.in_draw) {
      return GameEndState.draw;
    }

    return GameEndState.none;
  }

  bool isGameOver() {
    return gameEndState() !=
        GameEndState.none;
  }

  BoardPieceVisual? pieceVisualAt(
    String square,
  ) {
    final piece = game.get(square);

    if (piece == null) {
      return null;
    }

    final isWhite =
        piece.color ==
        chess.Color.WHITE;

    final type =
        switch (piece.type) {
      chess.PieceType.KING =>
        BoardPieceType.king,

      chess.PieceType.QUEEN =>
        BoardPieceType.queen,

      chess.PieceType.ROOK =>
        BoardPieceType.rook,

      chess.PieceType.BISHOP =>
        BoardPieceType.bishop,

      chess.PieceType.KNIGHT =>
        BoardPieceType.knight,

      chess.PieceType.PAWN =>
        BoardPieceType.pawn,

      _ => BoardPieceType.pawn,
    };

    return BoardPieceVisual(
      type: type,
      isWhite: isWhite,
    );
  }

  bool canSelect(String square) {
    if (isGameOver()) {
      return false;
    }

    final piece = game.get(square);

    if (piece == null) {
      return false;
    }

    return piece.color == game.turn;
  }

  Set<String> legalTargets(
    String square,
  ) {
    final moves = game.moves({
      'square': square,
      'verbose': true,
    });

    final result = <String>{};

    for (final move in moves) {
      final target = move['to'];

      if (target is String) {
        result.add(target);
      }
    }

    return result;
  }

  bool move({
    required String from,
    required String to,
    String? promotion,
  }) {
    final legal =
        legalTargets(from);

    if (!legal.contains(to)) {
      return false;
    }

    final promotionRequired =
        isPromotionMove(
      from: from,
      to: to,
    );

    if (promotionRequired &&
        promotion == null) {
      return false;
    }

    final moveData =
        <String, dynamic>{
      'from': from,
      'to': to,
    };

    if (promotionRequired) {
      moveData['promotion'] =
          promotion;
    }

    game.move(moveData);

    return true;
  }

  String? checkedKingSquare() {
    if (!isInCheck()) {
      return null;
    }

    final checkedColor =
        game.turn;

    const files =
        'abcdefgh';

    for (
      int fileIndex = 0;
      fileIndex < files.length;
      fileIndex++
    ) {
      final file =
          files[fileIndex];

      for (
        int rank = 1;
        rank <= 8;
        rank++
      ) {
        final square =
            '$file$rank';

        final piece =
            game.get(square);

        if (piece == null) {
          continue;
        }

        if (piece.type ==
                chess.PieceType.KING &&
            piece.color ==
                checkedColor) {
          return square;
        }
      }
    }

    return null;
  }
}
