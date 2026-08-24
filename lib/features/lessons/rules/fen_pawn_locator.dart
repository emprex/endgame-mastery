/// Minimal FEN helper used by pedagogical rules.
///
/// This does not replace ChessController and does not validate move legality.
/// It only locates pawns in the board portion of a valid FEN.
class FenPawnLocator {
  const FenPawnLocator();

  List<String> whitePawns(String fen) {
    final fields = fen.trim().split(RegExp(r'\s+'));

    if (fields.isEmpty) {
      return const <String>[];
    }

    final ranks = fields.first.split('/');

    if (ranks.length != 8) {
      return const <String>[];
    }

    final result = <String>[];

    for (var rankIndex = 0; rankIndex < 8; rankIndex++) {
      final fenRank = ranks[rankIndex];

      var fileIndex = 0;

      for (final rune in fenRank.runes) {
        final character = String.fromCharCode(rune);

        final emptyCount = int.tryParse(character);

        if (emptyCount != null) {
          fileIndex += emptyCount;
          continue;
        }

        if (character == 'P') {
          final file = String.fromCharCode('a'.codeUnitAt(0) + fileIndex);

          final rank = 8 - rankIndex;

          result.add('$file$rank');
        }

        fileIndex++;
      }
    }

    return List<String>.unmodifiable(result);
  }
}
