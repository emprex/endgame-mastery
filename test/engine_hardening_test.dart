import 'dart:async';

import 'package:endgame_mastery/core/chess/chess_controller.dart';
import 'package:endgame_mastery/core/engine/chess_engine.dart';
import 'package:endgame_mastery/core/engine/engine_config.dart';
import 'package:endgame_mastery/core/engine/engine_exception.dart';
import 'package:endgame_mastery/core/engine/engine_move.dart';
import 'package:endgame_mastery/core/game/game_engine_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// Controllable fake engine used to test asynchronous failure cases.
///
/// Unlike LegalMoveTestEngine, this fake does not automatically
/// produce a move. Each test decides exactly when the engine answers.
class HardeningFakeEngine
    implements ChessEngine {
  bool initialized = false;
  bool disposed = false;

  int stopCount = 0;

  final List<Completer<EngineMove>>
      searches = <Completer<EngineMove>>[];

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

    searches.add(
      completer,
    );

    return completer.future;
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void main() {
  // ---------------------------------------------------------------------------
  // TIMEOUT
  // ---------------------------------------------------------------------------

  test(
    'engine timeout clears busy state and requests stop',
    () async {
      final engine =
          HardeningFakeEngine();

      final chessController =
          ChessController();

      final game =
          GameEngineController(
        chessController:
            chessController,
        engine: engine,

        // Deliberately tiny timeout so the test remains fast.
        searchTimeout:
            const Duration(
          milliseconds: 20,
        ),
      );

      await game.initialize();

      expect(
        game.playUserMove(
          from: 'd5',
          to: 'c5',
        ),
        isTrue,
      );

      expect(
        game.isEngineTurn,
        isTrue,
      );

      await expectLater(
        game.requestEngineMove(),
        throwsA(
          isA<
              EngineTimeoutException>(),
        ),
      );

      // A timeout must NEVER leave the app permanently
      // stuck in its "engine thinking" state.
      expect(
        game.engineBusy,
        isFalse,
      );

      // The orchestration layer must tell the underlying
      // engine to stop its old calculation.
      expect(
        engine.stopCount,
        greaterThanOrEqualTo(1),
      );

      // No stale engine move was applied.
      expect(
        chessController
            .pieceVisualAt('d7'),
        isNotNull,
      );
    },
  );

  // ---------------------------------------------------------------------------
  // SUCCESSIVE ENGINE SEARCHES
  // ---------------------------------------------------------------------------

  test(
    'multiple engine searches can run successively',
    () async {
      final engine =
          HardeningFakeEngine();

      final chessController =
          ChessController();

      final game =
          GameEngineController(
        chessController:
            chessController,
        engine: engine,
      );

      await game.initialize();

      // White first move.
      expect(
        game.playUserMove(
          from: 'd5',
          to: 'c5',
        ),
        isTrue,
      );

      final firstSearch =
          game.requestEngineMove();

      await Future<void>.delayed(
        Duration.zero,
      );

      // Black responds with a legal king move.
      engine.searches[0].complete(
        const EngineMove(
          from: 'd7',
          to: 'c7',
        ),
      );

      expect(
        await firstSearch,
        isTrue,
      );

      expect(
        game.engineBusy,
        isFalse,
      );

      // White second move.
      expect(
        game.playUserMove(
          from: 'c5',
          to: 'b5',
        ),
        isTrue,
      );

      final secondSearch =
          game.requestEngineMove();

      await Future<void>.delayed(
        Duration.zero,
      );

      expect(
        engine.searches.length,
        2,
      );

      // Black king c7 -> b7 is legal in this position.
      engine.searches[1].complete(
        const EngineMove(
          from: 'c7',
          to: 'b7',
        ),
      );

      expect(
        await secondSearch,
        isTrue,
      );

      expect(
        chessController
            .pieceVisualAt('b7'),
        isNotNull,
      );

      expect(
        game.engineBusy,
        isFalse,
      );
    },
  );

  // ---------------------------------------------------------------------------
  // ENGINE PROMOTION
  // ---------------------------------------------------------------------------

  test(
    'engine promotion is applied explicitly',
    () async {
      /*
       * Black pawn is ready to promote:
       *
       * Black king: h8
       * Black pawn: e2
       * White king: a1
       * Black to move
       *
       * Crucially, e1 is EMPTY.
       *
       * Therefore:
       *
       * e2-e1=Q
       *
       * is a legal promotion.
       */
      const fen =
          '7k/8/8/8/8/8/4p3/K7 b - - 0 1';

      final engine =
          HardeningFakeEngine();

      final chessController =
          ChessController(
        fen: fen,
      );

      final game =
          GameEngineController(
        chessController:
            chessController,
        engine: engine,
        engineSide:
            EngineSide.black,
      );

      await game.initialize();

      expect(
        game.isEngineTurn,
        isTrue,
      );

      final search =
          game.requestEngineMove();

      await Future<void>.delayed(
        Duration.zero,
      );

      engine.searches.single.complete(
        const EngineMove(
          from: 'e2',
          to: 'e1',
          promotion: 'q',
        ),
      );

      expect(
        await search,
        isTrue,
      );

      // The pawn must have disappeared from e2.
      expect(
        chessController
            .pieceVisualAt('e2'),
        isNull,
      );

      // A black queen must now occupy e1.
      final promotedPiece =
          chessController
              .pieceVisualAt('e1');

      expect(
        promotedPiece?.type,
        BoardPieceType.queen,
      );

      expect(
        promotedPiece?.isWhite,
        isFalse,
      );
    },
  );
}
