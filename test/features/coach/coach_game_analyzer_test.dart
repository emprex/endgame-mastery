import 'package:endgame_mastery/core/engine/engine_config.dart';
import 'package:endgame_mastery/core/engine/engine_move.dart';
import 'package:endgame_mastery/core/engine/engine_position_analysis.dart';
import 'package:endgame_mastery/core/engine/position_analysis_engine.dart';
import 'package:endgame_mastery/features/coach/application/coach_game_analyzer.dart';
import 'package:endgame_mastery/features/coach/application/pgn_game_parser.dart';
import 'package:endgame_mastery/features/coach/domain/game_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = PgnGameParser();

  const pgn = '''
[White "WhitePlayer"]
[Black "BlackPlayer"]
[Result "*"]

1. e4 e5 2. Nf3 *
''';

  test('analyzes only the selected side and ranks numeric evaluation swings', () async {
    final engine = _QueueAnalysisEngine(<int>[30, 70, 20, 100]);
    final analyzer = CoachGameAnalyzer(engine: engine);
    final game = parser.parse(pgn);

    final progress = <String>[];

    final analysis = await analyzer.analyze(
      game: game,
      side: CoachGameSide.white,
      onProgress: (completed, total) {
        progress.add('$completed/$total');
      },
    );

    expect(engine.initialized, isTrue);
    expect(analysis.moves, hasLength(2));
    expect(analysis.moves[0].position.san, 'e4');
    expect(analysis.moves[0].centipawnLoss, 100);
    expect(analysis.moves[1].position.san, 'Nf3');
    expect(analysis.moves[1].centipawnLoss, 120);

    final critical = analysis.largestEvaluationSwings(limit: 1);
    expect(critical.single.position.san, 'Nf3');
    expect(progress.first, '0/4');
    expect(progress.last, '4/4');
  });
}

class _QueueAnalysisEngine implements PositionAnalysisEngine {
  _QueueAnalysisEngine(this._scores);

  final List<int> _scores;
  int _index = 0;
  bool initialized = false;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<EnginePositionAnalysis> analyzePosition({
    required String fen,
    required EngineConfig config,
  }) async {
    final score = _scores[_index++];

    return EnginePositionAnalysis(
      fen: fen,
      bestMove: const EngineMove(from: 'e2', to: 'e4'),
      score: EngineScore.centipawns(score),
      depth: 12,
      principalVariation: const <String>['e2e4'],
    );
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}
