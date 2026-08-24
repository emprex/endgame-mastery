import 'dart:async';

import 'package:endgame_mastery/core/chess/chess_controller.dart';
import 'package:endgame_mastery/core/engine/chess_engine.dart';
import 'package:endgame_mastery/core/engine/engine_config.dart';
import 'package:endgame_mastery/core/engine/engine_exception.dart';
import 'package:endgame_mastery/core/engine/engine_move.dart';

enum EngineSide {
  white,
  black,
}

/// Coordinates chess rules with an asynchronous chess engine.
///
/// Responsibilities:
///
/// - knows which side the engine plays;
/// - prevents user input during the engine turn;
/// - tracks position revisions;
/// - rejects stale engine responses;
/// - validates every engine move through ChessController;
/// - handles reset while the engine is calculating;
/// - handles engine timeout without leaving the UI locked.
///
/// Platform-specific Stockfish code does NOT belong here.
class GameEngineController {
  GameEngineController({
    required this.chessController,
    required this.engine,
    this.engineSide = EngineSide.black,
    this.engineConfig = const EngineConfig(),
    this.searchTimeout = const Duration(
      seconds: 2,
    ),
  });

  final ChessController chessController;
  final ChessEngine engine;

  final EngineSide engineSide;
  final EngineConfig engineConfig;
  final Duration searchTimeout;

  bool _initialized = false;
  bool _disposed = false;
  bool _engineBusy = false;

  EngineMove? _lastEngineMove;

  int _positionRevision = 0;
  int _requestId = 0;

  bool get engineBusy => _engineBusy;

  bool get isDisposed => _disposed;

  EngineMove? get lastEngineMove =>
      _lastEngineMove;

  int get positionRevision =>
      _positionRevision;

  /// True when the current position belongs to the engine.
  bool get isEngineTurn {
    if (chessController.isGameOver()) {
      return false;
    }

    return switch (engineSide) {
      EngineSide.white =>
        chessController.isWhiteToMove(),

      EngineSide.black =>
        !chessController.isWhiteToMove(),
    };
  }

  /// True when the current position belongs to the human player.
  bool get isUserTurn {
    if (chessController.isGameOver()) {
      return false;
    }

    return !isEngineTurn;
  }

  // ---------------------------------------------------------------------------
  // INITIALIZATION
  // ---------------------------------------------------------------------------

  Future<void> initialize() async {
    _ensureNotDisposed();

    if (_initialized) {
      return;
    }

    await engine.initialize();

    _ensureNotDisposed();

    _initialized = true;
  }

  // ---------------------------------------------------------------------------
  // USER MOVE
  // ---------------------------------------------------------------------------

  /// Applies the human move immediately.
  ///
  /// The engine search is deliberately NOT started here.
  ///
  /// This allows Flutter to repaint the board first:
  ///
  /// human move
  /// -> visible immediately
  /// -> engine search starts afterwards.
  bool playUserMove({
    required String from,
    required String to,
    String? promotion,
  }) {
    _ensureNotDisposed();
    _ensureInitialized();

    if (_engineBusy ||
        chessController.isGameOver() ||
        !isUserTurn) {
      return false;
    }

    final moved = chessController.move(
      from: from,
      to: to,
      promotion: promotion,
    );

    if (!moved) {
      return false;
    }

    _positionRevision++;

    return true;
  }

  // ---------------------------------------------------------------------------
  // ENGINE MOVE
  // ---------------------------------------------------------------------------

  Future<bool> requestEngineMove() async {
    _ensureNotDisposed();
    _ensureInitialized();

    if (_engineBusy ||
        chessController.isGameOver() ||
        !isEngineTurn) {
      return false;
    }

    final requestId =
        ++_requestId;

    final revisionAtStart =
        _positionRevision;

    final fenAtStart =
        chessController.fen;

    _engineBusy = true;

    try {
      final move = await engine
          .bestMove(
            fen: fenAtStart,
            config: engineConfig,
          )
          .timeout(
            searchTimeout,
            onTimeout: () {
              throw const EngineTimeoutException(
                'Engine search timed out.',
              );
            },
          );

      // -----------------------------------------------------------------------
      // STALE RESPONSE PROTECTION
      // -----------------------------------------------------------------------
      //
      // The answer is discarded if anything changed while Stockfish
      // was calculating.
      //
      // Examples:
      //
      // - Reset was pressed.
      // - Another request replaced this one.
      // - The board position changed.
      // - The controller was disposed.
      // - The game ended.

      if (_disposed ||
          requestId != _requestId ||
          revisionAtStart !=
              _positionRevision ||
          chessController.fen !=
              fenAtStart ||
          !isEngineTurn ||
          chessController.isGameOver()) {
        return false;
      }

      // -----------------------------------------------------------------------
      // LEGALITY GATE
      // -----------------------------------------------------------------------
      //
      // Even Stockfish output is never trusted blindly.
      //
      // Every returned move must pass ChessController / package:chess.

      final applied =
          _applyEngineMove(
        move,
      );

      if (!applied) {
        throw EngineSearchException(
          'Engine returned illegal move: ${move.uci}',
        );
      }

      _lastEngineMove = move;

      _positionRevision++;

      return true;
    } on EngineTimeoutException {
      // -----------------------------------------------------------------------
      // TIMEOUT RECOVERY
      // -----------------------------------------------------------------------
      //
      // Invalidate the timed-out request immediately.
      //
      // If Stockfish later emits a bestmove from that old search,
      // GameEngineController will never apply it to the board.

      if (requestId == _requestId) {
        _requestId++;
      }

      _engineBusy = false;

      // Ask the underlying engine to stop its old calculation.
      //
      // Stockfish remains alive and can be reused afterwards.
      await engine.stop();

      rethrow;
    } finally {
      // Only the currently valid request is allowed to change
      // the busy state here.
      //
      // Reset/stop/timeout may already have invalidated it.
      if (requestId == _requestId) {
        _engineBusy = false;
      }
    }
  }

  bool _applyEngineMove(
    EngineMove move,
  ) {
    return chessController.move(
      from: move.from,
      to: move.to,
      promotion: move.promotion,
    );
  }

  // ---------------------------------------------------------------------------
  // RESET
  // ---------------------------------------------------------------------------

  Future<void> reset() async {
    _ensureNotDisposed();

    // Invalidate every result belonging to the previous position.
    _requestId++;

    _engineBusy = false;

    await engine.stop();

    chessController.reset();

    _lastEngineMove = null;

    _positionRevision++;
  }

  // ---------------------------------------------------------------------------
  // STOP
  // ---------------------------------------------------------------------------

  Future<void> stop() async {
    _ensureNotDisposed();

    _requestId++;

    _engineBusy = false;

    await engine.stop();
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }

    _disposed = true;

    _requestId++;

    _engineBusy = false;

    await engine.stop();

    await engine.dispose();
  }

  // ---------------------------------------------------------------------------
  // SAFETY
  // ---------------------------------------------------------------------------

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'GameEngineController must be initialized first.',
      );
    }
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw const EngineDisposedException();
    }
  }
}
