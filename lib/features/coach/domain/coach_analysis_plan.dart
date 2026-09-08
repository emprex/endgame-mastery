import 'package:endgame_mastery/features/coach/domain/coach_game.dart';

enum CoachingAxis {
  openingUnderstanding,
  candidateMoves,
  calculation,
  tacticalAwareness,
  positionalPlay,
  technique,
  endgame,
  decisionQuality,
}

class CoachAnalysisStep {
  const CoachAnalysisStep({
    required this.title,
    required this.purpose,
  });

  final String title;
  final String purpose;
}

class CoachAnalysisPlan {
  const CoachAnalysisPlan({
    required this.game,
    required this.steps,
    required this.axes,
  });

  final CoachGame game;
  final List<CoachAnalysisStep> steps;
  final List<CoachingAxis> axes;
}

class CoachAnalysisPlanner {
  const CoachAnalysisPlanner();

  CoachAnalysisPlan build(CoachGame game) {
    return CoachAnalysisPlan(
      game: game,
      steps: const [
        CoachAnalysisStep(
          title: 'Reconstruct the game',
          purpose: 'Build every position from the played moves before judging decisions.',
        ),
        CoachAnalysisStep(
          title: 'Find critical decisions',
          purpose: 'Use engine comparison to isolate moments where the position or plan changed materially.',
        ),
        CoachAnalysisStep(
          title: 'Explain the cause',
          purpose: 'Prefer the underlying chess reason over a long list of engine variations.',
        ),
        CoachAnalysisStep(
          title: 'Detect a development axis',
          purpose: 'Connect the mistake to a repeatable thinking skill or chess concept.',
        ),
        CoachAnalysisStep(
          title: 'Turn the game into training',
          purpose: 'Create a focused exercise and later ask the player to solve the idea independently.',
        ),
      ],
      axes: const [
        CoachingAxis.openingUnderstanding,
        CoachingAxis.candidateMoves,
        CoachingAxis.calculation,
        CoachingAxis.tacticalAwareness,
        CoachingAxis.positionalPlay,
        CoachingAxis.technique,
        CoachingAxis.endgame,
        CoachingAxis.decisionQuality,
      ],
    );
  }
}
