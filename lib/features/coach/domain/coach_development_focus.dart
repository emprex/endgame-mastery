import 'package:endgame_mastery/features/coach/domain/coach_analysis_plan.dart';

enum FocusConfidence {
  provisional,
  recurring,
}

class CoachDevelopmentFocus {
  const CoachDevelopmentFocus({
    required this.axis,
    required this.evidenceCount,
    required this.reason,
    required this.confidence,
  });

  final CoachingAxis axis;
  final int evidenceCount;
  final String reason;
  final FocusConfidence confidence;
}
