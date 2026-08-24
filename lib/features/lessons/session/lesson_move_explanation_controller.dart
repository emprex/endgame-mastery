import '../../../core/chess/played_move.dart';
import '../domain/lesson_definition.dart';
import '../teaching/key_squares_move_explainer.dart';
import '../teaching/move_explanation.dart';
import '../teaching/teaching_state_builder.dart';

/// Coordinates move events with before/after pedagogical positions.
///
/// BoardScreen reports the completed move before it reports the resulting FEN.
/// This controller deliberately waits for both pieces of information before
/// asking a curriculum explainer for a pedagogical interpretation.
///
/// It does not run Stockfish and does not evaluate move quality.
class LessonMoveExplanationController {
  LessonMoveExplanationController({
    required this.lesson,
    required String initialFen,
    this.teachingStateBuilder = const TeachingStateBuilder(),
    this.keySquaresMoveExplainer = const KeySquaresMoveExplainer(),
  }) : _currentFen = initialFen.trim();

  final LessonDefinition lesson;
  final TeachingStateBuilder teachingStateBuilder;
  final KeySquaresMoveExplainer keySquaresMoveExplainer;

  String _currentFen;

  PlayedMove? _pendingMove;
  String? _pendingBeforeFen;

  MoveExplanation? _latestExplanation;

  String get currentFen => _currentFen;

  MoveExplanation? get latestExplanation => _latestExplanation;

  bool get hasExplanation => _latestExplanation != null;

  void onMovePlayed(PlayedMove move) {
    _pendingMove = move;
    _pendingBeforeFen = _currentFen;

    // Never leave feedback from a previous move visible while a new move
    // is waiting for its resulting position.
    _latestExplanation = null;
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
      _latestExplanation = null;
      return null;
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

    _pendingMove = null;
    _pendingBeforeFen = null;

    return _latestExplanation;
  }

  void reset(String fen) {
    _currentFen = fen.trim();
    _pendingMove = null;
    _pendingBeforeFen = null;
    _latestExplanation = null;
  }
}
