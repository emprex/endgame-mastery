import 'package:endgame_mastery/features/lessons/data/pawn_endgame_hints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pawn Endgame curriculum hints', () {
    test('first lesson exposes three progressive hints', () {
      expect(keySquaresLesson01Hints.concept, contains('six-square'));
      expect(keySquaresLesson01Hints.visual, contains('c6, d6, e6'));
      expect(keySquaresLesson01Hints.visual, contains('d7'));
      expect(keySquaresLesson01Hints.targeted, contains('Preserve the draw'));
    });

    test('second lesson hints use the corrected position', () {
      expect(keySquaresLesson02Hints.visual, contains('king b5'));
      expect(keySquaresLesson02Hints.visual, contains('pawn b6'));
      expect(keySquaresLesson02Hints.visual, contains('king b8'));
    });

    test('hints do not give a forced move', () {
      for (final hint in <String>[
        keySquaresLesson01Hints.concept,
        keySquaresLesson01Hints.visual,
        keySquaresLesson01Hints.targeted,
        keySquaresLesson02Hints.concept,
        keySquaresLesson02Hints.visual,
        keySquaresLesson02Hints.targeted,
      ]) {
        expect(hint, isNot(contains('Kc5!')));
        expect(hint, isNot(contains('Kb4!')));
      }
    });
  });
}
