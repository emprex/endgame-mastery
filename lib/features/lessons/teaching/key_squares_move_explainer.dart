import '../../../core/chess/played_move.dart';
import 'move_explanation.dart';
import 'teaching_state.dart';

/// Produces conservative curriculum explanations for key-square geometry.
///
/// It never evaluates move quality and never calls Stockfish.
///
/// An explanation is returned only when the verified pedagogical key-square
/// geometry actually changes between the position before and after the move.
class KeySquaresMoveExplainer {
  const KeySquaresMoveExplainer();

  MoveExplanation? explain({
    required PlayedMove move,
    required TeachingState before,
    required TeachingState after,
  }) {
    final beforeSquares = before.keySquares;
    final afterSquares = after.keySquares;

    if (beforeSquares.isEmpty || afterSquares.isEmpty) {
      return null;
    }

    if (_sameSquares(beforeSquares, afterSquares)) {
      return null;
    }

    final beforeLabel = _squareList(beforeSquares);
    final afterLabel = _squareList(afterSquares);

    return MoveExplanation(
      move: move,
      title: 'Key-square geometry changed',
      message:
          'Before the move, the relevant key squares were $beforeLabel. '
          'After the move, they are $afterLabel. '
          'Re-evaluate which squares the king must reach.',
      source: MoveExplanationSource.curriculum,
    );
  }

  bool _sameSquares(Set<String> first, Set<String> second) {
    return first.length == second.length && first.containsAll(second);
  }

  String _squareList(Set<String> squares) {
    final ordered = squares.toList()..sort();

    if (ordered.length == 1) {
      return ordered.first;
    }

    if (ordered.length == 2) {
      return '${ordered.first} and ${ordered.last}';
    }

    final leading = ordered.sublist(0, ordered.length - 1).join(', ');
    return '$leading, and ${ordered.last}';
  }
}
