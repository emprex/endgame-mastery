import 'package:endgame_mastery/core/engine/engine_position_analysis.dart';
import 'package:endgame_mastery/core/engine/uci/uci_info_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses centipawn evaluation and principal variation', () {
    final info = UciInfoParser.parse(
      'info depth 18 seldepth 27 score cp 43 nodes 1000 pv e2e4 e7e5 g1f3',
    );

    expect(info, isNotNull);
    expect(info!.depth, 18);
    expect(info.score.kind, EngineScoreKind.centipawn);
    expect(info.score.value, 43);
    expect(info.principalVariation, <String>['e2e4', 'e7e5', 'g1f3']);
  });

  test('parses signed mate evaluation', () {
    final info = UciInfoParser.parse(
      'info depth 22 score mate -3 nodes 5000 pv g7g8q',
    );

    expect(info, isNotNull);
    expect(info!.score.kind, EngineScoreKind.mate);
    expect(info.score.value, -3);
    expect(info.score.isMate, isTrue);
  });

  test('ignores non-info and info lines without scores', () {
    expect(UciInfoParser.parse('bestmove e2e4'), isNull);
    expect(UciInfoParser.parse('info depth 12 nodes 999'), isNull);
  });
}
