import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_controller.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_outcome.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_state.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_stage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LessonSessionController createController() {
    return LessonSessionController(
      initialState: LessonSessionState.initial(keySquaresLesson01),
    );
  }

  LessonSessionController createProveController() {
    final controller = createController();

    controller.startPractice();
    controller.startProve();

    return controller;
  }

  group('LessonSessionState', () {
    test('initial session starts in Learn without an outcome', () {
      final state = LessonSessionState.initial(keySquaresLesson01);

      expect(state.lesson, same(keySquaresLesson01));
      expect(state.stage, LessonStage.learn);
      expect(state.outcome, isNull);
    });

    test('copyWith preserves the lesson', () {
      final initial = LessonSessionState.initial(keySquaresLesson01);

      final updated = initial.copyWith(stage: LessonStage.practice);

      expect(updated.lesson, same(keySquaresLesson01));
      expect(updated.stage, LessonStage.practice);
      expect(updated.outcome, isNull);
      expect(initial.stage, LessonStage.learn);
    });

    test('rejects Result without an outcome', () {
      expect(
        () => LessonSessionState(
          lesson: keySquaresLesson01,
          stage: LessonStage.result,
        ),
        throwsArgumentError,
      );
    });

    test('rejects Completed without an outcome', () {
      expect(
        () => LessonSessionState(
          lesson: keySquaresLesson01,
          stage: LessonStage.completed,
        ),
        throwsArgumentError,
      );
    });

    test('rejects an outcome before Result', () {
      for (final stage in <LessonStage>[
        LessonStage.learn,
        LessonStage.practice,
        LessonStage.prove,
      ]) {
        expect(
          () => LessonSessionState(
            lesson: keySquaresLesson01,
            stage: stage,
            outcome: LessonSessionOutcome.draw,
          ),
          throwsArgumentError,
        );
      }
    });

    test('accepts Result with an outcome', () {
      final state = LessonSessionState(
        lesson: keySquaresLesson01,
        stage: LessonStage.result,
        outcome: LessonSessionOutcome.draw,
      );

      expect(state.stage, LessonStage.result);
      expect(state.outcome, LessonSessionOutcome.draw);
    });
  });

  group('LessonSessionController legal transitions', () {
    test('Learn -> Practice', () {
      final controller = createController();

      controller.startPractice();

      expect(controller.state.stage, LessonStage.practice);
      expect(controller.state.outcome, isNull);
    });

    test('Practice -> Prove', () {
      final controller = createController();

      controller.startPractice();
      controller.startProve();

      expect(controller.state.stage, LessonStage.prove);
      expect(controller.state.outcome, isNull);
    });

    test('Prove does not automatically become Result', () {
      final controller = createProveController();

      expect(controller.state.stage, LessonStage.prove);
      expect(controller.state.outcome, isNull);
    });

    test('Prove -> Result stores explicit win outcome', () {
      final controller = createProveController();

      controller.completeProof(LessonSessionOutcome.win);

      expect(controller.state.stage, LessonStage.result);
      expect(controller.state.outcome, LessonSessionOutcome.win);
    });

    test('Prove -> Result stores explicit draw outcome', () {
      final controller = createProveController();

      controller.completeProof(LessonSessionOutcome.draw);

      expect(controller.state.stage, LessonStage.result);
      expect(controller.state.outcome, LessonSessionOutcome.draw);
    });

    test('Prove -> Result stores explicit loss outcome', () {
      final controller = createProveController();

      controller.completeProof(LessonSessionOutcome.loss);

      expect(controller.state.stage, LessonStage.result);
      expect(controller.state.outcome, LessonSessionOutcome.loss);
    });

    test('Result -> Completed preserves the proof outcome', () {
      final controller = createProveController();

      controller.completeProof(LessonSessionOutcome.draw);
      controller.completeLesson();

      expect(controller.state.stage, LessonStage.completed);
      expect(controller.state.outcome, LessonSessionOutcome.draw);
    });

    test('full lifecycle preserves explicit session outcome', () {
      final controller = createController();

      expect(controller.state.stage, LessonStage.learn);
      expect(controller.state.outcome, isNull);

      controller.startPractice();
      expect(controller.state.stage, LessonStage.practice);

      controller.startProve();
      expect(controller.state.stage, LessonStage.prove);

      controller.completeProof(LessonSessionOutcome.win);
      expect(controller.state.stage, LessonStage.result);
      expect(controller.state.outcome, LessonSessionOutcome.win);

      controller.completeLesson();
      expect(controller.state.stage, LessonStage.completed);
      expect(controller.state.outcome, LessonSessionOutcome.win);
    });
  });

  group('LessonSessionController illegal transitions', () {
    test('cannot start Prove from Learn', () {
      final controller = createController();

      expect(controller.startProve, throwsStateError);

      expect(controller.state.stage, LessonStage.learn);
    });

    test('cannot complete proof from Learn', () {
      final controller = createController();

      expect(
        () => controller.completeProof(LessonSessionOutcome.draw),
        throwsStateError,
      );

      expect(controller.state.stage, LessonStage.learn);
      expect(controller.state.outcome, isNull);
    });

    test('cannot complete proof from Practice', () {
      final controller = createController();

      controller.startPractice();

      expect(
        () => controller.completeProof(LessonSessionOutcome.draw),
        throwsStateError,
      );

      expect(controller.state.stage, LessonStage.practice);
      expect(controller.state.outcome, isNull);
    });

    test('cannot start Practice twice', () {
      final controller = createController();

      controller.startPractice();

      expect(controller.startPractice, throwsStateError);

      expect(controller.state.stage, LessonStage.practice);
    });

    test('cannot start Practice from Prove', () {
      final controller = createProveController();

      expect(controller.startPractice, throwsStateError);

      expect(controller.state.stage, LessonStage.prove);
    });

    test('cannot complete lesson directly from Prove', () {
      final controller = createProveController();

      expect(controller.completeLesson, throwsStateError);

      expect(controller.state.stage, LessonStage.prove);
    });

    test('cannot complete proof twice', () {
      final controller = createProveController();

      controller.completeProof(LessonSessionOutcome.draw);

      expect(
        () => controller.completeProof(LessonSessionOutcome.win),
        throwsStateError,
      );

      expect(controller.state.stage, LessonStage.result);
      expect(controller.state.outcome, LessonSessionOutcome.draw);
    });

    test('cannot return to Practice from Result', () {
      final controller = createProveController();

      controller.completeProof(LessonSessionOutcome.draw);

      expect(controller.startPractice, throwsStateError);

      expect(controller.state.stage, LessonStage.result);
    });

    test('completed session rejects every transition', () {
      final controller = createProveController();

      controller.completeProof(LessonSessionOutcome.draw);
      controller.completeLesson();

      expect(controller.startPractice, throwsStateError);
      expect(controller.startProve, throwsStateError);
      expect(
        () => controller.completeProof(LessonSessionOutcome.win),
        throwsStateError,
      );
      expect(controller.completeLesson, throwsStateError);

      expect(controller.state.stage, LessonStage.completed);
      expect(controller.state.outcome, LessonSessionOutcome.draw);
    });
  });
}
