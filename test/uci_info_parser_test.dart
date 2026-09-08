import 'package:endgame_mastery/core/engine/uci/uci_info_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses depth centipawn score and principal variation', () {
    final info = UciInfoParser.parse(
      'info depth 18 seldepth 25 score cp 34 nodes 12345 pv e2e4 e7e5 g1f3',
    );

    expect(info, isNotNull);
    expect(info!.depth, 18);
    expect(info.scoreCp, 34);
    expect(info.mateIn, isNull);
    expect(info.principalVariation, ['e2e4', 'e7e5', 'g1f3']);
  });

  test('parses mate scores without inventing a centipawn value', () {
    final info = UciInfoParser.parse(
      'info depth 22 score mate -3 nodes 9000 pv g8h8 f7f8q',
    );

    expect(info, isNotNull);
    expect(info!.depth, 22);
    expect(info.scoreCp, isNull);
    expect(info.mateIn, -3);
    expect(info.principalVariation, ['g8h8', 'f7f8q']);
  });

  test('ignores non-info UCI output', () {
    expect(UciInfoParser.parse('bestmove e2e4'), isNull);
  });
}
