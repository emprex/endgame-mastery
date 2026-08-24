import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_controller.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_state.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_stage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LessonSessionController createController() {
    return LessonSessionController(
      initialState: LessonSessionState.initial(keySquaresLesson01),
    );
  }

  group('LessonSessionState', () {
    test('initial session starts in Learn', () {
      final state = LessonSessionState.initial(keySquaresLesson01);

      expect(state.lesson, same(keySquaresLesson01));
      expect(state.stage, LessonStage.learn);
    });

    test('copyWith preserves the lesson', () {
      final initial = LessonSessionState.initial(keySquaresLesson01);

      final updated = initial.copyWith(stage: LessonStage.practice);

      expect(updated.lesson, same(keySquaresLesson01));
      expect(updated.stage, LessonStage.practice);
      expect(initial.stage, LessonStage.learn);
    });
  });

  group('LessonSessionController legal transitions', () {
    test('Learn -> Practice', () {
      final controller = createController();

      controller.startPractice();

      expect(controller.state.stage, LessonStage.practice);
    });

    test('Practice -> Prove', () {
      final controller = createController();

      controller.startPractice();
      controller.startProve();

      expect(controller.state.stage, LessonStage.prove);
    });

    test('Prove does not automatically become Result', () {
      final controller = createController();

      controller.startPractice();
      controller.startProve();

      expect(controller.state.stage, LessonStage.prove);
    });

    test('Prove -> Result only through explicit proof completion', () {
      final controller = createController();

      controller.startPractice();
      controller.startProve();
      controller.completeProof();

      expect(controller.state.stage, LessonStage.result);
    });

    test('Result -> Completed', () {
      final controller = createController();

      controller.startPractice();
      controller.startProve();
      controller.completeProof();
      controller.completeLesson();

      expect(controller.state.stage, LessonStage.completed);
    });

    test('full lifecycle follows Learn Practice Prove Result Completed', () {
      final controller = createController();

      expect(controller.state.stage, LessonStage.learn);

      controller.startPractice();
      expect(controller.state.stage, LessonStage.practice);

      controller.startProve();
      expect(controller.state.stage, LessonStage.prove);

      controller.completeProof();
      expect(controller.state.stage, LessonStage.result);

      controller.completeLesson();
      expect(controller.state.stage, LessonStage.completed);
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

      expect(controller.completeProof, throwsStateError);

      expect(controller.state.stage, LessonStage.learn);
    });

    test('cannot complete lesson from Learn', () {
      final controller = createController();

      expect(controller.completeLesson, throwsStateError);
    });

    test('cannot start Practice twice', () {
      final controller = createController();

      controller.startPractice();

      expect(controller.startPractice, throwsStateError);

      expect(controller.state.stage, LessonStage.practice);
    });

    test('cannot complete proof from Practice', () {
      final controller = createController();

      controller.startPractice();

      expect(controller.completeProof, throwsStateError);

      expect(controller.state.stage, LessonStage.practice);
    });

    test('cannot start Practice from Prove', () {
      final controller = createController();

      controller.startPractice();
      controller.startProve();

      expect(controller.startPractice, throwsStateError);

      expect(controller.state.stage, LessonStage.prove);
    });

    test('cannot complete lesson directly from Prove', () {
      final controller = createController();

      controller.startPractice();
      controller.startProve();

      expect(controller.completeLesson, throwsStateError);

      expect(controller.state.stage, LessonStage.prove);
    });

    test('cannot return to Practice from Result', () {
      final controller = createController();

      controller.startPractice();
      controller.startProve();
      controller.completeProof();

      expect(controller.startPractice, throwsStateError);

      expect(controller.state.stage, LessonStage.result);
    });

    test('completed session rejects every transition', () {
      final controller = createController();

      controller.startPractice();
      controller.startProve();
      controller.completeProof();
      controller.completeLesson();

      expect(controller.startPractice, throwsStateError);
      expect(controller.startProve, throwsStateError);
      expect(controller.completeProof, throwsStateError);
      expect(controller.completeLesson, throwsStateError);

      expect(controller.state.stage, LessonStage.completed);
    });
  });
}
