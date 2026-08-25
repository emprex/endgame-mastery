import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LessonDefinition', () {
    test('first lesson preserves the corrected starting position', () {
      expect(
        keySquaresLesson01.fen,
        '8/3k4/8/3K4/3P4/8/8/8 w - - 0 1',
      );
      expect(keySquaresLesson01.sideToMove, ChessSide.white);
      expect(keySquaresLesson01.userSide, ChessSide.white);
      expect(keySquaresLesson01.concept, LessonConcept.keySquares);
      expect(keySquaresLesson01.theoreticalResult, TheoreticalResult.draw);
      expect(keySquaresLesson01.difficulty, 1);
    });

    test('first lesson exposes the three key squares', () {
      expect(keySquaresLesson01.initialKeySquares, <String>{'c6', 'd6', 'e6'});
      expect(keySquaresLesson01.initialKeySquares.contains('d5'), isFalse);
    });

    test('side to move is derived from FEN', () {
      final lesson = LessonDefinition(
        id: 'black-to-move-test',
        title: 'Black to move',
        fen: '8/3k4/8/3K4/3P4/8/8/8 b - - 0 1',
        concept: LessonConcept.keySquares,
        objective: 'Test objective.',
        learnText: 'Test lesson.',
        userSide: ChessSide.white,
        initialKeySquares: const <String>{'c6', 'd6', 'e6'},
        theoreticalResult: TheoreticalResult.draw,
        difficulty: 1,
      );
      expect(lesson.sideToMove, ChessSide.black);
    });

    test('rejects malformed chess square', () {
      expect(
        () => LessonDefinition(
          id: 'invalid-square',
          title: 'Invalid Square',
          fen: keySquaresLesson01.fen,
          concept: LessonConcept.keySquares,
          objective: 'Test objective.',
          learnText: 'Test lesson.',
          userSide: ChessSide.white,
          initialKeySquares: const <String>{'c9'},
          theoreticalResult: TheoreticalResult.draw,
          difficulty: 1,
        ),
        throwsArgumentError,
      );
    });

    test('rejects duplicate key squares', () {
      expect(
        () => LessonDefinition(
          id: 'duplicate-square',
          title: 'Duplicate Square',
          fen: keySquaresLesson01.fen,
          concept: LessonConcept.keySquares,
          objective: 'Test objective.',
          learnText: 'Test lesson.',
          userSide: ChessSide.white,
          initialKeySquares: const <String>['c6', 'c6'],
          theoreticalResult: TheoreticalResult.draw,
          difficulty: 1,
        ),
        throwsArgumentError,
      );
    });

    test('rejects difficulty outside supported range', () {
      expect(
        () => LessonDefinition(
          id: 'invalid-difficulty',
          title: 'Invalid Difficulty',
          fen: keySquaresLesson01.fen,
          concept: LessonConcept.keySquares,
          objective: 'Test objective.',
          learnText: 'Test lesson.',
          userSide: ChessSide.white,
          initialKeySquares: const <String>{'c6'},
          theoreticalResult: TheoreticalResult.draw,
          difficulty: 0,
        ),
        throwsArgumentError,
      );
    });

    test('rejects malformed FEN', () {
      expect(
        () => LessonDefinition(
          id: 'invalid-fen',
          title: 'Invalid FEN',
          fen: 'not-a-fen',
          concept: LessonConcept.keySquares,
          objective: 'Test objective.',
          learnText: 'Test lesson.',
          userSide: ChessSide.white,
          initialKeySquares: const <String>{'c6'},
          theoreticalResult: TheoreticalResult.draw,
          difficulty: 1,
        ),
        throwsArgumentError,
      );
    });
  });
}
