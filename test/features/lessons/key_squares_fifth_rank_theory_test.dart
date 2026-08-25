import 'package:endgame_mastery/features/lessons/data/pawn_endgame_hints.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Lesson 2 corrected position', () {
    const fen = '1k6/8/1P6/1K6/8/8/8/8 w - - 0 1';

    test('preserves the requested second starting position', () {
      expect(keySquaresLesson02.fen, fen);
      expect(keySquaresLesson02.sideToMove, ChessSide.white);
      expect(keySquaresLesson02.theoreticalResult, TheoreticalResult.draw);
      expect(keySquaresLesson02.difficulty, 1);
    });

    test('does not invent unsupported key-square overlays', () {
      expect(keySquaresLesson02.concept, LessonConcept.practicalAwareness);
      expect(keySquaresLesson02.initialKeySquares, isEmpty);
    });

    test('hints describe the exact b5 king and b6 pawn geometry', () {
      expect(keySquaresLesson02Hints.visual, contains('king b5'));
      expect(keySquaresLesson02Hints.visual, contains('pawn b6'));
      expect(keySquaresLesson02Hints.visual, contains('king b8'));
    });

    test('unknown positions do not inherit theoretical truth', () {
      expect(
        keySquaresLesson02.theoreticalResultForFen(
          '1k6/8/1P6/2K5/8/8/8/8 w - - 0 1',
        ),
        isNull,
      );
    });
  });
}
