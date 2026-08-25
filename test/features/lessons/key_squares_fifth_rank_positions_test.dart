import 'package:endgame_mastery/features/lessons/data/pawn_endgame_positions.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_position_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Lesson 2 position pack', () {
    const fen = '1k6/8/1P6/1K6/8/8/8/8 w - - 0 1';

    test('uses the exact requested position for learn practice and prove', () {
      expect(keySquaresLesson02Positions.length, 3);

      for (final position in keySquaresLesson02Positions) {
        expect(position.fen, fen);
        expect(position.sideToMove, ChessSide.white);
        expect(position.theoreticalResult, TheoreticalResult.draw);
      }
    });

    test('contains one learn one practice and one prove position', () {
      expect(
        keySquaresLesson02Positions
            .where((position) => position.role == LessonPositionRole.learn)
            .length,
        1,
      );
      expect(
        keySquaresLesson02Positions
            .where((position) => position.role == LessonPositionRole.practice)
            .length,
        1,
      );
      expect(
        keySquaresLesson02Positions
            .where((position) => position.role == LessonPositionRole.prove)
            .length,
        1,
      );
    });
  });
}
