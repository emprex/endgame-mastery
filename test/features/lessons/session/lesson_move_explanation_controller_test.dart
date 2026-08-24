import 'package:endgame_mastery/core/chess/played_move.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_move_explanation_controller.dart';
import 'package:endgame_mastery/features/lessons/teaching/move_explanation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LessonMoveExplanationController', () {
    test('starts without an explanation', () {
      final controller = LessonMoveExplanationController(
        lesson: keySquaresLesson01,
        initialFen: keySquaresLesson01.fen,
      );

      expect(controller.hasExplanation, isFalse);
      expect(controller.latestExplanation, isNull);
    });

    test('FEN change without a preceding move does not invent explanation', () {
      final controller = LessonMoveExplanationController(
        lesson: keySquaresLesson01,
        initialFen: keySquaresLesson01.fen,
      );

      final explanation = controller.onFenChanged(
        '8/3k4/8/3K4/3P4/8/8/8 b - - 1 1',
      );

      expect(explanation, isNull);
      expect(controller.hasExplanation, isFalse);
    });

    test('records move before waiting for resulting FEN', () {
      final controller = LessonMoveExplanationController(
        lesson: keySquaresLesson01,
        initialFen: keySquaresLesson01.fen,
      );

      controller.onMovePlayed(PlayedMove(from: 'd5', to: 'c5'));

      expect(controller.latestExplanation, isNull);
      expect(controller.currentFen, keySquaresLesson01.fen);
    });

    test(
      'produces curriculum explanation after a real key-square geometry change',
      () {
        const beforeFen = '7k/8/8/8/2KP4/8/8/8 w - - 0 1';

        const afterFen = '7k/8/8/3P4/2K5/8/8/8 b - - 0 1';

        final controller = LessonMoveExplanationController(
          lesson: keySquaresLesson01,
          initialFen: beforeFen,
        );

        controller.onMovePlayed(PlayedMove(from: 'd4', to: 'd5'));

        final explanation = controller.onFenChanged(afterFen);

        expect(explanation, isNotNull);

        expect(explanation!.move.uci, 'd4d5');

        expect(explanation.source, MoveExplanationSource.curriculum);

        expect(explanation.title, 'Key-square geometry changed');

        expect(explanation.message, contains('c6'));

        expect(explanation.message, contains('c7'));

        expect(explanation.message, contains('e7'));

        expect(controller.hasExplanation, isTrue);

        expect(controller.latestExplanation, same(explanation));
      },
    );

    test('reset clears pending and previous explanation state', () {
      final controller = LessonMoveExplanationController(
        lesson: keySquaresLesson01,
        initialFen: keySquaresLesson01.fen,
      );

      controller.onMovePlayed(PlayedMove(from: 'd5', to: 'c5'));

      controller.reset(keySquaresLesson01.fen);

      expect(controller.currentFen, keySquaresLesson01.fen);

      expect(controller.latestExplanation, isNull);

      expect(controller.hasExplanation, isFalse);
    });
  });
}
