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

    test('Diagram 1-2 recognizes the verified Ka6 conversion route', () {
      const beforeFen = '1k6/8/1K6/1P6/8/8/8/8 w - - 0 1';
      const afterFen = '1k6/8/K7/1P6/8/8/8/8 b - - 1 1';

      final before = builder.build(lesson: keySquaresLesson02, fen: beforeFen);
      final after = builder.build(lesson: keySquaresLesson02, fen: afterFen);

      final assessment = rule.assess(
        move: PlayedMove(from: 'b6', to: 'a6'),
        before: before,
        after: after,
      );

      expect(assessment, isNotNull);
      expect(assessment!.quality, PedagogicalMoveQuality.reinforcesConcept);
      expect(assessment.title, 'Use the king to convert');
      expect(assessment.message, contains('Ka6'));
    });

    test('Diagram 1-2 treats Kc6 as a supported less direct route', () {
      const beforeFen = '1k6/8/1K6/1P6/8/8/8/8 w - - 0 1';
      const afterFen = '1k6/8/2K5/1P6/8/8/8/8 b - - 1 1';

      final before = builder.build(lesson: keySquaresLesson02, fen: beforeFen);
      final after = builder.build(lesson: keySquaresLesson02, fen: afterFen);

      final assessment = rule.assess(
        move: PlayedMove(from: 'b6', to: 'c6'),
        before: before,
        after: after,
      );

      expect(assessment, isNotNull);
      expect(assessment!.quality, PedagogicalMoveQuality.needsAttention);
      expect(assessment.title, 'A less direct king route');
      expect(assessment.message, contains('still winning'));
      expect(assessment.message, contains('...Ka7'));
    });

    test('Diagram 1-2 recognizes the exact b6 stalemate resource', () {
      const beforeFen = 'k7/2K5/8/1P6/8/8/8/8 w - - 0 1';
      const afterFen = 'k7/2K5/1P6/8/8/8/8/8 b - - 0 1';

      final before = builder.build(lesson: keySquaresLesson02, fen: beforeFen);
      final after = builder.build(lesson: keySquaresLesson02, fen: afterFen);

      final assessment = rule.assess(
        move: PlayedMove(from: 'b5', to: 'b6'),
        before: before,
        after: after,
      );

      expect(assessment, isNotNull);
      expect(assessment!.quality, PedagogicalMoveQuality.needsAttention);
      expect(assessment.title, 'Stalemate resource');
      expect(assessment.message, contains('stalemate'));
      expect(assessment.source, PedagogicalAssessmentSource.curriculum);
    });

    test('Diagram 1-2 does not judge unsupported moves', () {
      const beforeFen = '1k6/8/1K6/1P6/8/8/8/8 w - - 0 1';
      const afterFen = '1k6/2K5/8/1P6/8/8/8/8 b - - 1 1';

      final before = builder.build(lesson: keySquaresLesson02, fen: beforeFen);
      final after = builder.build(lesson: keySquaresLesson02, fen: afterFen);

      final assessment = rule.assess(
        move: PlayedMove(from: 'b6', to: 'c7'),
        before: before,
        after: after,
      );

      expect(assessment, isNull);
    });

    test('Diagram 1-4 recognizes Kf2 as the verified preparation', () {
      const beforeFen = '2k5/8/8/7p/8/8/6P1/5K2 w - - 0 1';
      const afterFen = '2k5/8/8/7p/8/8/5KP1/8 b - - 1 1';

      final before = builder.build(lesson: keySquaresLesson04, fen: beforeFen);
      final after = builder.build(lesson: keySquaresLesson04, fen: afterFen);

      final assessment = rule.assess(
        move: PlayedMove(from: 'f1', to: 'f2'),
        before: before,
        after: after,
      );

      expect(assessment, isNotNull);
      expect(assessment!.quality, PedagogicalMoveQuality.reinforcesConcept);
      expect(assessment.title, 'Prepare for the pawn structure to change');
      expect(assessment.message, contains('Kf2'));
    });

    test('Diagram 1-4 flags the rejected Kg1 first move', () {
      const beforeFen = '2k5/8/8/7p/8/8/6P1/5K2 w - - 0 1';
      const afterFen = '2k5/8/8/7p/8/8/6P1/6K1 b - - 1 1';

      final before = builder.build(lesson: keySquaresLesson04, fen: beforeFen);
      final after = builder.build(lesson: keySquaresLesson04, fen: afterFen);

      final assessment = rule.assess(
        move: PlayedMove(from: 'f1', to: 'g1'),
        before: before,
        after: after,
      );

      expect(assessment, isNotNull);
      expect(assessment!.quality, PedagogicalMoveQuality.needsAttention);
      expect(assessment.title, 'Do not commit the king too early');
    });

    test('Diagram 1-4 recognizes Kg1 after h4 as the verified response', () {
      const beforeFen = '2k5/8/8/8/7p/8/5KP1/8 w - - 0 2';
      const afterFen = '2k5/8/8/8/7p/8/6P1/6K1 b - - 1 2';

      final before = builder.build(lesson: keySquaresLesson04, fen: beforeFen);
      final after = builder.build(lesson: keySquaresLesson04, fen: afterFen);

      final assessment = rule.assess(
        move: PlayedMove(from: 'f2', to: 'g1'),
        before: before,
        after: after,
      );

      expect(assessment, isNotNull);
      expect(assessment!.quality, PedagogicalMoveQuality.reinforcesConcept);
      expect(assessment.title, 'React to the changed structure');
    });

    test('Diagram 1-4 flags Kf3 because of the h3 resource', () {
      const beforeFen = '2k5/8/8/8/7p/8/5KP1/8 w - - 0 2';
      const afterFen = '2k5/8/8/8/7p/5K2/6P1/8 b - - 1 2';

      final before = builder.build(lesson: keySquaresLesson04, fen: beforeFen);
      final after = builder.build(lesson: keySquaresLesson04, fen: afterFen);

      final assessment = rule.assess(
        move: PlayedMove(from: 'f2', to: 'f3'),
        before: before,
        after: after,
      );

      expect(assessment, isNotNull);
      expect(assessment!.quality, PedagogicalMoveQuality.needsAttention);
      expect(assessment.title, 'The structure can change again');
      expect(assessment.message, contains('...h3'));
    });

    test('Diagram 1-4 explains g3 as a key-square recalculation', () {
      const beforeFen = '2k5/8/8/8/8/7p/6P1/6K1 w - - 0 3';
      const afterFen = '2k5/8/8/8/8/6Pp/8/6K1 b - - 0 3';

      final before = builder.build(lesson: keySquaresLesson04, fen: beforeFen);
      final after = builder.build(lesson: keySquaresLesson04, fen: afterFen);

      final assessment = rule.assess(
        move: PlayedMove(from: 'g2', to: 'g3'),
        before: before,
        after: after,
      );

      expect(assessment, isNotNull);
      expect(assessment!.quality, PedagogicalMoveQuality.reinforcesConcept);
      expect(assessment.title, 'Recalculate the key squares');
      expect(assessment.message, contains('f5, g5, and h5'));
      expect(after.keySquares, <String>{'f5', 'g5', 'h5'});
    });
  });
}
