import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/teaching/teaching_state_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TeachingStateBuilder - Key Squares', () {
    const builder = TeachingStateBuilder();

    const whiteToMoveFen = '8/3k4/8/3K4/3P4/8/8/8 w - - 0 1';

    const blackToMoveFen = '8/3k4/8/3K4/3P4/8/8/8 b - - 0 1';

    const pawnOnD5Fen = '8/3k4/8/2KP4/8/8/8/8 b - - 0 1';

    test('White to move teaching state is a draw', () {
      final state = builder.build(
        lesson: keySquaresLesson01,
        fen: whiteToMoveFen,
      );

      expect(state.sideToMove, ChessSide.white);

      expect(state.theoreticalResult, TheoreticalResult.draw);

      expect(state.hasKnownTheoreticalResult, isTrue);

      expect(state.keySquares, <String>{'c6', 'd6', 'e6'});
    });

    test('Black to move teaching state is winning for White', () {
      final state = builder.build(
        lesson: keySquaresLesson01,
        fen: blackToMoveFen,
      );

      expect(state.sideToMove, ChessSide.black);

      expect(state.theoreticalResult, TheoreticalResult.win);

      expect(state.keySquares, <String>{'c6', 'd6', 'e6'});

      expect(state.teachingPoint, contains('Black must retreat'));
    });

    test('side to move changes result but not physical key squares', () {
      final whiteState = builder.build(
        lesson: keySquaresLesson01,
        fen: whiteToMoveFen,
      );

      final blackState = builder.build(
        lesson: keySquaresLesson01,
        fen: blackToMoveFen,
      );

      expect(whiteState.keySquares, blackState.keySquares);

      expect(whiteState.theoreticalResult, isNot(blackState.theoreticalResult));
    });

    test(
      'live pawn advance to d5 updates key squares without inventing theory',
      () {
        final state = builder.build(
          lesson: keySquaresLesson01,
          fen: pawnOnD5Fen,
        );

        expect(state.sideToMove, ChessSide.black);

        expect(state.keySquares, <String>{'c6', 'd6', 'e6', 'c7', 'd7', 'e7'});

        // Dynamic pedagogical geometry can be known even when this exact
        // full position has no verified curriculum result attached to it.
        expect(state.theoreticalResult, isNull);

        expect(state.hasKnownTheoreticalResult, isFalse);

        expect(state.teachingPoint, isNull);
      },
    );

    test('malformed FEN is rejected before teaching state is built', () {
      expect(
        () => builder.build(lesson: keySquaresLesson01, fen: 'not-a-fen'),
        throwsArgumentError,
      );
    });
  });
}
