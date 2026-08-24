import 'package:endgame_mastery/features/lessons/data/curriculum.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_experience_builder.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_progression.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_proof_evaluation.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_outcome.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_state.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_stage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const builder = LessonExperienceBuilder();

  const whiteToMoveFen = '8/3k4/8/3K4/3P4/8/8/8 w - - 0 1';

  const blackToMoveFen = '8/3k4/8/3K4/3P4/8/8/8 b - - 0 1';

  LessonDefinition testLesson(String id) {
    return LessonDefinition(
      id: id,
      title: 'Test Lesson',
      fen: whiteToMoveFen,
      concept: LessonConcept.keySquares,
      objective: 'Integration contract test.',
      learnText: 'Integration contract test.',
      userSide: ChessSide.white,
      initialKeySquares: const <String>{'c6', 'd6', 'e6'},
      theoreticalResult: TheoreticalResult.draw,
      difficulty: 1,
    );
  }

  group('LessonExperienceBuilder', () {
    test('Learn exposes teaching state without proof evaluation', () {
      final session = LessonSessionState.initial(keySquaresLesson01);

      final experience = builder.build(
        session: session,
        currentFen: whiteToMoveFen,
      );

      expect(experience.lesson, same(keySquaresLesson01));
      expect(experience.stage, LessonStage.learn);
      expect(experience.teaching.fen, whiteToMoveFen);
      expect(experience.teaching.theoreticalResult, TheoreticalResult.draw);
      expect(experience.hasProofEvaluation, isFalse);
      expect(experience.hasNextLesson, isFalse);
      expect(experience.isCurriculumEnd, isFalse);
    });

    test('Practice accepts a changed current FEN', () {
      final session = LessonSessionState(
        lesson: keySquaresLesson01,
        stage: LessonStage.practice,
      );

      final experience = builder.build(
        session: session,
        currentFen: blackToMoveFen,
      );

      expect(experience.stage, LessonStage.practice);
      expect(experience.teaching.fen, blackToMoveFen);
      expect(experience.teaching.theoreticalResult, TheoreticalResult.win);
    });

    test('Result evaluates exact proof starting FEN', () {
      final session = LessonSessionState(
        lesson: keySquaresLesson01,
        stage: LessonStage.result,
        outcome: LessonSessionOutcome.win,
      );

      final experience = builder.build(
        session: session,
        currentFen: blackToMoveFen,
        proofFen: blackToMoveFen,
      );

      expect(experience.hasProofEvaluation, isTrue);
      expect(experience.proofEvaluation!.verdict, LessonProofVerdict.passed);
      expect(experience.proofEvaluation!.expectedResult, TheoreticalResult.win);
    });

    test('Result uses proof FEN rather than current final FEN', () {
      final session = LessonSessionState(
        lesson: keySquaresLesson01,
        stage: LessonStage.result,
        outcome: LessonSessionOutcome.draw,
      );

      final experience = builder.build(
        session: session,
        currentFen: blackToMoveFen,
        proofFen: whiteToMoveFen,
      );

      expect(experience.teaching.fen, blackToMoveFen);

      expect(experience.proofEvaluation!.proofFen, whiteToMoveFen);

      expect(
        experience.proofEvaluation!.expectedResult,
        TheoreticalResult.draw,
      );

      expect(experience.proofEvaluation!.verdict, LessonProofVerdict.passed);
    });

    test('unknown proof FEN remains unsupported', () {
      const unknownFen = '8/3k4/8/4K3/3P4/8/8/8 w - - 0 1';

      final session = LessonSessionState(
        lesson: keySquaresLesson01,
        stage: LessonStage.result,
        outcome: LessonSessionOutcome.win,
      );

      final experience = builder.build(
        session: session,
        currentFen: unknownFen,
        proofFen: unknownFen,
      );

      expect(
        experience.proofEvaluation!.verdict,
        LessonProofVerdict.unsupported,
      );

      expect(experience.proofEvaluation!.expectedResult, isNull);
    });

    test('Result requires proof starting FEN', () {
      final session = LessonSessionState(
        lesson: keySquaresLesson01,
        stage: LessonStage.result,
        outcome: LessonSessionOutcome.draw,
      );

      expect(
        () => builder.build(session: session, currentFen: whiteToMoveFen),
        throwsArgumentError,
      );
    });

    test('proof FEN is rejected before Result', () {
      final session = LessonSessionState(
        lesson: keySquaresLesson01,
        stage: LessonStage.prove,
      );

      expect(
        () => builder.build(
          session: session,
          currentFen: whiteToMoveFen,
          proofFen: whiteToMoveFen,
        ),
        throwsArgumentError,
      );
    });

    test('completed real curriculum reports curriculum end', () {
      final session = LessonSessionState(
        lesson: keySquaresLesson01,
        stage: LessonStage.completed,
        outcome: LessonSessionOutcome.draw,
      );

      final experience = builder.build(
        session: session,
        currentFen: whiteToMoveFen,
        proofFen: whiteToMoveFen,
        progression: LessonProgression(curriculum),
      );

      expect(experience.hasNextLesson, isFalse);
      expect(experience.nextLesson, isNull);
      expect(experience.isCurriculumEnd, isTrue);
    });

    test('completed session exposes next curriculum lesson when available', () {
      final first = testLesson('test-01');
      final second = testLesson('test-02');

      final session = LessonSessionState(
        lesson: first,
        stage: LessonStage.completed,
        outcome: LessonSessionOutcome.draw,
      );

      final experience = builder.build(
        session: session,
        currentFen: whiteToMoveFen,
        proofFen: whiteToMoveFen,
        progression: LessonProgression(<LessonDefinition>[first, second]),
      );

      expect(experience.hasNextLesson, isTrue);
      expect(experience.nextLesson, same(second));
      expect(experience.isCurriculumEnd, isFalse);
    });
  });
}
