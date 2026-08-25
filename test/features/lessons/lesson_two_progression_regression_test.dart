import 'package:endgame_mastery/features/lessons/data/curriculum.dart';
import 'package:endgame_mastery/features/lessons/data/pawn_endgame_lessons.dart';
import 'package:endgame_mastery/features/lessons/presentation/lesson_experience_presenter.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_experience_builder.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_progression.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_controller.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_outcome.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_session_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Lesson 2 progression regression', () {
    test('completed Lesson 2 exposes Lesson 3 as the next lesson', () {
      final progression = LessonProgression(curriculum);
      final controller = LessonSessionController(
        initialState: LessonSessionState.initial(keySquaresLesson02),
      );

      controller.startPractice();
      controller.startProve();
      controller.completeProof(LessonSessionOutcome.draw);
      controller.completeLesson();

      final next = progression.nextLessonFor(controller.state);
      expect(next, isNotNull);
      expect(next!.id, keySquaresLesson03.id);
    });

    test('completed Lesson 2 presenter exposes a Next Lesson action', () {
      final progression = LessonProgression(curriculum);
      final controller = LessonSessionController(
        initialState: LessonSessionState.initial(keySquaresLesson02),
      );

      controller.startPractice();
      controller.startProve();
      controller.completeProof(LessonSessionOutcome.draw);
      controller.completeLesson();

      const builder = LessonExperienceBuilder();
      const presenter = LessonExperiencePresenter();

      final experience = builder.build(
        session: controller.state,
        currentFen: keySquaresLesson02.fen,
        proofFen: keySquaresLesson02.fen,
        progression: progression,
      );
      final presentation = presenter.present(experience);

      expect(presentation.nextAvailable, isTrue);
      expect(presentation.primaryActionLabel, 'Next Lesson');
    });
  });
}
