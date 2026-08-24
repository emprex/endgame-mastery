import '../domain/lesson_definition.dart';
import '../teaching/teaching_state.dart';
import 'lesson_proof_evaluation.dart';
import 'lesson_session_state.dart';
import 'lesson_stage.dart';

/// Read-only integration contract for the future lesson UI.
///
/// It combines already-established domain state without owning gameplay,
/// Stockfish, rendering, or navigation side effects.
class LessonExperienceState {
  factory LessonExperienceState({
    required LessonSessionState session,
    required TeachingState teaching,
    LessonProofEvaluation? proofEvaluation,
    LessonDefinition? nextLesson,
  }) {
    if (session.lesson.id.isEmpty) {
      throw ArgumentError('Session lesson must have a valid ID.');
    }

    final isResultStage =
        session.stage == LessonStage.result ||
        session.stage == LessonStage.completed;

    if (!isResultStage && proofEvaluation != null) {
      throw ArgumentError(
        'Proof evaluation may only exist in result or completed stages.',
      );
    }

    if (isResultStage && proofEvaluation == null) {
      throw ArgumentError(
        'Result and completed stages require a proof evaluation.',
      );
    }

    if (session.stage != LessonStage.completed && nextLesson != null) {
      throw ArgumentError(
        'A next lesson may only be exposed after session completion.',
      );
    }

    if (proofEvaluation != null &&
        proofEvaluation.actualOutcome != session.outcome) {
      throw ArgumentError(
        'Proof evaluation outcome must match the session outcome.',
      );
    }

    return LessonExperienceState._(
      session: session,
      teaching: teaching,
      proofEvaluation: proofEvaluation,
      nextLesson: nextLesson,
    );
  }

  const LessonExperienceState._({
    required this.session,
    required this.teaching,
    required this.proofEvaluation,
    required this.nextLesson,
  });

  final LessonSessionState session;
  final TeachingState teaching;

  /// Present only after a Prove attempt has explicitly completed.
  final LessonProofEvaluation? proofEvaluation;

  /// Present only after the current lesson has been completed and another
  /// curriculum lesson actually exists.
  final LessonDefinition? nextLesson;

  LessonDefinition get lesson => session.lesson;

  LessonStage get stage => session.stage;

  bool get hasProofEvaluation => proofEvaluation != null;

  bool get hasNextLesson => nextLesson != null;

  bool get isCurriculumEnd =>
      stage == LessonStage.completed && nextLesson == null;
}
