import 'package:endgame_mastery/features/lessons/session/lesson_hint_controller.dart';
import 'package:endgame_mastery/features/lessons/session/lesson_hint_overlay_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LessonHintOverlayPolicy', () {
    const policy = LessonHintOverlayPolicy();

    test('no hint does not reveal key squares', () {
      expect(policy.showKeySquares(LessonHintLevel.none), isFalse);
    });

    test('concept hint remains textual only', () {
      expect(policy.showKeySquares(LessonHintLevel.concept), isFalse);
    });

    test('visual hint reveals key squares', () {
      expect(policy.showKeySquares(LessonHintLevel.visual), isTrue);
    });

    test('targeted hint keeps key squares visible', () {
      expect(policy.showKeySquares(LessonHintLevel.targeted), isTrue);
    });
  });
}
