import '../../../core/chess/played_move.dart';
import '../domain/lesson_definition.dart';
import '../teaching/key_squares_move_assessment_rule.dart';
import '../teaching/key_squares_move_explainer.dart';
import '../teaching/move_explanation.dart';
import '../teaching/pedagogical_move_assessment.dart';
import '../teaching/teaching_state_builder.dart';

/// Coordinates learner move events with before/after pedagogical positions.
///
/// BoardScreen reports the completed move before it reports the resulting FEN.
/// This controller waits for both before producing curriculum feedback.
///
/// Only the learner's moves may create or replace coaching. Engine replies
/// update the tracked position but leave the learner's latest coaching visible.
///
/// It does not run Stockfish and does not calculate engine move quality.
class LessonMoveExplanationController {
  LessonMoveExplanationController({
    required this.lesson,
    required String initialFen,
    this.teachingStateBuilder = const TeachingStateBuilder(),
    this.keySquaresMoveExplainer = const KeySquaresMoveExplainer(),
    this.keySquaresMoveAssessmentRule = const KeySquaresMoveAssessmentRule(),
  }) : _currentFen = initialFen.trim();

  final LessonDefinition lesson;
  final TeachingStateBuilder teachingStateBuilder;
  final KeySquaresMoveExplainer keySquaresMoveExplainer;
  final KeySquaresMoveAssessmentRule keySquaresMoveAssessmentRule;

  String _currentFen;

  PlayedMove? _pendingMove;
  String? _pendingBeforeFen;

  MoveExplanation? _latestExplanation;
  PedagogicalMoveAssessment? _latestAssessment;

  String get currentFen => _currentFen;

  MoveExplanation? get latestExplanation => _latestExplanation;

  PedagogicalMoveAssessment? get latestAssessment => _latestAssessment;

  bool get hasExplanation => _latestExplanation != null;

  bool get hasAssessment => _latestAssessment != null;

  void onMovePlayed(PlayedMove move) {
    if (!_isLearnerToMove(_currentFen)) {
      _pendingMove = null;
      _pendingBeforeFen = null;
      return;
    }

    _pendingMove = move;
    _pendingBeforeFen = _currentFen;
  }

  MoveExplanation? onFenChanged(String fen) {
    final normalizedFen = fen.trim();

    if (normalizedFen == _currentFen) {
      return _latestExplanation;
    }

    final move = _pendingMove;
    final beforeFen = _pendingBeforeFen;

    _currentFen = normalizedFen;

    if (move == null || beforeFen == null) {
      return _latestExplanation;
    }

    final before = teachingStateBuilder.build(lesson: lesson, fen: beforeFen);

    final after = teachingStateBuilder.build(
      lesson: lesson,
      fen: normalizedFen,
    );

    _latestExplanation = keySquaresMoveExplainer.explain(
      move: move,
      before: before,
      after: after,
    );

    _latestAssessment = keySquaresMoveAssessmentRule.assess(
      move: move,
      before: before,
      after: after,
    );

    _pendingMove = null;
    _pendingBeforeFen = null;

    return _latestExplanation;
  }

  void reset(String fen) {
    _currentFen = fen.trim();
    _pendingMove = null;
    _pendingBeforeFen = null;
    _latestExplanation = null;
    _latestAssessment = null;
  }

  bool _isLearnerToMove(String fen) {
    final fields = fen.trim().split(RegExp(r'\s+'));

    if (fields.length < 2) {
      return false;
    }

    final sideToMove = fields[1] == 'b'
        ? ChessSide.black
        : fields[1] == 'w'
        ? ChessSide.white
        : null;

    return sideToMove == lesson.userSide;
  }
}
