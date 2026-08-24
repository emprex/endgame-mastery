import '../domain/lesson_definition.dart';
import '../teaching/teaching_state_builder.dart';
import 'lesson_experience_state.dart';
import 'lesson_progression.dart';
import 'lesson_proof_evaluation.dart';
import 'lesson_proof_evaluator.dart';
import 'lesson_session_state.dart';
import 'lesson_stage.dart';

/// Builds the read-only lesson integration state consumed by future UI.
///
/// This class composes existing domain services. It does not mutate gameplay,
/// run Stockfish, perform Flutter navigation, or render widgets.
class LessonExperienceBuilder {
  const LessonExperienceBuilder({
    this.teachingStateBuilder = const TeachingStateBuilder(),
    this.proofEvaluator = const LessonProofEvaluator(),
  });

  final TeachingStateBuilder teachingStateBuilder;
  final LessonProofEvaluator proofEvaluator;

  LessonExperienceState build({
    required LessonSessionState session,
    required String currentFen,
    String? proofFen,
    LessonProgression? progression,
  }) {
    final teaching = teachingStateBuilder.build(
      lesson: session.lesson,
      fen: currentFen,
    );

    LessonProofEvaluation? proofEvaluation;

    final isResultStage =
        session.stage == LessonStage.result ||
        session.stage == LessonStage.completed;

    if (isResultStage) {
      final outcome = session.outcome;

      if (outcome == null) {
        throw StateError('Result and completed sessions require an outcome.');
      }

      if (proofFen == null || proofFen.trim().isEmpty) {
        throw ArgumentError(
          'A proof starting FEN is required after Prove completion.',
        );
      }

      proofEvaluation = proofEvaluator.evaluate(
        lesson: session.lesson,
        proofFen: proofFen,
        actualOutcome: outcome,
      );
    } else if (proofFen != null) {
      throw ArgumentError(
        'Proof FEN may only be supplied after Prove completion.',
      );
    }

    LessonDefinition? nextLesson;

    if (session.stage == LessonStage.completed && progression != null) {
      nextLesson = progression.nextLessonFor(session);
    }

    return LessonExperienceState(
      session: session,
      teaching: teaching,
      proofEvaluation: proofEvaluation,
      nextLesson: nextLesson,
    );
  }
}
