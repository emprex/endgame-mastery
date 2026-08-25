import 'package:endgame_mastery/core/chess/played_move.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_move_explanation_controller.dart';
import 'package:endgame_mastery/features/lessons/teaching/move_explanation.dart';
import 'package:endgame_mastery/features/lessons/teaching/pedagogical_move_assessment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LessonMoveExplanationController', () {
    test('starts without explanation or assessment', () {
      final controller = LessonMoveExplanationController(
        lesson: keySquaresLesson01,
        initialFen: keySquaresLesson01.fen,
      );

      expect(controller.hasExplanation, isFalse);
      expect(controller.hasAssessment, isFalse);
    });

    test('FEN change without move does not invent feedback', () {
      final controller = LessonMoveExplanationController(
        lesson: keySquaresLesson01,
        initialFen: keySquaresLesson01.fen,
      );

      controller.onFenChanged('8/3k4/8/3K4/3P4/8/8/8 b - - 1 1');

      expect(controller.latestExplanation, isNull);
      expect(controller.latestAssessment, isNull);
    });

    test('produces explanation after learner changes key-square geometry', () {
      const beforeFen = '7k/8/8/8/2KP4/8/8/8 w - - 0 1';
      const afterFen = '7k/8/8/3P4/2K5/8/8/8 b - - 0 1';

      final controller = LessonMoveExplanationController(
        lesson: keySquaresLesson01,
        initialFen: beforeFen,
      );

      controller.onMovePlayed(PlayedMove(from: 'd4', to: 'd5'));

      final explanation = controller.onFenChanged(afterFen);

      expect(explanation, isNotNull);
      expect(explanation!.source, MoveExplanationSource.curriculum);
      expect(explanation.title, 'Key-square geometry changed');
      expect(controller.latestAssessment, isNull);
    });

    test('produces assessment when learner king reaches key square', () {
      const beforeFen = '7k/8/8/3K4/3P4/8/8/8 w - - 0 1';
      const afterFen = '7k/8/2K5/8/3P4/8/8/8 b - - 1 1';

      final controller = LessonMoveExplanationController(
        lesson: keySquaresLesson01,
        initialFen: beforeFen,
      );

      controller.onMovePlayed(PlayedMove(from: 'd5', to: 'c6'));

      controller.onFenChanged(afterFen);

      final assessment = controller.latestAssessment;

      expect(assessment, isNotNull);
      expect(assessment!.quality, PedagogicalMoveQuality.reinforcesConcept);
      expect(assessment.source, PedagogicalAssessmentSource.curriculum);
    });

    test('Stockfish reply keeps learner coaching visible', () {
      const learnerBeforeFen = '7k/8/8/3K4/3P4/8/8/8 w - - 0 1';
      const learnerAfterFen = '7k/8/2K5/8/3P4/8/8/8 b - - 1 1';
      const engineAfterFen = '8/7k/2K5/8/3P4/8/8/8 w - - 2 2';

      final controller = LessonMoveExplanationController(
        lesson: keySquaresLesson01,
        initialFen: learnerBeforeFen,
      );

      controller.onMovePlayed(PlayedMove(from: 'd5', to: 'c6'));
      controller.onFenChanged(learnerAfterFen);

      final learnerAssessment = controller.latestAssessment;

      expect(learnerAssessment, isNotNull);

      controller.onMovePlayed(PlayedMove(from: 'h8', to: 'h7'));
      controller.onFenChanged(engineAfterFen);

      expect(controller.latestAssessment, same(learnerAssessment));
    });

    test('next learner move may replace previous coaching', () {
      const firstBeforeFen = '7k/8/8/3K4/3P4/8/8/8 w - - 0 1';
      const firstAfterFen = '7k/8/2K5/8/3P4/8/8/8 b - - 1 1';
      const engineAfterFen = '8/7k/2K5/8/3P4/8/8/8 w - - 2 2';
      const secondAfterFen = '8/7k/8/2K5/3P4/8/8/8 b - - 3 2';

      final controller = LessonMoveExplanationController(
        lesson: keySquaresLesson01,
        initialFen: firstBeforeFen,
      );

      controller.onMovePlayed(PlayedMove(from: 'd5', to: 'c6'));
      controller.onFenChanged(firstAfterFen);

      final firstAssessment = controller.latestAssessment;

      expect(firstAssessment, isNotNull);

      controller.onMovePlayed(PlayedMove(from: 'h8', to: 'h7'));
      controller.onFenChanged(engineAfterFen);

      expect(controller.latestAssessment, same(firstAssessment));

      controller.onMovePlayed(PlayedMove(from: 'c6', to: 'c5'));
      controller.onFenChanged(secondAfterFen);

      expect(controller.currentFen, secondAfterFen);
    });

    test('reset clears all feedback state', () {
      final controller = LessonMoveExplanationController(
        lesson: keySquaresLesson01,
        initialFen: keySquaresLesson01.fen,
      );

      controller.onMovePlayed(PlayedMove(from: 'd5', to: 'c5'));

      controller.reset(keySquaresLesson01.fen);

      expect(controller.currentFen, keySquaresLesson01.fen);
      expect(controller.latestExplanation, isNull);
      expect(controller.latestAssessment, isNull);
      expect(controller.hasExplanation, isFalse);
      expect(controller.hasAssessment, isFalse);
    });
  });
}
