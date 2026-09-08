import 'package:endgame_mastery/core/engine/engine_position_analysis.dart';
import 'package:endgame_mastery/features/coach/domain/reconstructed_move.dart';

enum EngineImpactLevel {
  negligible,
  small,
  significant,
  severe,
  forcedMateSwing,
  unclassified,
}

class CoachMoveEngineAnalysis {
  const CoachMoveEngineAnalysis({
    required this.move,
    required this.before,
    required this.after,
    required this.isEngineBestMove,
    required this.centipawnLoss,
    required this.impact,
  });

  final ReconstructedMove move;
  final EnginePositionAnalysis before;
  final EnginePositionAnalysis? after;
  final bool isEngineBestMove;

  /// Evaluation lost by the mover after normalizing both engine scores
  /// to the mover's perspective. Null when a safe centipawn comparison
  /// is not available (for example, mate-score transitions).
  final int? centipawnLoss;

  final EngineImpactLevel impact;

  bool get isCritical =>
      impact == EngineImpactLevel.significant ||
      impact == EngineImpactLevel.severe ||
      impact == EngineImpactLevel.forcedMateSwing;
}
