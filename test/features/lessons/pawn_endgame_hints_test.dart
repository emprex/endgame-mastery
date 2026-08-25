import 'package:endgame_mastery/features/lessons/data/pawn_endgame_hints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pawn Endgame curriculum hints', () {
    test('first lesson exposes three progressive hints', () {
      expect(keySquaresLesson01Hints.concept, contains('key square'));
      expect(keySquaresLesson01Hints.visual, contains('c6, d6, and e6'));
      expect(keySquaresLesson01Hints.visual, contains('d5'));
      expect(keySquaresLesson01Hints.targeted, contains('Preserve the draw'));
    });

    test('second lesson hints use the corrected position', () {
      expect(keySquaresLesson02Hints.visual, contains('pawn on b5'));
      expect(keySquaresLesson02Hints.visual, contains('standing on b6'));
      expect(keySquaresLesson02Hints.visual, contains('a6, b6, c6, a7, b7, and c7'));
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
