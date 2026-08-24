import 'package:endgame_mastery/features/lessons/domain/lesson_hints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LessonHints', () {
    test('preserves three progressive hint levels', () {
      final hints = LessonHints(
        concept: 'Use the key-square rule.',
        visual: 'Focus on the squares in front of the pawn.',
        targeted: 'Find a route for the king toward a key square.',
      );

      expect(hints.concept, 'Use the key-square rule.');

      expect(hints.visual, 'Focus on the squares in front of the pawn.');

      expect(hints.targeted, 'Find a route for the king toward a key square.');
    });

    test('trims hint text', () {
      final hints = LessonHints(
        concept: '  Concept hint  ',
        visual: '  Visual hint  ',
        targeted: '  Targeted hint  ',
      );

      expect(hints.concept, 'Concept hint');
      expect(hints.visual, 'Visual hint');
      expect(hints.targeted, 'Targeted hint');
    });

    test('rejects empty concept hint', () {
      expect(
        () => LessonHints(
          concept: '   ',
          visual: 'Visual hint',
          targeted: 'Targeted hint',
        ),
        throwsArgumentError,
      );
    });

    test('rejects empty visual hint', () {
      expect(
        () => LessonHints(
          concept: 'Concept hint',
          visual: '   ',
          targeted: 'Targeted hint',
        ),
        throwsArgumentError,
      );
    });

    test('rejects empty targeted hint', () {
      expect(
        () => LessonHints(
          concept: 'Concept hint',
          visual: 'Visual hint',
          targeted: '   ',
        ),
        throwsArgumentError,
      );
    });
  });
}
