/// Computes pedagogical key squares for the simple king-and-pawn
/// positions used by the first Key Squares lesson.
///
/// Phase 3.3 deliberately supports only:
///
/// - one white pawn;
/// - non-rook pawns (files b through g);
/// - pawn ranks currently needed by this lesson.
///
/// Unsupported positions return an empty set rather than inventing theory.
class KeySquaresRule {
  const KeySquaresRule();

  /// Returns the key squares associated with [pawnSquare].
  ///
  /// This rule is intentionally conservative.
  Set<String> forWhitePawn(String pawnSquare) {
    final square = pawnSquare.trim().toLowerCase();

    if (!_isValidSquare(square)) {
      return const <String>{};
    }

    final fileIndex = square.codeUnitAt(0) - 'a'.codeUnitAt(0);

    final rank = int.parse(square[1]);

    // Rook pawns have important special cases and are deliberately
    // excluded from this first generic rule.
    if (fileIndex == 0 || fileIndex == 7) {
      return const <String>{};
    }

    // Initial teaching rule:
    //
    // Pawn on ranks 2, 3 or 4:
    // key squares are two ranks ahead.
    //
    // Example:
    //
    // d4 -> c6, d6, e6
    if (rank >= 2 && rank <= 4) {
      return _threeSquares(fileIndex: fileIndex, targetRank: rank + 2);
    }

    // For now, later pawn ranks are intentionally unsupported.
    //
    // We will add them only when the corresponding Dvoretsky teaching
    // position is introduced and tested.
    return const <String>{};
  }

  Set<String> _threeSquares({required int fileIndex, required int targetRank}) {
    final result = <String>{};

    for (final offset in const <int>[-1, 0, 1]) {
      final targetFile = fileIndex + offset;

      if (targetFile < 0 || targetFile > 7) {
        continue;
      }

      final file = String.fromCharCode('a'.codeUnitAt(0) + targetFile);

      result.add('$file$targetRank');
    }

    return Set<String>.unmodifiable(result);
  }

  bool _isValidSquare(String square) {
    if (square.length != 2) {
      return false;
    }

    final file = square.codeUnitAt(0);

    final rank = square.codeUnitAt(1);

    return file >= 'a'.codeUnitAt(0) &&
        file <= 'h'.codeUnitAt(0) &&
        rank >= '1'.codeUnitAt(0) &&
        rank <= '8'.codeUnitAt(0);
  }
}
