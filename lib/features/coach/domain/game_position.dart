enum CoachGameSide {
  white,
  black,
}

class GamePosition {
  const GamePosition({
    required this.ply,
    required this.moveNumber,
    required this.side,
    required this.san,
    required this.fenBefore,
    required this.fenAfter,
  });

  final int ply;
  final int moveNumber;
  final CoachGameSide side;
  final String san;
  final String fenBefore;
  final String fenAfter;

  String get moveLabel {
    final separator = side == CoachGameSide.white ? '.' : '...';
    return '$moveNumber$separator $san';
  }
}
