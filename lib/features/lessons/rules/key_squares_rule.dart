/// Computes pedagogical key squares for the simple king-and-pawn
/// positions used by the Key Squares curriculum.
///
/// The rule is deliberately conservative:
///
/// - one white pawn;
/// - non-rook pawns (files b through g);
/// - only pawn ranks explicitly supported by verified curriculum theory.
///
/// Unsupported positions return an empty set rather than inventing theory.
class KeySquaresRule {
  const KeySquaresRule();

  /// Returns the key squares associated with [pawnSquare].
  Set<String> forWhitePawn(String pawnSquare) {
    final square = pawnSquare.trim().toLowerCase();

    if (!_isValidSquare(square)) {
      return const <String>{};
    }

    final fileIndex = square.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = int.parse(square[1]);

    // Rook pawns have important special cases and are deliberately excluded
    // from this generic rule.
    if (fileIndex == 0 || fileIndex == 7) {
      return const <String>{};
    }

    // Pawn on ranks 2, 3 or 4:
    //
    // The key squares are the three squares two ranks ahead.
    //
    // Example:
    //
    // d4 -> c6, d6, e6
    if (rank >= 2 && rank <= 4) {
      return _threeSquares(fileIndex: fileIndex, targetRank: rank + 2);
    }

    // Pawn on the 5th rank:
    //
    // Verified Key Squares theory gives six key squares:
    // the three adjacent files on both the 6th and 7th ranks.
    //
    // Example:
    //
    // d5 -> c6, d6, e6, c7, d7, e7
    if (rank == 5) {
      return Set<String>.unmodifiable({
        ..._threeSquares(fileIndex: fileIndex, targetRank: 6),
        ..._threeSquares(fileIndex: fileIndex, targetRank: 7),
      });
    }

    // Later ranks remain unsupported until their specific theory,
    // including promotion and edge cases, is introduced and tested.
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
