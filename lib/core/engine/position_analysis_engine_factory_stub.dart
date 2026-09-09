import 'package:endgame_mastery/core/engine/engine_config.dart';
import 'package:endgame_mastery/core/engine/engine_exception.dart';
import 'package:endgame_mastery/core/engine/engine_position_analysis.dart';
import 'package:endgame_mastery/core/engine/position_analysis_engine.dart';

PositionAnalysisEngine createPlatformPositionAnalysisEngine() {
  return _UnsupportedPositionAnalysisEngine();
}

class _UnsupportedPositionAnalysisEngine implements PositionAnalysisEngine {
  @override
  Future<void> initialize() async {
    throw const EngineInitializationException(
      'Post-game Stockfish analysis is not available on this platform yet.',
    );
  }

  @override
  Future<EnginePositionAnalysis> analyzePosition({
    required String fen,
    required EngineConfig config,
  }) async {
    throw const EngineInitializationException(
      'Post-game Stockfish analysis is not available on this platform yet.',
    );
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}
