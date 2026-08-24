import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_proof_evaluation.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_proof_evaluator.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_outcome.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const evaluator = LessonProofEvaluator();

  const whiteToMoveFen = '8/3k4/8/3K4/3P4/8/8/8 w - - 0 1';

  const blackToMoveFen = '8/3k4/8/3K4/3P4/8/8/8 b - - 0 1';

  group('LessonProofEvaluator', () {
    test('White to move: draw passes', () {
      final evaluation = evaluator.evaluate(
        lesson: keySquaresLesson01,
        proofFen: whiteToMoveFen,
        actualOutcome: LessonSessionOutcome.draw,
      );

      expect(evaluation.proofFen, whiteToMoveFen);
      expect(evaluation.expectedResult, TheoreticalResult.draw);
      expect(evaluation.actualOutcome, LessonSessionOutcome.draw);
      expect(evaluation.verdict, LessonProofVerdict.passed);
      expect(evaluation.isSupported, isTrue);
      expect(evaluation.passed, isTrue);
    });

    test('White to move: win fails because verified result is draw', () {
      final evaluation = evaluator.evaluate(
        lesson: keySquaresLesson01,
        proofFen: whiteToMoveFen,
        actualOutcome: LessonSessionOutcome.win,
      );

      expect(evaluation.expectedResult, TheoreticalResult.draw);
      expect(evaluation.actualOutcome, LessonSessionOutcome.win);
      expect(evaluation.verdict, LessonProofVerdict.failed);
      expect(evaluation.passed, isFalse);
    });

    test('White to move: loss fails because verified result is draw', () {
      final evaluation = evaluator.evaluate(
        lesson: keySquaresLesson01,
        proofFen: whiteToMoveFen,
        actualOutcome: LessonSessionOutcome.loss,
      );

      expect(evaluation.expectedResult, TheoreticalResult.draw);
      expect(evaluation.verdict, LessonProofVerdict.failed);
    });

    test('Black to move: win passes', () {
      final evaluation = evaluator.evaluate(
        lesson: keySquaresLesson01,
        proofFen: blackToMoveFen,
        actualOutcome: LessonSessionOutcome.win,
      );

      expect(evaluation.proofFen, blackToMoveFen);
      expect(evaluation.expectedResult, TheoreticalResult.win);
      expect(evaluation.actualOutcome, LessonSessionOutcome.win);
      expect(evaluation.verdict, LessonProofVerdict.passed);
    });

    test('Black to move: draw fails because verified result is win', () {
      final evaluation = evaluator.evaluate(
        lesson: keySquaresLesson01,
        proofFen: blackToMoveFen,
        actualOutcome: LessonSessionOutcome.draw,
      );

      expect(evaluation.expectedResult, TheoreticalResult.win);
      expect(evaluation.verdict, LessonProofVerdict.failed);
    });

    test('side to move remains part of proof truth', () {
      final whiteToMove = evaluator.evaluate(
        lesson: keySquaresLesson01,
        proofFen: whiteToMoveFen,
        actualOutcome: LessonSessionOutcome.draw,
      );

      final blackToMove = evaluator.evaluate(
        lesson: keySquaresLesson01,
        proofFen: blackToMoveFen,
        actualOutcome: LessonSessionOutcome.draw,
      );

      expect(whiteToMove.verdict, LessonProofVerdict.passed);
      expect(blackToMove.verdict, LessonProofVerdict.failed);

      expect(whiteToMove.expectedResult, TheoreticalResult.draw);
      expect(blackToMove.expectedResult, TheoreticalResult.win);
    });

    test('unknown FEN is unsupported instead of guessed', () {
      const unknownFen = '8/3k4/8/4K3/3P4/8/8/8 w - - 0 1';

      final evaluation = evaluator.evaluate(
        lesson: keySquaresLesson01,
        proofFen: unknownFen,
        actualOutcome: LessonSessionOutcome.win,
      );

      expect(evaluation.proofFen, unknownFen);
      expect(evaluation.expectedResult, isNull);
      expect(evaluation.verdict, LessonProofVerdict.unsupported);
      expect(evaluation.isSupported, isFalse);
      expect(evaluation.passed, isFalse);
    });

    test('normalizes surrounding FEN whitespace', () {
      final evaluation = evaluator.evaluate(
        lesson: keySquaresLesson01,
        proofFen: '  $whiteToMoveFen  ',
        actualOutcome: LessonSessionOutcome.draw,
      );

      expect(evaluation.proofFen, whiteToMoveFen);
      expect(evaluation.verdict, LessonProofVerdict.passed);
    });
  });
}
