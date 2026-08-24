import 'package:endgame_mastery/features/lessons/rules/fen_pawn_locator.dart';
import 'package:endgame_mastery/features/lessons/rules/key_squares_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KeySquaresRule', () {
    const rule = KeySquaresRule();

    test('d4 produces c6 d6 e6', () {
      expect(rule.forWhitePawn('d4'), <String>{'c6', 'd6', 'e6'});
    });

    test('e3 produces d5 e5 f5', () {
      expect(rule.forWhitePawn('e3'), <String>{'d5', 'e5', 'f5'});
    });

    test('rook pawn is intentionally unsupported', () {
      expect(rule.forWhitePawn('a4'), isEmpty);

      expect(rule.forWhitePawn('h4'), isEmpty);
    });

    test('unsupported later pawn rank returns no invented result', () {
      expect(rule.forWhitePawn('d5'), isEmpty);
    });

    test('invalid square returns empty result', () {
      expect(rule.forWhitePawn('z9'), isEmpty);
    });
  });

  group('FenPawnLocator', () {
    const locator = FenPawnLocator();

    test('finds white pawn on d4', () {
      expect(locator.whitePawns('8/3k4/8/3K4/3P4/8/8/8 w - - 0 1'), <String>[
        'd4',
      ]);
    });

    test('finds white pawn on d5', () {
      expect(locator.whitePawns('8/3k4/8/2KP4/8/8/8/8 b - - 0 1'), <String>[
        'd5',
      ]);
    });
  });
}
