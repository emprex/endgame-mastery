import 'package:chess/chess.dart' as chess;
import 'package:endgame_mastery/features/coach/domain/game_position.dart';
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

    final timeline = _buildTimeline(
      headers: headers,
      moves: moves,
    );

    return ImportedGame(
      rawPgn: normalized,
      headers: headers,
      moves: moves,
      positions: timeline.positions,
      initialFen: timeline.initialFen,
      finalFen: timeline.finalFen,
    );
  }

  _PositionTimeline _buildTimeline({
    required Map<String, String> headers,
    required List<String> moves,
  }) {
    final setupFen = headers['FEN']?.trim();
    final useSetupFen =
        headers['SetUp'] == '1' && setupFen != null && setupFen.isNotEmpty;

    late final chess.Chess replay;

    try {
      replay = useSetupFen ? chess.Chess.fromFEN(setupFen) : chess.Chess();
    } catch (_) {
      throw const PgnParseException(
        'The PGN contains an invalid starting position.',
      );
    }

    final initialFen = replay.fen;
    final positions = <GamePosition>[];

    for (var index = 0; index < moves.length; index++) {
      final san = moves[index];
      final fenBefore = replay.fen;
      final fenFields = fenBefore.trim().split(RegExp(r'\s+'));

      if (fenFields.length < 6) {
        throw const PgnParseException(
          'The game produced an invalid position while being prepared.',
        );
      }

      final side = fenFields[1] == 'b' ? CoachGameSide.black : CoachGameSide.white;
      final moveNumber = int.tryParse(fenFields[5]);

      if (moveNumber == null) {
        throw const PgnParseException(
          'The game produced an invalid move number while being prepared.',
        );
      }

      final moved = replay.move(san);

      if (!moved) {
        throw PgnParseException(
          'The move $san could not be replayed while preparing the analysis.',
        );
      }

      positions.add(
        GamePosition(
          ply: index + 1,
          moveNumber: moveNumber,
          side: side,
          san: san,
          fenBefore: fenBefore,
          fenAfter: replay.fen,
        ),
      );
    }

    return _PositionTimeline(
      initialFen: initialFen,
      finalFen: replay.fen,
      positions: positions,
    );
  }
}

class _PositionTimeline {
  const _PositionTimeline({
    required this.initialFen,
    required this.finalFen,
    required this.positions,
  });

  final String initialFen;
  final String finalFen;
  final List<GamePosition> positions;
}
