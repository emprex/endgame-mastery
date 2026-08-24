import 'package:endgame_mastery/core/engine/engine_config.dart';
import 'package:endgame_mastery/core/engine/engine_move.dart';
import 'package:endgame_mastery/core/engine/uci/uci_best_move_parser.dart';
import 'package:endgame_mastery/core/engine/uci/uci_command_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'UciCommandBuilder',
    () {
      test(
        'builds position command from FEN',
        () {
          const fen =
              '8/3k4/8/3K4/3P4/8/8/8 w - - 0 1';

          expect(
            UciCommandBuilder
                .positionFromFen(
              fen,
            ),
            'position fen $fen',
          );
        },
      );

      test(
        'builds responsive movetime command',
        () {
          const config =
              EngineConfig(
            moveTime: Duration(
              milliseconds: 250,
            ),
          );

          expect(
            UciCommandBuilder.go(
              config,
            ),
            'go movetime 250',
          );
        },
      );

      test(
        'includes optional depth',
        () {
          const config =
              EngineConfig(
            moveTime: Duration(
              milliseconds: 200,
            ),
            depth: 8,
          );

          expect(
            UciCommandBuilder.go(
              config,
            ),
            'go movetime 200 depth 8',
          );
        },
      );
    },
  );

  group(
    'UciBestMoveParser',
    () {
      test(
        'parses normal bestmove',
        () {
          final move =
              UciBestMoveParser.parse(
            'bestmove d7c7',
          );

          expect(
            move,
            const EngineMove(
              from: 'd7',
              to: 'c7',
            ),
          );
        },
      );

      test(
        'parses promotion bestmove',
        () {
          final move =
              UciBestMoveParser.parse(
            'bestmove e2e1q',
          );

          expect(
            move,
            const EngineMove(
              from: 'e2',
              to: 'e1',
              promotion: 'q',
            ),
          );
        },
      );

      test(
        'ignores ponder suffix',
        () {
          final move =
              UciBestMoveParser.parse(
            'bestmove d7c7 ponder e1e2',
          );

          expect(
            move,
            const EngineMove(
              from: 'd7',
              to: 'c7',
            ),
          );
        },
      );

      test(
        'returns null for no legal move',
        () {
          expect(
            UciBestMoveParser.parse(
              'bestmove (none)',
            ),
            isNull,
          );

          expect(
            UciBestMoveParser.parse(
              'bestmove 0000',
            ),
            isNull,
          );
        },
      );

      test(
        'rejects invalid UCI move',
        () {
          expect(
            UciBestMoveParser.parse(
              'bestmove z9z1',
            ),
            isNull,
          );

          expect(
            UciBestMoveParser.parse(
              'bestmove e2e1x',
            ),
            isNull,
          );
        },
      );

      test(
        'ignores non-bestmove engine output',
        () {
          expect(
            UciBestMoveParser.parse(
              'info depth 8 score cp 23',
            ),
            isNull,
          );
        },
      );
    },
  );
}
