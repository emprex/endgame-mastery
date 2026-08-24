import 'package:endgame_mastery/features/lessons/domain/lesson_hints.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_hint_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LessonHintController', () {
    final hints = LessonHints(
      concept: 'Concept hint',
      visual: 'Visual hint',
      targeted: 'Targeted hint',
    );

    test('starts with no revealed hint', () {
      final controller = LessonHintController(hints: hints);

      expect(controller.level, LessonHintLevel.none);
      expect(controller.currentHint, isNull);
      expect(controller.hasHint, isFalse);
      expect(controller.isFullyRevealed, isFalse);
    });

    test('reveals concept hint first', () {
      final controller = LessonHintController(hints: hints);

      controller.revealNext();

      expect(controller.level, LessonHintLevel.concept);
      expect(controller.currentHint, 'Concept hint');
      expect(controller.hasHint, isTrue);
      expect(controller.isFullyRevealed, isFalse);
    });

    test('reveals hints progressively in order', () {
      final controller = LessonHintController(hints: hints);

      controller.revealNext();

      expect(controller.level, LessonHintLevel.concept);
      expect(controller.currentHint, 'Concept hint');

      controller.revealNext();

      expect(controller.level, LessonHintLevel.visual);
      expect(controller.currentHint, 'Visual hint');

      controller.revealNext();

      expect(controller.level, LessonHintLevel.targeted);
      expect(controller.currentHint, 'Targeted hint');
      expect(controller.isFullyRevealed, isTrue);
    });

    test('does not advance beyond targeted hint', () {
      final controller = LessonHintController(hints: hints);

      controller.revealNext();
      controller.revealNext();
      controller.revealNext();
      controller.revealNext();

      expect(controller.level, LessonHintLevel.targeted);
      expect(controller.currentHint, 'Targeted hint');
      expect(controller.isFullyRevealed, isTrue);
    });

    test('reset hides all hints again', () {
      final controller = LessonHintController(hints: hints);

      controller.revealNext();
      controller.revealNext();

      expect(controller.level, LessonHintLevel.visual);

      controller.reset();

      expect(controller.level, LessonHintLevel.none);
      expect(controller.currentHint, isNull);
      expect(controller.hasHint, isFalse);
      expect(controller.isFullyRevealed, isFalse);
    });
  });
}
