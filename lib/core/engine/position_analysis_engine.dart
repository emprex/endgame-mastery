import 'package:endgame_mastery/core/engine/engine_config.dart';
import 'package:endgame_mastery/core/engine/engine_position_analysis.dart';

abstract interface class PositionAnalysisEngine {
  Future<EnginePositionAnalysis> analyzePosition({
    required String fen,
    required EngineConfig config,
  });
}
