import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/teaching/teaching_state_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TeachingStateBuilder - corrected opening lessons', () {
    const builder = TeachingStateBuilder();

    test('first lesson state is a known draw with three key squares', () {
      final state = builder.build(
        lesson: keySquaresLesson01,
        fen: keySquaresLesson01.fen,
      );

      expect(state.sideToMove, ChessSide.white);
      expect(state.theoreticalResult, TheoreticalResult.draw);
      expect(state.hasKnownTheoreticalResult, isTrue);
      expect(state.keySquares, <String>{'c6', 'd6', 'e6'});
    });

    test('second lesson state is a known win with six key squares', () {
      final state = builder.build(
        lesson: keySquaresLesson02,
        fen: keySquaresLesson02.fen,
      );

      expect(state.sideToMove, ChessSide.white);
      expect(state.theoreticalResult, TheoreticalResult.win);
      expect(state.hasKnownTheoreticalResult, isTrue);
      expect(state.keySquares, <String>{
        'a6', 'b6', 'c6', 'a7', 'b7', 'c7',
      });
    });

    test('unknown first-lesson FEN has no invented theoretical result', () {
      final state = builder.build(
        lesson: keySquaresLesson01,
        fen: '8/3k4/8/4K3/3P4/8/8/8 w - - 0 1',
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
