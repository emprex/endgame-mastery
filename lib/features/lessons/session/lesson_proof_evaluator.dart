import '../domain/lesson_definition.dart';
import 'lesson_proof_evaluation.dart';
import 'lesson_session_outcome.dart';

/// Compares an actual Prove result with verified curriculum theory.
///
/// This evaluator does not use:
/// - Stockfish evaluation
/// - board heuristics
/// - piece placement inference
/// - guessed endgame theory
///
/// If curriculum truth for the exact proof FEN is unknown, the evaluation
/// is explicitly unsupported.
class LessonProofEvaluator {
  const LessonProofEvaluator();

  LessonProofEvaluation evaluate({
    required LessonDefinition lesson,
    required String proofFen,
    required LessonSessionOutcome actualOutcome,
  }) {
    final normalizedFen = proofFen.trim();

    final expectedResult = lesson.theoreticalResultForFen(normalizedFen);

    if (expectedResult == null) {
      return LessonProofEvaluation(
        proofFen: normalizedFen,
        actualOutcome: actualOutcome,
        expectedResult: null,
        verdict: LessonProofVerdict.unsupported,
      );
    }

    final expectedOutcome = _toSessionOutcome(expectedResult);

    return LessonProofEvaluation(
      proofFen: normalizedFen,
      actualOutcome: actualOutcome,
      expectedResult: expectedResult,
      verdict: actualOutcome == expectedOutcome
          ? LessonProofVerdict.passed
          : LessonProofVerdict.failed,
    );
  }

  LessonSessionOutcome _toSessionOutcome(TheoreticalResult result) {
    return switch (result) {
      TheoreticalResult.win => LessonSessionOutcome.win,
      TheoreticalResult.draw => LessonSessionOutcome.draw,
      TheoreticalResult.loss => LessonSessionOutcome.loss,
    };
  }
}
