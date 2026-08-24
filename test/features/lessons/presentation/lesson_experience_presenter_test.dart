import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/domain/lesson_definition.dart';
import 'package:endgame_mastery/features/lessons/overlay/pedagogical_overlay.dart';
import 'package:endgame_mastery/features/lessons/presentation/lesson_experience_presenter.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_experience_state.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_proof_evaluation.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_outcome.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_state.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_stage.dart';
import 'package:endgame_mastery/features/lessons/teaching/teaching_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const presenter = LessonExperiencePresenter();

  TeachingState teachingState() {
    return TeachingState(
      fen: keySquaresLesson01.fen,
      sideToMove: keySquaresLesson01.sideToMove,
      theoreticalResult: keySquaresLesson01.theoreticalResult,
      overlay: PedagogicalOverlay(),
      teachingPoint: null,
    );
  }

  LessonExperienceState experienceFor(
    LessonStage stage, {
    LessonProofEvaluation? proofEvaluation,
    LessonDefinition? nextLesson,
  }) {
    final outcome =
        stage == LessonStage.result || stage == LessonStage.completed
        ? LessonSessionOutcome.draw
        : null;

    return LessonExperienceState(
      session: LessonSessionState(
        lesson: keySquaresLesson01,
        stage: stage,
        outcome: outcome,
      ),
      teaching: teachingState(),
      proofEvaluation: proofEvaluation,
      nextLesson: nextLesson,
    );
  }

  LessonProofEvaluation proofEvaluation(LessonProofVerdict verdict) {
    return LessonProofEvaluation(
      proofFen: keySquaresLesson01.fen,
      actualOutcome: LessonSessionOutcome.draw,
      expectedResult: verdict == LessonProofVerdict.unsupported
          ? null
          : TheoreticalResult.draw,
      verdict: verdict,
    );
  }

  LessonDefinition nextLessonFixture() {
    return LessonDefinition(
      id: 'test-next-lesson',
      title: 'Next Test Lesson',
      fen: '8/3k4/8/3K4/3P4/8/8/8 w - - 0 1',
      concept: LessonConcept.keySquares,
      objective: 'Test fixture only.',
      learnText: 'Test fixture only.',
      userSide: ChessSide.white,
      initialKeySquares: const <String>{'c6', 'd6', 'e6'},
      theoreticalResult: TheoreticalResult.draw,
      difficulty: 1,
    );
  }

  group('LessonExperiencePresenter', () {
    test('presents LEARN without board interaction', () {
      final presentation = presenter.present(experienceFor(LessonStage.learn));

      expect(presentation.stageLabel, 'LEARN');
      expect(presentation.stageTitle, 'Understand the concept');

      expect(presentation.primaryAction, LessonPrimaryAction.startPractice);

      expect(presentation.primaryActionLabel, 'Start Practice');

      expect(presentation.boardInteractionEnabled, isFalse);

      expect(presentation.showLearnContent, isTrue);
      expect(presentation.learnText, keySquaresLesson01.learnText);

      expect(presentation.hasProofResult, isFalse);
      expect(presentation.nextAvailable, isFalse);
      expect(presentation.curriculumEnd, isFalse);
    });

    test('presents PRACTICE with board interaction', () {
      final presentation = presenter.present(
        experienceFor(LessonStage.practice),
      );

      expect(presentation.stageLabel, 'PRACTICE');

      expect(presentation.primaryAction, LessonPrimaryAction.startProve);

      expect(presentation.primaryActionLabel, 'Start Prove');

      expect(presentation.boardInteractionEnabled, isTrue);
      expect(presentation.showLearnContent, isFalse);
      expect(presentation.learnText, isNull);
    });

    test('PROVE enables board but has no manual finish action', () {
      final presentation = presenter.present(experienceFor(LessonStage.prove));

      expect(presentation.stageLabel, 'PROVE');
      expect(presentation.stageTitle, 'Prove it');

      expect(presentation.boardInteractionEnabled, isTrue);

      expect(presentation.primaryAction, isNull);
      expect(presentation.primaryActionLabel, isNull);
    });

    test('RESULT presents a passed proof verdict', () {
      final presentation = presenter.present(
        experienceFor(
          LessonStage.result,
          proofEvaluation: proofEvaluation(LessonProofVerdict.passed),
        ),
      );

      expect(presentation.stageLabel, 'RESULT');
      expect(presentation.boardInteractionEnabled, isFalse);

      expect(presentation.hasProofResult, isTrue);
      expect(presentation.proofTitle, 'Passed');

      expect(
        presentation.proofMessage,
        'Your result matches the verified theoretical result.',
      );

      expect(presentation.primaryAction, LessonPrimaryAction.completeLesson);
    });

    test('RESULT preserves unsupported proof truth', () {
      final presentation = presenter.present(
        experienceFor(
          LessonStage.result,
          proofEvaluation: proofEvaluation(LessonProofVerdict.unsupported),
        ),
      );

      expect(presentation.hasProofResult, isTrue);
      expect(presentation.proofTitle, 'Unsupported');

      expect(
        presentation.proofMessage,
        'This proof position is not covered by verified curriculum theory.',
      );
    });

    test('completed curriculum exposes no fake Next action', () {
      final presentation = presenter.present(
        experienceFor(
          LessonStage.completed,
          proofEvaluation: proofEvaluation(LessonProofVerdict.passed),
        ),
      );

      expect(presentation.stageLabel, 'NEXT');
      expect(presentation.stageTitle, 'Lesson complete');

      expect(presentation.curriculumEnd, isTrue);
      expect(presentation.nextAvailable, isFalse);

      expect(presentation.primaryAction, isNull);
      expect(presentation.primaryActionLabel, isNull);

      expect(presentation.boardInteractionEnabled, isFalse);
    });

    test('completed session exposes Next only when a lesson exists', () {
      final presentation = presenter.present(
        experienceFor(
          LessonStage.completed,
          proofEvaluation: proofEvaluation(LessonProofVerdict.passed),
          nextLesson: nextLessonFixture(),
        ),
      );

      expect(presentation.curriculumEnd, isFalse);
      expect(presentation.nextAvailable, isTrue);

      expect(presentation.primaryAction, LessonPrimaryAction.nextLesson);

      expect(presentation.primaryActionLabel, 'Next Lesson');
    });
  });
}
