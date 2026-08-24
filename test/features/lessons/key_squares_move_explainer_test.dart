import 'package:endgame_mastery/core/chess/played_move.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/overlay/pedagogical_overlay.dart';
import 'package:endgame_mastery/features/lessons/teaching/key_squares_move_explainer.dart';
import 'package:endgame_mastery/features/lessons/teaching/move_explanation.dart';
import 'package:endgame_mastery/features/lessons/teaching/teaching_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TeachingState teachingStateWithKeySquares(Set<String> keySquares) {
    return TeachingState(
      fen: '8/8/8/8/8/8/8/8 w - - 0 1',
      sideToMove: ChessSide.white,
      theoreticalResult: null,
      overlay: PedagogicalOverlay(
        squares: keySquares
            .map(
              (square) => SquareOverlay(
                square: square,
                role: SquareOverlayRole.keySquare,
              ),
            )
            .toList(),
      ),
      teachingPoint: null,
    );
  }

  group('KeySquaresMoveExplainer', () {
    const explainer = KeySquaresMoveExplainer();

    final move = PlayedMove(from: 'd4', to: 'd5');

    test('returns explanation when key-square geometry changes', () {
      final before = teachingStateWithKeySquares(<String>{'c6', 'd6', 'e6'});

      final after = teachingStateWithKeySquares(<String>{
        'c6',
        'd6',
        'e6',
        'c7',
        'd7',
        'e7',
      });

      final explanation = explainer.explain(
        move: move,
        before: before,
        after: after,
      );

      expect(explanation, isNotNull);

      expect(explanation!.title, 'Key-square geometry changed');

      expect(explanation.move.uci, 'd4d5');

      expect(explanation.source, MoveExplanationSource.curriculum);

      expect(explanation.message, contains('c6'));

      expect(explanation.message, contains('e7'));
    });

    test('returns null when key squares do not change', () {
      final before = teachingStateWithKeySquares(<String>{'c6', 'd6', 'e6'});

      final after = teachingStateWithKeySquares(<String>{'e6', 'c6', 'd6'});

      final explanation = explainer.explain(
        move: move,
        before: before,
        after: after,
      );

      expect(explanation, isNull);
    });

    test('returns null when previous position has no known key squares', () {
      final before = teachingStateWithKeySquares(<String>{});

      final after = teachingStateWithKeySquares(<String>{'c6', 'd6', 'e6'});

      final explanation = explainer.explain(
        move: move,
        before: before,
        after: after,
      );

      expect(explanation, isNull);
    });

    test('returns null when resulting position has no known key squares', () {
      final before = teachingStateWithKeySquares(<String>{'c6', 'd6', 'e6'});

      final after = teachingStateWithKeySquares(<String>{});

      final explanation = explainer.explain(
        move: move,
        before: before,
        after: after,
      );

      expect(explanation, isNull);
    });

    test('ignores non-key-square overlays', () {
      final before = TeachingState(
        fen: '8/8/8/8/8/8/8/8 w - - 0 1',
        sideToMove: ChessSide.white,
        theoreticalResult: null,
        overlay: PedagogicalOverlay(
          squares: [
            SquareOverlay(square: 'c6', role: SquareOverlayRole.highlight),
          ],
        ),
        teachingPoint: null,
      );

      final after = teachingStateWithKeySquares(<String>{'c6', 'd6', 'e6'});

      final explanation = explainer.explain(
        move: move,
        before: before,
        after: after,
      );

      expect(explanation, isNull);
    });
  });
}
