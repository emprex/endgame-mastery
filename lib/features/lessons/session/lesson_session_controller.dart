import 'lesson_session_state.dart';
import 'lesson_stage.dart';

/// Controls the legal lifecycle of one lesson session.
///
/// Allowed flow:
///
/// Learn -> Practice -> Prove -> Result -> Completed
///
/// Entering Prove does not automatically create a Result.
/// [completeProof] must be called explicitly.
///
/// This controller deliberately contains no:
/// - Stockfish logic
/// - chess move logic
/// - theoretical evaluation
/// - Flutter dependencies
class LessonSessionController {
  LessonSessionController({required LessonSessionState initialState})
    : _state = initialState;

  LessonSessionState _state;

  LessonSessionState get state => _state;

  /// Advances from Learn to Practice.
  void startPractice() {
    _requireStage(LessonStage.learn, action: 'start practice');

    _setStage(LessonStage.practice);
  }

  /// Advances from Practice to Prove.
  void startProve() {
    _requireStage(LessonStage.practice, action: 'start prove');

    _setStage(LessonStage.prove);
  }

  /// Explicitly completes the proof session and enters Result.
  ///
  /// The actual chess result is intentionally not calculated here.
  void completeProof() {
    _requireStage(LessonStage.prove, action: 'complete proof');

    _setStage(LessonStage.result);
  }

  /// Marks the lesson session as completed after the Result stage.
  void completeLesson() {
    _requireStage(LessonStage.result, action: 'complete lesson');

    _setStage(LessonStage.completed);
  }

  void _setStage(LessonStage stage) {
    _state = _state.copyWith(stage: stage);
  }

  void _requireStage(LessonStage requiredStage, {required String action}) {
    if (_state.stage != requiredStage) {
      throw StateError(
        'Cannot $action while lesson stage is ${_state.stage.name}. '
        'Required stage: ${requiredStage.name}.',
      );
    }
  }
}
