import '../domain/lesson_definition.dart';
import '../rules/fen_pawn_locator.dart';
import '../rules/key_squares_rule.dart';
import 'pedagogical_overlay.dart';

/// Converts curriculum knowledge into semantic board annotations.
///
/// This layer sits between LessonDefinition and the future Flutter renderer.
///
/// Stockfish does not participate here.
class PedagogicalOverlayEngine {
  const PedagogicalOverlayEngine({
    this.keySquaresRule = const KeySquaresRule(),
    this.pawnLocator = const FenPawnLocator(),
  });

  final KeySquaresRule keySquaresRule;
  final FenPawnLocator pawnLocator;

  PedagogicalOverlay build({
    required LessonDefinition lesson,
    required String fen,
  }) {
    switch (lesson.concept) {
      case LessonConcept.keySquares:
        return _buildKeySquares(lesson: lesson, fen: fen);
    }
  }

  PedagogicalOverlay _buildKeySquares({
    required LessonDefinition lesson,
    required String fen,
  }) {
    final whitePawns = pawnLocator.whitePawns(fen);

    // The first rule is deliberately limited to a single white pawn.
    //
    // Unsupported positions must not produce invented teaching overlays.
    if (whitePawns.length != 1) {
      return PedagogicalOverlay();
    }

    final keySquares = keySquaresRule.forWhitePawn(whitePawns.single);

    if (keySquares.isEmpty) {
      return PedagogicalOverlay();
    }

    return PedagogicalOverlay(
      squares: keySquares.map(
        (square) =>
            SquareOverlay(square: square, role: SquareOverlayRole.keySquare),
      ),
    );
  }
}
