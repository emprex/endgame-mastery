import 'dart:async';

import 'package:endgame_mastery/core/chess/chess_controller.dart';
import 'package:endgame_mastery/core/engine/chess_engine.dart';
import 'package:endgame_mastery/core/engine/engine_config.dart';
import 'package:endgame_mastery/core/engine/engine_move.dart';
import 'package:endgame_mastery/core/game/game_engine_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeChessEngine
    implements ChessEngine {
  bool initialized = false;
  bool stopped = false;
  bool disposed = false;

  final List<Completer<EngineMove>>
      pendingSearches = [];

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<EngineMove> bestMove({
    required String fen,
    required EngineConfig config,
  }) {
    final completer =
        Completer<EngineMove>();

    pendingSearches.add(
      completer,
    );

    return completer.future;
  }

  @override
  Future<void> stop() async {
    stopped = true;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void main() {
  test(
    'controller initializes engine',
    () async {
      final engine =
          FakeChessEngine();

      final game =
          GameEngineController(
        chessController:
            ChessController(),
        engine: engine,
      );

      await game.initialize();

      expect(
        engine.initialized,
        isTrue,
      );
    },
  );

  test(
    'user move is applied before engine search',
    () async {
      final engine =
          FakeChessEngine();

      final chessController =
          ChessController();

      final game =
          GameEngineController(
        chessController:
            chessController,
        engine: engine,
      );

      await game.initialize();

      final moved =
          game.playUserMove(
        from: 'd5',
        to: 'c5',
      );

      expect(
        moved,
        isTrue,
      );

      expect(
        chessController
            .pieceVisualAt('c5'),
        isNotNull,
      );

      expect(
        chessController
            .pieceVisualAt('d5'),
        isNull,
      );

      expect(
        game.isEngineTurn,
        isTrue,
      );

      expect(
        game.engineBusy,
        isFalse,
      );

      expect(
        engine.pendingSearches,
        isEmpty,
      );
    },
  );

  test(
    'explicit engine request applies black move',
    () async {
      final engine =
          FakeChessEngine();

      final chessController =
          ChessController();

      final game =
          GameEngineController(
        chessController:
            chessController,
        engine: engine,
      );

      await game.initialize();

      expect(
        game.playUserMove(
          from: 'd5',
          to: 'c5',
        ),
        isTrue,
      );

      final future =
          game.requestEngineMove();

      await Future<void>.delayed(
        Duration.zero,
      );

      expect(
        game.engineBusy,
        isTrue,
      );

      expect(
        engine.pendingSearches.length,
        1,
      );

      engine.pendingSearches.single
          .complete(
        const EngineMove(
          from: 'd7',
          to: 'c7',
        ),
      );

      expect(
        await future,
        isTrue,
      );

      expect(
        chessController
            .pieceVisualAt('c7'),
        isNotNull,
      );

      expect(
        chessController
            .pieceVisualAt('d7'),
        isNull,
      );

      expect(
        chessController.isWhiteToMove(),
        isTrue,
      );

      expect(
        game.engineBusy,
        isFalse,
      );
    },
  );

  test(
    'reset rejects stale engine response',
    () async {
      final engine =
          FakeChessEngine();

      final chessController =
          ChessController();

      final game =
          GameEngineController(
        chessController:
            chessController,
        engine: engine,
      );

      await game.initialize();

      expect(
        game.playUserMove(
          from: 'd5',
          to: 'c5',
        ),
        isTrue,
      );

      final future =
          game.requestEngineMove();

      await Future<void>.delayed(
        Duration.zero,
      );

      await game.reset();

      engine.pendingSearches.single
          .complete(
        const EngineMove(
          from: 'd7',
          to: 'c7',
        ),
      );

      expect(
        await future,
        isFalse,
      );

      expect(
        chessController
            .pieceVisualAt('d5'),
        isNotNull,
      );

      expect(
        chessController
            .pieceVisualAt('d7'),
        isNotNull,
      );

      expect(
        chessController
            .pieceVisualAt('c7'),
        isNull,
      );
    },
  );

  test(
    'user cannot move during active engine search',
    () async {
      final engine =
          FakeChessEngine();

      final chessController =
          ChessController();

      final game =
          GameEngineController(
        chessController:
            chessController,
        engine: engine,
      );

      await game.initialize();

      expect(
        game.playUserMove(
          from: 'd5',
          to: 'c5',
        ),
        isTrue,
      );

      final engineFuture =
          game.requestEngineMove();

      await Future<void>.delayed(
        Duration.zero,
      );

      expect(
        game.engineBusy,
        isTrue,
      );

      final illegalUserTurn =
          game.playUserMove(
        from: 'd4',
        to: 'd5',
      );

      expect(
        illegalUserTurn,
        isFalse,
      );

      engine.pendingSearches.single
          .complete(
        const EngineMove(
          from: 'd7',
          to: 'c7',
        ),
      );

      await engineFuture;

      expect(
        game.engineBusy,
        isFalse,
      );
    },
  );

  test(
    'dispose rejects stale engine response',
    () async {
      final engine =
          FakeChessEngine();

      final chessController =
          ChessController();

      final game =
          GameEngineController(
        chessController:
            chessController,
        engine: engine,
      );

      await game.initialize();

      expect(
        game.playUserMove(
          from: 'd5',
          to: 'c5',
        ),
        isTrue,
      );

      final future =
          game.requestEngineMove();

      await Future<void>.delayed(
        Duration.zero,
      );

      await game.dispose();

      engine.pendingSearches.single
          .complete(
        const EngineMove(
          from: 'd7',
          to: 'c7',
        ),
      );

      expect(
        await future,
        isFalse,
      );

      expect(
        engine.disposed,
        isTrue,
      );

      expect(
        chessController
            .pieceVisualAt('c7'),
        isNull,
      );
    },
  );
}
