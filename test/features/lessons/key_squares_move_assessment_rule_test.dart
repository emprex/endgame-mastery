import 'package:endgame_mastery/core/chess/played_move.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/teaching/key_squares_move_assessment_rule.dart';
import 'package:endgame_mastery/features/lessons/teaching/pedagogical_move_assessment.dart';
import 'package:endgame_mastery/features/lessons/teaching/teaching_state_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KeySquaresMoveAssessmentRule', () {
    const rule = KeySquaresMoveAssessmentRule();
    const builder = TeachingStateBuilder();

    test('reinforces concept when white king reaches a key square', () {
      const beforeFen = '7k/8/8/3K4/3P4/8/8/8 w - - 0 1';

      const afterFen = '7k/8/2K5/8/3P4/8/8/8 b - - 1 1';

      final before = builder.build(lesson: keySquaresLesson01, fen: beforeFen);

      final after = builder.build(lesson: keySquaresLesson01, fen: afterFen);

      final assessment = rule.assess(
        move: PlayedMove(from: 'd5', to: 'c6'),
        before: before,
        after: after,
      );

      expect(assessment, isNotNull);

      expect(assessment!.quality, PedagogicalMoveQuality.reinforcesConcept);

      expect(assessment.title, 'You reached a key square');

      expect(assessment.message, contains('c6'));

      expect(assessment.source, PedagogicalAssessmentSource.curriculum);
    });

    test('does not judge king move that does not reach a key square', () {
      const beforeFen = '7k/8/8/3K4/3P4/8/8/8 w - - 0 1';

      const afterFen = '7k/8/8/2K5/3P4/8/8/8 b - - 1 1';

      final before = builder.build(lesson: keySquaresLesson01, fen: beforeFen);

      final after = builder.build(lesson: keySquaresLesson01, fen: afterFen);

      final assessment = rule.assess(
        move: PlayedMove(from: 'd5', to: 'c5'),
        before: before,
        after: after,
      );

      expect(assessment, isNull);
    });

    test('does not mistake a pawn move for a king move', () {
      const beforeFen = '7k/8/2K5/8/3P4/8/8/8 w - - 0 1';

      const afterFen = '7k/8/2K5/3P4/8/8/8/8 b - - 0 1';

      final before = builder.build(lesson: keySquaresLesson01, fen: beforeFen);

      final after = builder.build(lesson: keySquaresLesson01, fen: afterFen);

      final assessment = rule.assess(
        move: PlayedMove(from: 'd4', to: 'd5'),
        before: before,
        after: after,
      );

      expect(assessment, isNull);
    });

    test('does not automatically condemn leaving a key square', () {
      const beforeFen = '7k/8/2K5/8/3P4/8/8/8 w - - 0 1';

      const afterFen = '7k/8/8/2K5/3P4/8/8/8 b - - 1 1';

      final before = builder.build(lesson: keySquaresLesson01, fen: beforeFen);

      final after = builder.build(lesson: keySquaresLesson01, fen: afterFen);

      final assessment = rule.assess(
        move: PlayedMove(from: 'c6', to: 'c5'),
        before: before,
        after: after,
      );

      expect(assessment, isNull);
    });
  });
}
