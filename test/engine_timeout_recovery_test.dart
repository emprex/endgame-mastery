import 'dart:async';

import 'package:endgame_mastery/core/chess/chess_controller.dart';
import 'package:endgame_mastery/core/engine/chess_engine.dart';
import 'package:endgame_mastery/core/engine/engine_config.dart';
import 'package:endgame_mastery/core/engine/engine_exception.dart';
import 'package:endgame_mastery/core/engine/engine_move.dart';
import 'package:endgame_mastery/core/game/game_engine_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class RecoveryFakeEngine
    implements ChessEngine {
  final List<Completer<EngineMove>>
      searches = <Completer<EngineMove>>[];

  int stopCount = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<EngineMove> bestMove({
    required String fen,
    required EngineConfig config,
  }) {
    final completer =
        Completer<EngineMove>();

    searches.add(completer);

    return completer.future;
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  test(
    'engine can recover after a timed out search',
    () async {
      final engine =
          RecoveryFakeEngine();

      final chessController =
          ChessController();

      final game =
          GameEngineController(
        chessController:
            chessController,
        engine: engine,
        searchTimeout:
            const Duration(
          milliseconds: 20,
        ),
      );

      await game.initialize();

      // ------------------------------------------------------------
      // FIRST SEARCH: TIMEOUT
      // ------------------------------------------------------------

      expect(
        game.playUserMove(
          from: 'd5',
          to: 'c5',
        ),
        isTrue,
      );

      await expectLater(
        game.requestEngineMove(),
        throwsA(
          isA<
              EngineTimeoutException>(),
        ),
      );

      expect(
        game.engineBusy,
        isFalse,
      );

      expect(
        engine.stopCount,
        greaterThanOrEqualTo(1),
      );

      // ------------------------------------------------------------
      // RESET TO A CLEAN POSITION
      // ------------------------------------------------------------

      await game.reset();

      expect(
        chessController
            .pieceVisualAt('d5'),
        isNotNull,
      );

      // ------------------------------------------------------------
      // SECOND SEARCH: SUCCESS
      // ------------------------------------------------------------

      expect(
        game.playUserMove(
          from: 'd5',
          to: 'c5',
        ),
        isTrue,
      );

      final recoverySearch =
          game.requestEngineMove();

      await Future<void>.delayed(
        Duration.zero,
      );

      expect(
        engine.searches.length,
        2,
      );

      engine.searches[1].complete(
        const EngineMove(
          from: 'd7',
          to: 'c7',
        ),
      );

      expect(
        await recoverySearch,
        isTrue,
      );

      expect(
        chessController
            .pieceVisualAt('c7'),
        isNotNull,
      );

      expect(
        game.engineBusy,
        isFalse,
      );
    },
  );
}
