import 'package:endgame_mastery/core/engine/engine_config.dart';
import 'package:endgame_mastery/core/engine/engine_move.dart';
import 'package:endgame_mastery/core/engine/engine_position_analysis.dart';
import 'package:endgame_mastery/core/engine/position_analysis_engine.dart';
import 'package:endgame_mastery/features/coach/data/coach_engine_analyzer.dart';
import 'package:endgame_mastery/features/coach/data/game_reconstructor.dart';
import 'package:endgame_mastery/features/coach/data/pgn_game_parser.dart';
import 'package:endgame_mastery/features/coach/domain/coach_move_engine_analysis.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = PgnGameParser();
  const reconstructor = GameReconstructor();

  test('normalizes before and after scores to the mover perspective', () async {
    final move = reconstructor.reconstruct(parser.parse('1. e4')).single;
    final engine = _FakePositionAnalysisEngine({
      move.fenBefore: _analysis(
        bestMove: const EngineMove(from: 'd2', to: 'd4'),
        scoreCp: 80,
      ),
      move.fenAfter: _analysis(
        bestMove: const EngineMove(from: 'e7', to: 'e5'),
        scoreCp: 40,
      ),
    });

    final result = await CoachEngineAnalyzer(engine: engine).analyze([move]);
    final analysis = result.moves.single;

    // Before: +0.80 for the mover. After: +0.40 for the opponent,
    // therefore -0.40 for the mover. Total loss = 1.20 pawns.
    expect(analysis.centipawnLoss, 120);
    expect(analysis.impact, EngineImpactLevel.significant);
    expect(analysis.isCritical, isTrue);
  });

  test('does not penalize the exact engine best move', () async {
    final move = reconstructor.reconstruct(parser.parse('1. e4')).single;
    final engine = _FakePositionAnalysisEngine({
      move.fenBefore: _analysis(
        bestMove: const EngineMove(from: 'e2', to: 'e4'),
        scoreCp: 25,
      ),
      move.fenAfter: _analysis(
        bestMove: const EngineMove(from: 'e7', to: 'e5'),
        scoreCp: -20,
      ),
    });

    final result = await CoachEngineAnalyzer(engine: engine).analyze([move]);
    final analysis = result.moves.single;

    expect(analysis.isEngineBestMove, isTrue);
    expect(analysis.impact, EngineImpactLevel.negligible);
  });

  test('keeps forced-mate swings separate from centipawn thresholds', () async {
    final move = reconstructor.reconstruct(parser.parse('1. e4')).single;
    final engine = _FakePositionAnalysisEngine({
      move.fenBefore: _analysis(
        bestMove: const EngineMove(from: 'd2', to: 'd4'),
        mateIn: 3,
      ),
      move.fenAfter: _analysis(
        bestMove: const EngineMove(from: 'e7', to: 'e5'),
        mateIn: 2,
      ),
    });

    final result = await CoachEngineAnalyzer(engine: engine).analyze([move]);
    final analysis = result.moves.single;

    expect(analysis.centipawnLoss, isNull);
    expect(analysis.impact, EngineImpactLevel.forcedMateSwing);
    expect(analysis.isCritical, isTrue);
  });

  test('caches shared positions across consecutive moves', () async {
    final moves = reconstructor.reconstruct(parser.parse('1. e4 e5'));
    final engine = _FakePositionAnalysisEngine({
      moves[0].fenBefore: _analysis(
        bestMove: const EngineMove(from: 'e2', to: 'e4'),
        scoreCp: 20,
      ),
      moves[0].fenAfter: _analysis(
        bestMove: const EngineMove(from: 'e7', to: 'e5'),
        scoreCp: -20,
      ),
      moves[1].fenAfter: _analysis(
        bestMove: const EngineMove(from: 'g1', to: 'f3'),
        scoreCp: 15,
      ),
    });

    await CoachEngineAnalyzer(engine: engine).analyze(moves);

    expect(engine.calls[moves[0].fenAfter], 1);
  });
}

EnginePositionAnalysis _analysis({
  required EngineMove bestMove,
  int? scoreCp,
  int? mateIn,
}) {
  return EnginePositionAnalysis(
    bestMove: bestMove,
    depth: 14,
    scoreCp: scoreCp,
    mateIn: mateIn,
    principalVariation: [bestMove.uci],
  );
}

class _FakePositionAnalysisEngine implements PositionAnalysisEngine {
  _FakePositionAnalysisEngine(this.responses);

  final Map<String, EnginePositionAnalysis> responses;
  final Map<String, int> calls = {};

  @override
  Future<EnginePositionAnalysis> analyzePosition({
    required String fen,
    required EngineConfig config,
  }) async {
    calls[fen] = (calls[fen] ?? 0) + 1;
    final response = responses[fen];
    if (response == null) {
      throw StateError('No fake engine response for FEN: $fen');
    }
    return response;
  }
}
