import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/overlay/pedagogical_overlay.dart';
import 'package:endgame_mastery/features/lessons/overlay/pedagogical_overlay_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PedagogicalOverlay primitives', () {
    test('square overlay normalizes chess square', () {
      final overlay = SquareOverlay(
        square: ' C6 ',
        role: SquareOverlayRole.keySquare,
      );
      expect(overlay.square, 'c6');
    });

    test('square overlay rejects invalid square', () {
      expect(
        () => SquareOverlay(square: 'i9', role: SquareOverlayRole.highlight),
        throwsArgumentError,
      );
    });

    test('arrow rejects identical origin and destination', () {
      expect(() => ArrowOverlay(from: 'd5', to: 'd5'), throwsArgumentError);
    });

    test('zone requires at least one square', () {
      expect(() => ZoneOverlay(squares: const <String>[]), throwsArgumentError);
    });
  });

  group('PedagogicalOverlayEngine - corrected opening lessons', () {
    const engine = PedagogicalOverlayEngine();

    test('first position highlights the three key squares', () {
      final overlay = engine.build(
        lesson: keySquaresLesson01,
        fen: keySquaresLesson01.fen,
      );

      final keySquares = overlay.squares
          .where((overlay) => overlay.role == SquareOverlayRole.keySquare)
          .map((overlay) => overlay.square)
          .toSet();

      expect(keySquares, <String>{'c6', 'd6', 'e6'});
    });

    test('second position highlights the six fifth-rank key squares', () {
      final overlay = engine.build(
        lesson: keySquaresLesson02,
        fen: keySquaresLesson02.fen,
      );

      final keySquares = overlay.squares
          .where((overlay) => overlay.role == SquareOverlayRole.keySquare)
          .map((overlay) => overlay.square)
          .toSet();

      expect(keySquares, <String>{'a6', 'b6', 'c6', 'a7', 'b7', 'c7'});
    });

    test('unsupported later pawn rank produces no invented overlay', () {
      final overlay = engine.build(
        lesson: keySquaresLesson01,
        fen: '8/3k4/3P4/2K5/8/8/8/8 b - - 0 1',
      );
      expect(overlay.isEmpty, isTrue);
    });

    test('generated overlay collections are immutable', () {
      final overlay = engine.build(
        lesson: keySquaresLesson01,
        fen: keySquaresLesson01.fen,
      );

      expect(
        () => overlay.squares.add(
          SquareOverlay(square: 'a1', role: SquareOverlayRole.highlight),
        ),
        throwsUnsupportedError,
      );
    });
  });
}
