import 'package:endgame_mastery/core/engine/engine_config.dart';
import 'package:endgame_mastery/core/engine/engine_position_analysis.dart';
import 'package:endgame_mastery/core/engine/position_analysis_engine.dart';
import 'package:endgame_mastery/features/coach/domain/coach_game_analysis.dart';
import 'package:endgame_mastery/features/coach/domain/game_position.dart';
import 'package:endgame_mastery/features/coach/domain/imported_game.dart';

typedef CoachAnalysisProgress = void Function(int completed, int total);

class CoachGameAnalyzer {
  CoachGameAnalyzer({
    required this.engine,
    this.config = const EngineConfig(),
  });

  final PositionAnalysisEngine engine;
  final EngineConfig config;

  bool _disposed = false;

  Future<CoachGameAnalysis> analyze({
    required ImportedGame game,
    required CoachGameSide side,
    CoachAnalysisProgress? onProgress,
  }) async {
    if (_disposed) {
      throw StateError('CoachGameAnalyzer has been disposed.');
    }

    final playerMoves = game.positions
        .where((position) => position.side == side)
        .toList(growable: false);

    if (playerMoves.isEmpty) {
      throw StateError('The selected side has no moves in this game.');
    }

    final uniqueFens = <String>{
      for (final position in playerMoves) position.fenBefore,
      for (final position in playerMoves) position.fenAfter,
    };

    final total = uniqueFens.length;
    var completed = 0;
    final cache = <String, EnginePositionAnalysis>{};

    onProgress?.call(completed, total);

    await engine.initialize();

    Future<EnginePositionAnalysis> evaluate(String fen) async {
      final cached = cache[fen];

      if (cached != null) {
        return cached;
      }

      final analysis = await engine.analyzePosition(
        fen: fen,
        config: config,
      );

      cache[fen] = analysis;
      completed++;
      onProgress?.call(completed, total);

      return analysis;
    }

    final moveAnalyses = <CoachMoveAnalysis>[];

    for (final position in playerMoves) {
      final before = await evaluate(position.fenBefore);
      final after = await evaluate(position.fenAfter);

      moveAnalyses.add(
        CoachMoveAnalysis(
          position: position,
          before: before,
          after: after,
        ),
      );
    }

    return CoachGameAnalysis(
      game: game,
      side: side,
      moves: moveAnalyses,
    );
  }

  Future<void> stop() async {
    if (_disposed) {
      return;
    }

    await engine.stop();
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }

    _disposed = true;
    await engine.dispose();
  }
}
