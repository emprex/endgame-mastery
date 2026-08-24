import '../domain/lesson_definition.dart';
import 'lesson_session_outcome.dart';
import 'lesson_stage.dart';

/// Immutable state of one lesson session.
///
/// The session owns only pedagogical lifecycle state.
///
/// Gameplay, Stockfish, board state, and theoretical evaluation remain
/// separate concerns.
class LessonSessionState {
  factory LessonSessionState({
    required LessonDefinition lesson,
    required LessonStage stage,
    LessonSessionOutcome? outcome,
  }) {
    final requiresOutcome =
        stage == LessonStage.result || stage == LessonStage.completed;

    if (requiresOutcome && outcome == null) {
      throw ArgumentError(
        'Result and completed lesson stages require a session outcome.',
      );
    }

    if (!requiresOutcome && outcome != null) {
      throw ArgumentError(
        'A session outcome may only exist in result or completed stages.',
      );
    }

    return LessonSessionState._(lesson: lesson, stage: stage, outcome: outcome);
  }

  const LessonSessionState._({
    required this.lesson,
    required this.stage,
    required this.outcome,
  });

  /// Creates a new session at the mandatory initial Learn stage.
  factory LessonSessionState.initial(LessonDefinition lesson) {
    return LessonSessionState(lesson: lesson, stage: LessonStage.learn);
  }

  final LessonDefinition lesson;
  final LessonStage stage;

  /// Actual result achieved by the learner during Prove.
  ///
  /// Null before the proof has explicitly completed.
  final LessonSessionOutcome? outcome;

  LessonSessionState copyWith({
    LessonStage? stage,
    LessonSessionOutcome? outcome,
  }) {
    return LessonSessionState(
      lesson: lesson,
      stage: stage ?? this.stage,
      outcome: outcome ?? this.outcome,
    );
  }
}
