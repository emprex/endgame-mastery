import 'package:endgame_mastery/core/engine/engine_move.dart';

enum EngineScoreKind {
  centipawn,
  mate,
}

class EngineScore {
  const EngineScore.centipawns(int value)
      : kind = EngineScoreKind.centipawn,
        value = value;

  const EngineScore.mate(int value)
      : kind = EngineScoreKind.mate,
        value = value;

  final EngineScoreKind kind;

  /// UCI score from the side-to-move perspective.
  ///
  /// For [EngineScoreKind.centipawn], this is measured in centipawns.
  /// For [EngineScoreKind.mate], this is Stockfish's signed mate distance.
  final int value;

  bool get isMate => kind == EngineScoreKind.mate;
}

class EnginePositionAnalysis {
  EnginePositionAnalysis({
    required this.fen,
    required this.bestMove,
    required this.score,
    required this.depth,
    required List<String> principalVariation,
  }) : principalVariation = List<String>.unmodifiable(principalVariation);

  final String fen;
  final EngineMove bestMove;
  final EngineScore score;
  final int depth;
  final List<String> principalVariation;
}
