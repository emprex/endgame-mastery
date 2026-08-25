import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/teaching/teaching_state_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TeachingStateBuilder - corrected opening lessons', () {
    const builder = TeachingStateBuilder();
    const firstFen = '8/3k4/8/3P4/3K4/8/8/8 w - - 0 1';
    const secondFen = '1k6/8/1P6/1K6/8/8/8/8 w - - 0 1';

    test('first lesson state is a known draw with six key squares', () {
      final state = builder.build(lesson: keySquaresLesson01, fen: firstFen);

      expect(state.sideToMove, ChessSide.white);
      expect(state.theoreticalResult, TheoreticalResult.draw);
      expect(state.hasKnownTheoreticalResult, isTrue);
      expect(state.keySquares, <String>{
        'c6', 'd6', 'e6', 'c7', 'd7', 'e7',
      });
    });

    test('second lesson state is a known draw without invented overlays', () {
      final state = builder.build(lesson: keySquaresLesson02, fen: secondFen);

      expect(state.sideToMove, ChessSide.white);
      expect(state.theoreticalResult, TheoreticalResult.draw);
      expect(state.hasKnownTheoreticalResult, isTrue);
      expect(state.keySquares, isEmpty);
    });

    test('unknown first-lesson FEN has no invented theoretical result', () {
      final state = builder.build(
        lesson: keySquaresLesson01,
        fen: '8/3k4/8/3P4/4K3/8/8/8 w - - 0 1',
      );

      expect(state.theoreticalResult, isNull);
      expect(state.hasKnownTheoreticalResult, isFalse);
    });

    test('malformed FEN is rejected before teaching state is built', () {
      expect(
        () => builder.build(lesson: keySquaresLesson01, fen: 'not-a-fen'),
        throwsArgumentError,
      );
    });
  });
}
