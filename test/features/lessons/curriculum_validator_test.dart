import 'package:endgame_mastery/features/lessons/data/curriculum.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/validation/curriculum_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurriculumValidator', () {
    const validator = CurriculumValidator();

    test('current curriculum is valid', () {
      final result = validator.validate(curriculum);
      expect(result.isValid, isTrue);
      expect(result.issues, isEmpty);
    });

    test('rejects duplicate lesson ids', () {
      final duplicateLesson = LessonDefinition(
        id: keySquaresLesson01.id,
        title: 'Duplicate',
        fen: keySquaresLesson01.fen,
        concept: LessonConcept.keySquares,
        objective: 'Duplicate test.',
        learnText: 'Duplicate test lesson.',
        userSide: ChessSide.white,
        initialKeySquares: const <String>{'c6', 'd6', 'e6'},
        theoreticalResult: TheoreticalResult.draw,
        difficulty: 1,
      );

      final result = validator.validate(<LessonDefinition>[
        keySquaresLesson01,
        duplicateLesson,
      ]);

      expect(result.isValid, isFalse);
      expect(result.issues.any((issue) => issue.message.contains('unique')), isTrue);
    });

    test('Key Squares lesson requires at least one key square', () {
      final lesson = LessonDefinition(
        id: 'missing-key-squares',
        title: 'Missing Key Squares',
        fen: keySquaresLesson01.fen,
        concept: LessonConcept.keySquares,
        objective: 'Validation test.',
        learnText: 'Validation test.',
        userSide: ChessSide.white,
        initialKeySquares: const <String>{},
        theoreticalResult: TheoreticalResult.draw,
        difficulty: 1,
      );

      final result = validator.validate(<LessonDefinition>[lesson]);
      expect(result.isValid, isFalse);
      expect(
        result.issues.any(
          (issue) => issue.message.contains('must define initial key squares'),
        ),
        isTrue,
      );
    });

    test('first two corrected lesson positions resolve to verified results', () {
      expect(
        keySquaresLesson01.theoreticalResultForFen(keySquaresLesson01.fen),
        TheoreticalResult.draw,
      );
      expect(
        keySquaresLesson02.theoreticalResultForFen(keySquaresLesson02.fen),
        TheoreticalResult.win,
      );
    });
  });
}
