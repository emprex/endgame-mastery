import 'package:endgame_mastery/features/lessons/data/pawn_endgame_positions.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_position_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Lesson 2 position pack', () {
    const fen = '1k6/8/1K6/1P6/8/8/8/8 w - - 0 1';

    test('uses the exact Diagram 1-2 position for learn first practice and prove', () {
      expect(keySquaresLesson02Positions.length, 5);

      final learn = keySquaresLesson02Positions.singleWhere(
        (position) => position.role == LessonPositionRole.learn,
      );
      final prove = keySquaresLesson02Positions.singleWhere(
        (position) => position.role == LessonPositionRole.prove,
      );
      final practice = keySquaresLesson02Positions
          .where((position) => position.role == LessonPositionRole.practice)
          .toList(growable: false);

      expect(learn.fen, fen);
      expect(practice.first.fen, fen);
      expect(prove.fen, fen);
      expect(learn.sideToMove, ChessSide.white);
      expect(practice.first.sideToMove, ChessSide.white);
      expect(prove.sideToMove, ChessSide.white);
      expect(learn.theoreticalResult, TheoreticalResult.win);
      expect(practice.first.theoreticalResult, TheoreticalResult.win);
      expect(prove.theoreticalResult, TheoreticalResult.win);
    });

    test('then uses the two published Diagram 1-2 practice checkpoints', () {
      final practice = keySquaresLesson02Positions
          .where((position) => position.role == LessonPositionRole.practice)
          .toList(growable: false);

      expect(practice.length, 3);
      expect(practice[0].fen, fen);
      expect(practice[1].fen, '8/k7/2K5/1P6/8/8/8/8 w - - 0 1');
      expect(practice[2].fen, 'k7/2K5/8/1P6/8/8/8/8 w - - 0 1');

      for (final position in practice) {
        expect(position.sideToMove, ChessSide.white);
        expect(position.theoreticalResult, TheoreticalResult.win);
      }
    });
  });
}
