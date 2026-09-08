import 'package:endgame_mastery/core/engine/engine_move.dart';

class EnginePositionAnalysis {
  const EnginePositionAnalysis({
    required this.bestMove,
    required this.depth,
    required this.scoreCp,
    required this.mateIn,
    required this.principalVariation,
  });

  final EngineMove bestMove;
  final int? depth;

  /// Centipawn score from the side-to-move perspective reported by UCI.
  final int? scoreCp;

  /// Mate distance reported by UCI. Positive favors the side to move.
  final int? mateIn;

  /// UCI moves from the most recent principal variation line.
  final List<String> principalVariation;

  bool get isMateScore => mateIn != null;
}
