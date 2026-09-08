import 'package:endgame_mastery/features/coach/data/coach_development_focus_detector.dart';
import 'package:endgame_mastery/features/coach/data/coach_engine_analyzer.dart';
import 'package:endgame_mastery/features/coach/domain/coach_analysis_plan.dart';
import 'package:endgame_mastery/features/coach/domain/coach_development_focus.dart';
import 'package:flutter/material.dart';

class CoachDevelopmentFocusPanel extends StatelessWidget {
  const CoachDevelopmentFocusPanel({
    required this.result,
    super.key,
  });

  final CoachEngineAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final focuses = const CoachDevelopmentFocusDetector().detect(result);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What to work on next',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 6),
        const Text(
          'One game gives provisional signals, not a permanent label. Recurring weaknesses should only be promoted after the same pattern appears across multiple games.',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        const SizedBox(height: 12),
        if (focuses.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'No major development focus was inferred from the engine-critical moments in this scan.',
              ),
            ),
          )
        else
          for (final focus in focuses)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.track_changes_outlined),
                title: Text(_axisLabel(focus.axis)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(focus.reason),
                ),
                trailing: Text(
                  '${focus.evidenceCount}×',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
      ],
    );
  }

  String _axisLabel(CoachingAxis axis) {
    return switch (axis) {
      CoachingAxis.openingUnderstanding => 'Opening understanding',
      CoachingAxis.candidateMoves => 'Candidate moves',
      CoachingAxis.calculation => 'Calculation',
      CoachingAxis.tacticalAwareness => 'Tactical awareness',
      CoachingAxis.positionalPlay => 'Positional play',
      CoachingAxis.technique => 'Converting an advantage',
      CoachingAxis.endgame => 'Endgame technique',
      CoachingAxis.decisionQuality => 'Decision routine',
    };
  }
}
