import '../domain/lesson_definition.dart';
import 'lesson_session_outcome.dart';

/// Pedagogical verdict for a completed Prove attempt.
enum LessonProofVerdict {
  /// The actual played result matches verified curriculum theory.
  passed,

  /// Verified theory exists, but the learner did not achieve that result.
  failed,

  /// The curriculum has no verified theoretical truth for this exact FEN.
  unsupported,
}

/// Result of evaluating one completed proof attempt.
///
/// The proof position is the exact FEN from which the Prove attempt started.
/// This is intentionally separate from the final gameplay FEN.
class LessonProofEvaluation {
  const LessonProofEvaluation({
    required this.proofFen,
    required this.actualOutcome,
    required this.expectedResult,
    required this.verdict,
  });

  /// Exact starting FEN of the Prove attempt.
  final String proofFen;

  /// Result actually achieved by the learner.
  final LessonSessionOutcome actualOutcome;

  /// Verified curriculum result for [proofFen].
  ///
  /// Null means that this exact position is not supported by verified
  /// curriculum theory.
  final TheoreticalResult? expectedResult;

  final LessonProofVerdict verdict;

  bool get isSupported => expectedResult != null;

  bool get passed => verdict == LessonProofVerdict.passed;
}
