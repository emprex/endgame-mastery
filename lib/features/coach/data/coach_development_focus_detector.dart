import 'package:chess/chess.dart' as chess_lib;
import 'package:endgame_mastery/features/coach/data/coach_engine_analyzer.dart';
import 'package:endgame_mastery/features/coach/domain/coach_analysis_plan.dart';
import 'package:endgame_mastery/features/coach/domain/coach_development_focus.dart';
import 'package:endgame_mastery/features/coach/domain/coach_move_engine_analysis.dart';

class CoachDevelopmentFocusDetector {
  const CoachDevelopmentFocusDetector();

  List<CoachDevelopmentFocus> detect(CoachEngineAnalysisResult result) {
    final critical = result.criticalMoments;
    if (critical.isEmpty) return const [];

    final focuses = <CoachDevelopmentFocus>[];

    focuses.add(
      CoachDevelopmentFocus(
        axis: CoachingAxis.candidateMoves,
        evidenceCount: critical.length,
        reason:
            '${critical.length} turning point(s) should be revisited by generating candidate moves before calculating. This is a training process recommendation, not a claim that every error had the same cause.',
        confidence: FocusConfidence.provisional,
      ),
    );

    final opening = critical
        .where((analysis) => analysis.move.fullMoveNumber <= 12)
        .length;
    if (opening > 0) {
      focuses.add(
        CoachDevelopmentFocus(
          axis: CoachingAxis.openingUnderstanding,
          evidenceCount: opening,
          reason:
              '$opening significant decision(s) occurred in the first 12 moves. Review the plans and piece-placement ideas around those positions rather than memorizing only the engine move.',
          confidence: FocusConfidence.provisional,
        ),
      );
    }

    final endgame = critical.where(_isEndgamePosition).length;
    if (endgame > 0) {
      focuses.add(
        CoachDevelopmentFocus(
          axis: CoachingAxis.endgame,
          evidenceCount: endgame,
          reason:
              '$endgame critical decision(s) occurred with ten or fewer pieces on the board, making them strong candidates for focused endgame study.',
          confidence: FocusConfidence.provisional,
        ),
      );
    }

    final mateSwings = critical
        .where(
          (analysis) =>
              analysis.impact == EngineImpactLevel.forcedMateSwing,
        )
        .length;
    if (mateSwings > 0) {
      focuses.add(
        CoachDevelopmentFocus(
          axis: CoachingAxis.calculation,
          evidenceCount: mateSwings,
          reason:
              '$mateSwings decision(s) changed a forced-mate situation. These positions deserve explicit calculation practice with forcing candidate moves.',
          confidence: FocusConfidence.provisional,
        ),
      );
    }

    final forcing = critical.where(_bestMoveIsForcing).length;
    if (forcing > 0) {
      focuses.add(
        CoachDevelopmentFocus(
          axis: CoachingAxis.tacticalAwareness,
          evidenceCount: forcing,
          reason:
              'In $forcing critical position(s), Stockfish’s leading candidate was a capture or a check. Train the forcing-move scan before moving to quieter candidates.',
          confidence: FocusConfidence.provisional,
        ),
      );
    }

    final technique = critical.where(_lostExistingAdvantage).length;
    if (technique > 0) {
      focuses.add(
        CoachDevelopmentFocus(
          axis: CoachingAxis.technique,
          evidenceCount: technique,
          reason:
              '$technique critical decision(s) came from positions where the mover already held a clear engine advantage. Review how to restrict counterplay and convert without unnecessary risk.',
          confidence: FocusConfidence.provisional,
        ),
      );
    }

    final positional = critical.where((analysis) {
      return analysis.move.fullMoveNumber > 12 &&
          !_isEndgamePosition(analysis) &&
          !_bestMoveIsForcing(analysis) &&
          analysis.impact != EngineImpactLevel.forcedMateSwing;
    }).length;
    if (positional > 0) {
      focuses.add(
        CoachDevelopmentFocus(
          axis: CoachingAxis.positionalPlay,
          evidenceCount: positional,
          reason:
              '$positional critical decision(s) were neither early-opening moments, low-material endings, nor forcing tactical candidates. They deserve a plan-based positional review.',
          confidence: FocusConfidence.provisional,
        ),
      );
    }

    final severe = critical
        .where(
          (analysis) =>
              analysis.impact == EngineImpactLevel.severe ||
              analysis.impact == EngineImpactLevel.forcedMateSwing,
        )
        .length;
    if (severe >= 2) {
      focuses.add(
        CoachDevelopmentFocus(
          axis: CoachingAxis.decisionQuality,
          evidenceCount: severe,
          reason:
              '$severe major turning points occurred in the same game. A useful next step is to slow down at high-leverage positions and apply the same candidate → calculation → decision routine.',
          confidence: FocusConfidence.provisional,
        ),
      );
    }

    focuses.sort(
      (left, right) => right.evidenceCount.compareTo(left.evidenceCount),
    );
    return List.unmodifiable(focuses);
  }

  bool _isEndgamePosition(CoachMoveEngineAnalysis analysis) {
    final board = chess_lib.Chess.fromFEN(analysis.move.fenBefore);
    final pieceCount = board.board.where((piece) => piece != null).length;
    return pieceCount <= 10;
  }

  bool _lostExistingAdvantage(CoachMoveEngineAnalysis analysis) {
    final score = analysis.before.scoreCp;
    final loss = analysis.centipawnLoss;
    return score != null && score >= 150 && loss != null && loss >= 75;
  }

  bool _bestMoveIsForcing(CoachMoveEngineAnalysis analysis) {
    final uci = analysis.before.bestMove.uci;
    if (uci.length < 4) return false;

    final board = chess_lib.Chess.fromFEN(analysis.move.fenBefore);
    final to = uci.substring(2, 4);
    final isCapture = board.get(to) != null;

    final move = <String, String>{
      'from': uci.substring(0, 2),
      'to': to,
    };
    if (uci.length >= 5) {
      move['promotion'] = uci.substring(4, 5);
    }

    final accepted = board.move(move);
    final givesCheck = accepted && board.in_check;
    return isCapture || givesCheck;
  }
}
