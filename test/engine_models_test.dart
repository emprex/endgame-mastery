import 'package:endgame_mastery/core/engine/engine_config.dart';
import 'package:endgame_mastery/core/engine/engine_move.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'EngineMove',
    () {
      test(
        'creates normal UCI move',
        () {
          const move = EngineMove(
            from: 'd7',
            to: 'c6',
          );

          expect(
            move.uci,
            'd7c6',
          );
        },
      );

      test(
        'creates promotion UCI move',
        () {
          const move = EngineMove(
            from: 'e2',
            to: 'e1',
            promotion: 'q',
          );

          expect(
            move.uci,
            'e2e1q',
          );
        },
      );

      test(
        'supports value equality',
        () {
          const first = EngineMove(
            from: 'd7',
            to: 'c6',
          );

          const second = EngineMove(
            from: 'd7',
            to: 'c6',
          );

          expect(
            first,
            second,
          );
        },
      );
    },
  );

  group(
    'EngineConfig',
    () {
      test(
        'defaults to 250ms move time',
        () {
          const config =
              EngineConfig();

          expect(
            config.moveTime,
            const Duration(
              milliseconds: 250,
            ),
          );

          expect(
            config.depth,
            isNull,
          );
        },
      );

      test(
        'allows optional depth',
        () {
          const config =
              EngineConfig(
            moveTime: Duration(
              milliseconds: 200,
            ),
            depth: 8,
          );

          expect(
            config.depth,
            8,
          );
        },
      );
    },
  );
}
