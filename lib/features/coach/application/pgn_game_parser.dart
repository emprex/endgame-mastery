import 'package:chess/chess.dart' as chess;
import 'package:endgame_mastery/features/coach/domain/imported_game.dart';

class PgnParseException implements Exception {
  const PgnParseException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PgnGameParser {
  const PgnGameParser();

  ImportedGame parse(String rawPgn) {
    final normalized = rawPgn.trim();

    if (normalized.isEmpty) {
      throw const PgnParseException('Paste a chess game in PGN format first.');
    }

    final game = chess.Chess();

    try {
      final loaded = game.load_pgn(normalized);

      if (!loaded) {
        throw const PgnParseException(
          'This PGN could not be read. Check that the full game was copied.',
        );
      }
    } on PgnParseException {
      rethrow;
    } catch (_) {
      throw const PgnParseException(
        'This PGN could not be read. Check that the full game was copied.',
      );
    }

    final moves = game.san_moves().whereType<String>().toList(growable: false);

    if (moves.isEmpty) {
      throw const PgnParseException(
        'The PGN is valid but it does not contain any moves to analyze.',
      );
    }

    final headers = <String, String>{};

    game.header.forEach((key, value) {
      if (key is String && value != null) {
        headers[key] = value.toString();
      }
    });

    return ImportedGame(
      rawPgn: normalized,
      headers: headers,
      moves: moves,
    );
  }
}
