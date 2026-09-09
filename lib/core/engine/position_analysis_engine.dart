import 'package:endgame_mastery/core/engine/engine_config.dart';
import 'package:endgame_mastery/core/engine/engine_position_analysis.dart';

/// Engine capability used for post-game analysis.
///
/// This is intentionally separate from [ChessEngine]'s gameplay contract.
/// Interactive opponent play and post-game evaluation have different callers
/// and must not be coupled at the application layer.
abstract interface class PositionAnalysisEngine {
  Future<EnginePositionAnalysis> analyzePosition({
    required String fen,
    required EngineConfig config,
  });
}
