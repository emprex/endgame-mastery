import 'package:endgame_mastery/features/lessons/data/pawn_endgame_hints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pawn Endgame curriculum hints', () {
    test('Key Squares lesson exposes three progressive hints', () {
      expect(keySquaresLesson01Hints.concept, contains('key square'));

      expect(keySquaresLesson01Hints.visual, contains('c6, d6, and e6'));

      expect(keySquaresLesson01Hints.targeted, contains('c6, d6, or e6'));
    });

    test('Key Squares hints do not claim d5 is a key square', () {
      expect(
        keySquaresLesson01Hints.visual,
        contains('has not reached one of them yet'),
      );
    });

    test('targeted hint preserves side-to-move dependency', () {
      expect(keySquaresLesson01Hints.targeted, contains('side to move'));
    });

    test('hints do not give a move to play', () {
      for (final hint in <String>[
        keySquaresLesson01Hints.concept,
        keySquaresLesson01Hints.visual,
        keySquaresLesson01Hints.targeted,
      ]) {
        expect(hint, isNot(contains('Kd6')));
        expect(hint, isNot(contains('Kc6')));
        expect(hint, isNot(contains('Ke6')));
      }
    });
  });
}
