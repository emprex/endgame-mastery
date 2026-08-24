import 'package:chess/chess.dart' as chess;
import 'package:endgame_mastery/core/engine/chess_engine.dart';
import 'package:endgame_mastery/core/engine/engine_config.dart';
import 'package:endgame_mastery/core/engine/engine_exception.dart';
import 'package:endgame_mastery/core/engine/engine_move.dart';

/// Temporary deterministic engine used only to validate
/// the Phase 2 UI/orchestration pipeline.
///
/// This is NOT Stockfish.
///
/// It selects the first legal move returned by package:chess
/// after a short asynchronous delay.
class LegalMoveTestEngine implements ChessEngine {
  bool _initialized = false;
  bool _disposed = false;

  @override
  Future<void> initialize() async {
    if (_disposed) {
      throw const EngineDisposedException();
    }

    _initialized = true;
  }

  @override
  Future<EngineMove> bestMove({
    required String fen,
    required EngineConfig config,
  }) async {
    if (_disposed) {
      throw const EngineDisposedException();
    }

    if (!_initialized) {
      throw const EngineInitializationException(
        'Engine has not been initialized.',
      );
    }

    await Future<void>.delayed(
      config.moveTime,
    );

    final game = chess.Chess.fromFEN(fen);

    final moves = game.moves({
      'verbose': true,
    });

    if (moves.isEmpty) {
      throw const EngineSearchException(
        'Position has no legal moves.',
      );
    }

    final move = moves.first;

    final from = move['from'];
    final to = move['to'];

    if (from is! String || to is! String) {
      throw const EngineSearchException(
        'Could not parse legal engine move.',
      );
    }

    return EngineMove(
      from: from,
      to: to,
      promotion: _promotionCode(
        move['promotion'],
      ),
    );
  }

  String? _promotionCode(
    Object? promotion,
  ) {
    if (promotion == null) {
      return null;
    }

    final value =
        promotion.toString().toLowerCase();

    if (value == 'q' ||
        value.contains('queen')) {
      return 'q';
    }

    if (value == 'r' ||
        value.contains('rook')) {
      return 'r';
    }

    if (value == 'b' ||
        value.contains('bishop')) {
      return 'b';
    }

    if (value == 'n' ||
        value.contains('knight')) {
      return 'n';
    }

    return null;
  }

  @override
  Future<void> stop() async {
    // Nothing to terminate in this temporary test engine.
    //
    // GameEngineController request IDs are responsible
    // for rejecting a stale result after reset/stop.
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
  }
}
