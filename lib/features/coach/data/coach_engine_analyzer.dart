import 'package:chess/chess.dart' as chess_lib;
import 'package:endgame_mastery/core/engine/engine_config.dart';
import 'package:endgame_mastery/core/engine/engine_position_analysis.dart';
import 'package:endgame_mastery/core/engine/position_analysis_engine.dart';
import 'package:endgame_mastery/features/coach/domain/coach_move_engine_analysis.dart';
import 'package:endgame_mastery/features/coach/domain/reconstructed_move.dart';

class CoachEngineAnalysisResult {
  const CoachEngineAnalysisResult({required this.moves});

  final List<CoachMoveEngineAnalysis> moves;

  List<CoachMoveEngineAnalysis> get criticalMoments =>
      List.unmodifiable(moves.where((move) => move.isCritical));
}

class CoachEngineAnalyzer {
  const CoachEngineAnalyzer({
    required this.engine,
    this.scanConfig = const EngineConfig(
      moveTime: Duration(milliseconds: 180),
      depth: 14,
    ),
  });

  final PositionAnalysisEngine engine;
  final EngineConfig scanConfig;

  Future<CoachEngineAnalysisResult> analyze(
    List<ReconstructedMove> reconstructedMoves,
  ) async {
    final cache = <String, EnginePositionAnalysis>{};
    final analyses = <CoachMoveEngineAnalysis>[];

    for (final move in reconstructedMoves) {
      final before = await _analyzeCached(move.fenBefore, cache);
      final afterPosition = chess_lib.Chess.fromFEN(move.fenAfter);
      final isTerminal = afterPosition.game_over;

      EnginePositionAnalysis? after;
      if (!isTerminal) {
        after = await _analyzeCached(move.fenAfter, cache);
      }

      final isBestMove = before.bestMove.uci == move.uci;
      final centipawnLoss = _centipawnLoss(
        before: before,
        after: after,
        terminalDraw: isTerminal && afterPosition.in_draw,
      );

      analyses.add(
        CoachMoveEngineAnalysis(
          move: move,
          before: before,
          after: after,
          isEngineBestMove: isBestMove,
          centipawnLoss: centipawnLoss,
          impact: _impact(
            before: before,
            after: after,
            isBestMove: isBestMove,
            centipawnLoss: centipawnLoss,
            terminalCheckmate: isTerminal && afterPosition.in_checkmate,
          ),
        ),
      );
    }

    return CoachEngineAnalysisResult(
      moves: List.unmodifiable(analyses),
    );
  }

  Future<EnginePositionAnalysis> _analyzeCached(
    String fen,
    Map<String, EnginePositionAnalysis> cache,
  ) async {
    final cached = cache[fen];
    if (cached != null) return cached;

    final analysis = await engine.analyzePosition(
      fen: fen,
      config: scanConfig,
    );
    cache[fen] = analysis;
    return analysis;
  }

  int? _centipawnLoss({
    required EnginePositionAnalysis before,
    required EnginePositionAnalysis? after,
    required bool terminalDraw,
  }) {
    final beforeScore = before.scoreCp;
    if (beforeScore == null || before.mateIn != null) return null;

    if (terminalDraw) {
      return beforeScore < 0 ? 0 : beforeScore;
    }

    final afterScore = after?.scoreCp;
    if (afterScore == null || after?.mateIn != null) return null;

    // UCI scores are from the side-to-move perspective. After the move,
    // the opponent is to move, so its score must be negated to express
    // the resulting position from the original mover's perspective.
    final moverScoreAfter = -afterScore;
    final loss = beforeScore - moverScoreAfter;
    return loss < 0 ? 0 : loss;
  }

  EngineImpactLevel _impact({
    required EnginePositionAnalysis before,
    required EnginePositionAnalysis? after,
    required bool isBestMove,
    required int? centipawnLoss,
    required bool terminalCheckmate,
  }) {
    if (terminalCheckmate || isBestMove) {
      return EngineImpactLevel.negligible;
    }

    if (_forcedMateSwingAgainstMover(before, after)) {
      return EngineImpactLevel.forcedMateSwing;
    }

    if (centipawnLoss == null) {
      return EngineImpactLevel.unclassified;
    }

    if (centipawnLoss <= 25) return EngineImpactLevel.negligible;
    if (centipawnLoss <= 75) return EngineImpactLevel.small;
    if (centipawnLoss <= 150) return EngineImpactLevel.significant;
    return EngineImpactLevel.severe;
  }

  bool _forcedMateSwingAgainstMover(
    EnginePositionAnalysis before,
    EnginePositionAnalysis? after,
  ) {
    final beforeMate = before.mateIn;
    final afterMateForMover =
        after?.mateIn == null ? null : -after!.mateIn!;

    // The mover had a forced mate and no longer has it.
    if (beforeMate != null &&
        beforeMate > 0 &&
        (afterMateForMover == null || afterMateForMover <= 0)) {
      return true;
    }

    // The mover was not getting mated before, but is after the move.
    if ((beforeMate == null || beforeMate >= 0) &&
        afterMateForMover != null &&
        afterMateForMover < 0) {
      return true;
    }

    return false;
  }
}
