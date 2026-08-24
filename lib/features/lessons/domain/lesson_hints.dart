/// Progressive pedagogical hints for a lesson.
///
/// Hints are curriculum-owned teaching content.
///
/// They do not come from Stockfish and they do not represent
/// engine evaluation.
class LessonHints {
  factory LessonHints({
    required String concept,
    required String visual,
    required String targeted,
  }) {
    final normalizedConcept = concept.trim();
    final normalizedVisual = visual.trim();
    final normalizedTargeted = targeted.trim();

    if (normalizedConcept.isEmpty) {
      throw ArgumentError.value(
        concept,
        'concept',
        'Concept hint must not be empty.',
      );
    }

    if (normalizedVisual.isEmpty) {
      throw ArgumentError.value(
        visual,
        'visual',
        'Visual hint must not be empty.',
      );
    }

    if (normalizedTargeted.isEmpty) {
      throw ArgumentError.value(
        targeted,
        'targeted',
        'Targeted hint must not be empty.',
      );
    }

    return LessonHints._(
      concept: normalizedConcept,
      visual: normalizedVisual,
      targeted: normalizedTargeted,
    );
  }

  const LessonHints._({
    required this.concept,
    required this.visual,
    required this.targeted,
  });

  /// Level 1.
  ///
  /// Reminds the learner of the governing concept
  /// without identifying the solution.
  final String concept;

  /// Level 2.
  ///
  /// Directs attention to relevant board geometry or areas.
  final String visual;

  /// Level 3.
  ///
  /// Gives a precise target or constraint while still avoiding
  /// playing the move for the learner.
  final String targeted;
}
