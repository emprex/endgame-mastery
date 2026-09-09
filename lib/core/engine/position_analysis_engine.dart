import 'package:endgame_mastery/core/engine/engine_config.dart';
import 'package:endgame_mastery/core/engine/engine_position_analysis.dart';

/// Engine capability used for post-game analysis.
///
/// This lifecycle is deliberately separate from the interactive board caller.
/// Implementations may reuse the same Stockfish adapter internally, but coach
/// orchestration must depend only on this contract.
abstract interface class PositionAnalysisEngine {
  Future<void> initialize();

  Future<EnginePositionAnalysis> analyzePosition({
    required String fen,
    required EngineConfig config,
  });

  Future<void> stop();

  Future<void> dispose();
}
