import 'dart:math' as math;

import 'package:endgame_mastery/core/engine/engine_position_analysis.dart';
import 'package:endgame_mastery/features/coach/domain/game_position.dart';
import 'package:endgame_mastery/features/coach/domain/imported_game.dart';

class CoachMoveAnalysis {
  const CoachMoveAnalysis({
    required this.position,
    required this.before,
    required this.after,
  });

  final GamePosition position;
  final EnginePositionAnalysis before;
  final EnginePositionAnalysis after;

  /// Numeric evaluation loss for the mover, when both engine scores are
  /// centipawn scores. Mate scores are intentionally left unconverted.
  ///
  /// UCI reports from the side-to-move perspective. The `after` position is
  /// the opponent's turn, so its score is negated before comparing it with the
  /// mover's `before` score.
  int? get centipawnLoss {
    if (before.score.kind != EngineScoreKind.centipawn ||
        after.score.kind != EngineScoreKind.centipawn) {
      return null;
    }

    final rawLoss = before.score.value + after.score.value;
    return math.max(0, rawLoss);
  }
}

class CoachGameAnalysis {
  CoachGameAnalysis({
    required this.game,
    required this.side,
    required List<CoachMoveAnalysis> moves,
  }) : moves = List<CoachMoveAnalysis>.unmodifiable(moves);

  final ImportedGame game;
  final CoachGameSide side;
  final List<CoachMoveAnalysis> moves;

  List<CoachMoveAnalysis> largestEvaluationSwings({int limit = 5}) {
    final ranked = moves.where((move) => move.centipawnLoss != null).toList()
      ..sort(
        (left, right) =>
            (right.centipawnLoss ?? 0).compareTo(left.centipawnLoss ?? 0),
      );

    return ranked.take(limit).toList(growable: false);
  }
}
