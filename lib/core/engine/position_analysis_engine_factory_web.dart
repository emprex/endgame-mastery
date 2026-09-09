import 'package:endgame_mastery/core/engine/position_analysis_engine.dart';
import 'package:endgame_mastery/core/engine/web/stockfish_web_engine.dart';

PositionAnalysisEngine createPlatformPositionAnalysisEngine() {
  return StockfishWebEngine();
}
