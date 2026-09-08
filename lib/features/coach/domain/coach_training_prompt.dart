import 'package:endgame_mastery/features/coach/domain/coach_move_engine_analysis.dart';

class CoachTrainingPrompt {
  const CoachTrainingPrompt({
    required this.title,
    required this.fen,
    required this.question,
    required this.playedMove,
    required this.engineMove,
    required this.engineLine,
    required this.proofInstruction,
  });

  final String title;
  final String fen;
  final String question;
  final String playedMove;
  final String engineMove;
  final List<String> engineLine;
  final String proofInstruction;
}

class CoachTrainingPromptBuilder {
  const CoachTrainingPromptBuilder();

  CoachTrainingPrompt build(CoachMoveEngineAnalysis analysis) {
    final move = analysis.move;
    final moveLabel = move.wasWhiteMove
        ? '${move.fullMoveNumber}.'
        : '${move.fullMoveNumber}...';

    return CoachTrainingPrompt(
      title: '$moveLabel ${move.san}',
      fen: move.fenBefore,
      question:
          'Return to the position before this move. First identify the opponent’s idea or threat. Then list at least two candidate moves, calculate the most forcing reply to each, and choose your move before revealing the engine answer.',
      playedMove: move.san,
      engineMove: analysis.before.bestMove.uci,
      engineLine: analysis.before.principalVariation,
      proofInstruction:
          'Hide the answer, reset the position, and solve it again independently. The goal is to reproduce the decision process, not memorize the engine move.',
    );
  }
}
