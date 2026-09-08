import 'package:endgame_mastery/features/coach/domain/coach_game.dart';

class PgnGameParser {
  const PgnGameParser();

  static final RegExp _headerPattern = RegExp(
    r'^\[([A-Za-z0-9_]+)\s+"(.*)"\]\s*$',
  );

  CoachGame parse(String input) {
    final pgn = input.trim();
    if (pgn.isEmpty) {
      throw const FormatException('Paste a PGN game first.');
    }

    final headers = <String, String>{};
    final moveLines = <String>[];

    for (final line in pgn.split(RegExp(r'\r?\n'))) {
      final trimmed = line.trim();
      final match = _headerPattern.firstMatch(trimmed);
      if (match != null) {
        headers[match.group(1)!] = match.group(2)!;
      } else if (trimmed.isNotEmpty) {
        moveLines.add(trimmed);
      }
    }

    var movetext = moveLines.join(' ');
    movetext = _removeBraceComments(movetext);
    movetext = movetext.replaceAll(RegExp(r';[^\r\n]*'), ' ');
    movetext = _removeVariations(movetext);
    movetext = movetext.replaceAll(RegExp(r'\$\d+'), ' ');
    movetext = movetext.replaceAll(RegExp(r'\d+\.(?:\.\.)?'), ' ');

    const results = {'1-0', '0-1', '1/2-1/2', '*'};
    final moves = <String>[];

    for (final token in movetext.split(RegExp(r'\s+'))) {
      final move = token.trim();
      if (move.isEmpty || results.contains(move)) {
        continue;
      }
      moves.add(move);
    }

    if (moves.isEmpty) {
      throw const FormatException(
        'No moves were found. Paste a complete PGN or move list.',
      );
    }

    return CoachGame(
      headers: Map.unmodifiable(headers),
      moves: List.unmodifiable(moves),
      rawPgn: pgn,
    );
  }

  String _removeBraceComments(String value) {
    return value.replaceAll(RegExp(r'\{[^}]*\}'), ' ');
  }

  String _removeVariations(String value) {
    final buffer = StringBuffer();
    var depth = 0;

    for (final rune in value.runes) {
      final character = String.fromCharCode(rune);
      if (character == '(') {
        depth += 1;
        continue;
      }
      if (character == ')') {
        if (depth > 0) depth -= 1;
        continue;
      }
      if (depth == 0) buffer.write(character);
    }

    return buffer.toString();
  }
}
