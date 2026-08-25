import 'package:endgame_mastery/features/lessons/data/pawn_endgame_hints.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Diagram 1-2 exact theory', () {
    const fen = '1k6/8/1K6/1P6/8/8/8/8 w - - 0 1';

    test('preserves White king b6 pawn b5 Black king b8', () {
      expect(keySquaresLesson02.fen, fen);
      expect(keySquaresLesson02.sideToMove, ChessSide.white);
      expect(keySquaresLesson02.theoreticalResult, TheoreticalResult.win);
      expect(keySquaresLesson02.difficulty, 1);
    });

    test('defines the six key squares for the b5 pawn', () {
      expect(keySquaresLesson02.concept, LessonConcept.keySquares);
      expect(keySquaresLesson02.initialKeySquares, <String>{
        'a6',
        'b6',
        'c6',
        'a7',
        'b7',
        'c7',
      });
    });

    test('hints say the king already occupies b6', () {
      expect(keySquaresLesson02Hints.visual, contains('pawn on b5'));
      expect(keySquaresLesson02Hints.visual, contains('standing on b6'));
      expect(keySquaresLesson02Hints.visual, contains('a6, b6, c6, a7, b7, and c7'));
    });

    test('unknown positions do not inherit theoretical truth', () {
      expect(
        keySquaresLesson02.theoreticalResultForFen(
          '1k6/8/2K5/1P6/8/8/8/8 w - - 0 1',
        ),
        isNull,
      );
    });
  });
}
