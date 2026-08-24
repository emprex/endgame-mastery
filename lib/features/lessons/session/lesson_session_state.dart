import '../domain/lesson_definition.dart';
import 'lesson_stage.dart';

/// Immutable state of one lesson session.
///
/// The session owns only pedagogical lifecycle state.
/// Gameplay, Stockfish, board state, and theoretical evaluation remain
/// separate concerns.
class LessonSessionState {
  const LessonSessionState({required this.lesson, required this.stage});

  /// Creates a new session at the mandatory initial Learn stage.
  factory LessonSessionState.initial(LessonDefinition lesson) {
    return LessonSessionState(lesson: lesson, stage: LessonStage.learn);
  }

  final LessonDefinition lesson;
  final LessonStage stage;

  LessonSessionState copyWith({LessonStage? stage}) {
    return LessonSessionState(lesson: lesson, stage: stage ?? this.stage);
  }
}
