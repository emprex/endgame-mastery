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

  int _positionRevision = 0;
  int _requestId = 0;

  bool get engineBusy => _engineBusy;

  bool get isDisposed => _disposed;

  int get positionRevision =>
      _positionRevision;

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

  Future<void> initialize() async {
    _ensureNotDisposed();

    if (_initialized) {
      return;
    }

    await engine.initialize();

    _ensureNotDisposed();

    _initialized = true;
  }

  Future<bool> playUserMove({
    required String from,
    required String to,
    String? promotion,
  }) async {
    _ensureNotDisposed();

    if (!_initialized) {
      throw StateError(
        'GameEngineController must be initialized first.',
      );
    }

    if (_engineBusy ||
        chessController.isGameOver() ||
        isEngineTurn) {
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

    if (!chessController.isGameOver() &&
        isEngineTurn) {
      await requestEngineMove();
    }

    return true;
  }

  Future<bool> requestEngineMove() async {
    _ensureNotDisposed();

    if (!_initialized) {
      throw StateError(
        'GameEngineController must be initialized first.',
      );
    }

    if (_engineBusy ||
        chessController.isGameOver() ||
        !isEngineTurn) {
      return false;
    }

    final requestId = ++_requestId;
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

      final applied =
          _applyEngineMove(move);

      if (!applied) {
        throw EngineSearchException(
          'Engine returned illegal move: ${move.uci}',
        );
      }

      _positionRevision++;

      return true;
    } finally {
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

  Future<void> reset() async {
    _ensureNotDisposed();

    _requestId++;
    _engineBusy = false;

    await engine.stop();

    chessController.reset();

    _positionRevision++;
  }

  Future<void> stop() async {
    _ensureNotDisposed();

    _requestId++;
    _engineBusy = false;

    await engine.stop();
  }

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

  void _ensureNotDisposed() {
    if (_disposed) {
      throw const EngineDisposedException();
    }
  }
}
