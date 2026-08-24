import 'package:endgame_mastery/core/engine/engine_config.dart';
import 'package:endgame_mastery/core/engine/engine_move.dart';

abstract interface class ChessEngine {
  /// Starts the engine and waits until
  /// it is ready to accept searches.
  Future<void> initialize();

  /// Calculates a move from the supplied FEN.
  ///
  /// Implementations must never block
  /// Flutter's UI thread.
  Future<EngineMove> bestMove({
    required String fen,
    required EngineConfig config,
  });

  /// Requests cancellation of the active search.
  ///
  /// Calling this while idle should be safe.
  Future<void> stop();

  /// Releases engine resources permanently.
  Future<void> dispose();
}
