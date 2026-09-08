import 'package:endgame_mastery/core/engine/engine_move.dart';
import 'package:endgame_mastery/core/engine/engine_position_analysis.dart';
import 'package:endgame_mastery/features/coach/data/coach_development_focus_detector.dart';
import 'package:endgame_mastery/features/coach/data/coach_engine_analyzer.dart';
import 'package:endgame_mastery/features/coach/data/game_reconstructor.dart';
import 'package:endgame_mastery/features/coach/data/pgn_game_parser.dart';
import 'package:endgame_mastery/features/coach/domain/coach_analysis_plan.dart';
import 'package:endgame_mastery/features/coach/domain/coach_move_engine_analysis.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const detector = CoachDevelopmentFocusDetector();
  const parser = PgnGameParser();
  const reconstructor = GameReconstructor();

  test('turns critical opening decisions into provisional focus evidence', () {
    final move = reconstructor.reconstruct(parser.parse('1. e4')).single;
    final analysis = CoachMoveEngineAnalysis(
      move: move,
      before: _analysis(
        bestMove: const EngineMove(from: 'd2', to: 'd4'),
        scoreCp: 180,
      ),
      after: _analysis(
        bestMove: const EngineMove(from: 'e7', to: 'e5'),
        scoreCp: 40,
      ),
      isEngineBestMove: false,
      centipawnLoss: 220,
      impact: EngineImpactLevel.severe,
    );

    final focuses = detector.detect(
      CoachEngineAnalysisResult(moves: [analysis]),
    );

    expect(
      focuses.any((focus) => focus.axis == CoachingAxis.candidateMoves),
      isTrue,
    );
    expect(
      focuses.any((focus) => focus.axis == CoachingAxis.openingUnderstanding),
      isTrue,
    );
    expect(
      focuses.any((focus) => focus.axis == CoachingAxis.technique),
      isTrue,
    );
  });

  test('returns no development label when no critical moment exists', () {
    final move = reconstructor.reconstruct(parser.parse('1. e4')).single;
    final analysis = CoachMoveEngineAnalysis(
      move: move,
      before: _analysis(
        bestMove: const EngineMove(from: 'e2', to: 'e4'),
        scoreCp: 20,
      ),
      after: _analysis(
        bestMove: const EngineMove(from: 'e7', to: 'e5'),
        scoreCp: -15,
      ),
      isEngineBestMove: true,
      centipawnLoss: 5,
      impact: EngineImpactLevel.negligible,
    );

    final focuses = detector.detect(
      CoachEngineAnalysisResult(moves: [analysis]),
    );

    expect(focuses, isEmpty);
  });
}

EnginePositionAnalysis _analysis({
  required EngineMove bestMove,
  required int scoreCp,
}) {
  return EnginePositionAnalysis(
    bestMove: bestMove,
    depth: 14,
    scoreCp: scoreCp,
    mateIn: null,
    principalVariation: [bestMove.uci],
  );
}
