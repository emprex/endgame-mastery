import 'package:endgame_mastery/core/engine/position_analysis_engine.dart';
import 'package:endgame_mastery/core/engine/position_analysis_engine_factory_stub.dart'
    if (dart.library.js_interop)
        'package:endgame_mastery/core/engine/position_analysis_engine_factory_web.dart';

PositionAnalysisEngine createPositionAnalysisEngine() {
  return createPlatformPositionAnalysisEngine();
}
