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

  group('PedagogicalOverlayEngine - Key Squares', () {
    const engine = PedagogicalOverlayEngine();

    test('initial position highlights c6 d6 and e6', () {
      final overlay = engine.build(
        lesson: keySquaresLesson01,
        fen: keySquaresLesson01.fen,
      );

      final keySquares = overlay.squares
          .where((overlay) => overlay.role == SquareOverlayRole.keySquare)
          .map((overlay) => overlay.square)
          .toSet();

      expect(keySquares, <String>{'c6', 'd6', 'e6'});

      // White king starts on d5,
      // but d5 is not itself a key square.
      expect(keySquares.contains('d5'), isFalse);
    });

    test('Black to move keeps the same physical key squares', () {
      const blackToMoveFen = '8/3k4/8/3K4/3P4/8/8/8 b - - 0 1';

      final overlay = engine.build(
        lesson: keySquaresLesson01,
        fen: blackToMoveFen,
      );

      expect(overlay.squares.map((overlay) => overlay.square).toSet(), <String>{
        'c6',
        'd6',
        'e6',
      });

      // Important:
      //
      // This test says only that the physical key squares
      // remain c6/d6/e6.
      //
      // It does NOT say that the theoretical result is the same.
      //
      // The LessonDefinition tests separately guarantee:
      //
      // White to move -> draw.
      // Black to move -> White wins.
    });

    test(
      'changed piece placement does not reuse stale initial key squares',
      () {
        final overlay = engine.build(
          lesson: keySquaresLesson01,

          // White pawn has moved from d4 to d5.
          //
          // Phase 3.2 does not yet calculate the new
          // dynamic key squares.
          fen: '8/3k4/8/2KP4/8/8/8/8 b - - 0 1',
        );

        expect(overlay.isEmpty, isTrue);
      },
    );

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
