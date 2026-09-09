import 'dart:async';
import 'dart:js_interop';

import 'package:endgame_mastery/core/engine/chess_engine.dart';
import 'package:endgame_mastery/core/engine/engine_config.dart';
import 'package:endgame_mastery/core/engine/engine_exception.dart';
import 'package:endgame_mastery/core/engine/engine_move.dart';
import 'package:endgame_mastery/core/engine/engine_position_analysis.dart';
import 'package:endgame_mastery/core/engine/position_analysis_engine.dart';
import 'package:endgame_mastery/core/engine/uci/uci_best_move_parser.dart';
import 'package:endgame_mastery/core/engine/uci/uci_command_builder.dart';
import 'package:endgame_mastery/core/engine/uci/uci_info_parser.dart';
import 'package:web/web.dart' as web;

/// Web implementation backed by Stockfish 18 Lite WASM.
///
/// The same worker exposes two deliberately separate capabilities:
/// interactive best-move play through [ChessEngine], and post-game position
/// evaluation through [PositionAnalysisEngine]. Only one calculation may be
/// active at a time.
class StockfishWebEngine implements ChessEngine, PositionAnalysisEngine {
  web.Worker? _worker;

  StreamController<String>? _outputController;
  StreamSubscription<String>? _outputSubscription;

  bool _initialized = false;
  bool _disposed = false;

  Completer<EngineMove>? _activeSearch;
  Completer<EnginePositionAnalysis>? _activeAnalysis;

  bool get _hasActiveCalculation =>
      _activeSearch != null || _activeAnalysis != null;

  @override
  Future<void> initialize() async {
    _ensureNotDisposed();

    if (_initialized) {
      return;
    }

    final worker = web.Worker(
      (
        'stockfish/stockfish-18-lite-single.js'
        '#stockfish-18-lite-single.wasm'
      ).toJS,
    );

    final controller = StreamController<String>.broadcast();

    _worker = worker;
    _outputController = controller;

    worker.onmessage = (
      web.MessageEvent event,
    ) {
      final data = event.data;

      if (data == null) {
        return;
      }

      controller.add(data.toString());
    }.toJS;

    worker.onerror = (
      web.Event event,
    ) {
      if (controller.isClosed) {
        return;
      }

      controller.addError(
        const EngineSearchException(
          'Stockfish WebWorker reported an error.',
        ),
      );
    }.toJS;

    _send(UciCommandBuilder.initialize);

    await _waitForExactLine(
      'uciok',
      timeout: const Duration(seconds: 5),
    );

    _send(UciCommandBuilder.isReady);

    await _waitForExactLine(
      'readyok',
      timeout: const Duration(seconds: 5),
    );

    _initialized = true;
  }

  @override
  Future<EngineMove> bestMove({
    required String fen,
    required EngineConfig config,
  }) async {
    _ensureReadyForCalculation();

    final completer = Completer<EngineMove>();
    _activeSearch = completer;

    _outputSubscription = _outputController!.stream.listen(
      (line) {
        final move = UciBestMoveParser.parse(line);

        if (move == null) {
          return;
        }

        if (!completer.isCompleted) {
          completer.complete(move);
        }
      },
      onError: (
        Object error,
        StackTrace stackTrace,
      ) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
    );

    try {
      _send(UciCommandBuilder.positionFromFen(fen));
      _send(UciCommandBuilder.go(config));

      return await completer.future;
    } finally {
      await _clearOutputSubscription();
      _activeSearch = null;
    }
  }

  @override
  Future<EnginePositionAnalysis> analyzePosition({
    required String fen,
    required EngineConfig config,
  }) async {
    _ensureReadyForCalculation();

    final completer = Completer<EnginePositionAnalysis>();
    _activeAnalysis = completer;

    UciAnalysisInfo? latestInfo;

    _outputSubscription = _outputController!.stream.listen(
      (line) {
        final info = UciInfoParser.parse(line);

        if (info != null &&
            (latestInfo == null || info.depth >= latestInfo!.depth)) {
          latestInfo = info;
        }

        final bestMove = UciBestMoveParser.parse(line);

        if (bestMove == null || completer.isCompleted) {
          return;
        }

        final finalInfo = latestInfo;

        if (finalInfo == null) {
          completer.completeError(
            const EngineSearchException(
              'Stockfish returned a best move without an evaluation.',
            ),
          );
          return;
        }

        completer.complete(
          EnginePositionAnalysis(
            fen: fen,
            bestMove: bestMove,
            score: finalInfo.score,
            depth: finalInfo.depth,
            principalVariation: finalInfo.principalVariation,
          ),
        );
      },
      onError: (
        Object error,
        StackTrace stackTrace,
      ) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
    );

    try {
      _send(UciCommandBuilder.positionFromFen(fen));
      _send(UciCommandBuilder.go(config));

      return await completer.future;
    } finally {
      await _clearOutputSubscription();
      _activeAnalysis = null;
    }
  }

  @override
  Future<void> stop() async {
    if (_disposed || _worker == null) {
      return;
    }

    _send(UciCommandBuilder.stop);
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }

    _disposed = true;

    await _clearOutputSubscription();

    final controller = _outputController;

    if (controller != null && !controller.isClosed) {
      await controller.close();
    }

    _outputController = null;

    _worker?.terminate();
    _worker = null;

    _activeSearch = null;
    _activeAnalysis = null;
    _initialized = false;
  }

  Future<void> _clearOutputSubscription() async {
    await _outputSubscription?.cancel();
    _outputSubscription = null;
  }

  void _send(String command) {
    final worker = _worker;

    if (worker == null) {
      throw const EngineInitializationException(
        'Stockfish WebWorker does not exist.',
      );
    }

    worker.postMessage(command.toJS);
  }

  Future<void> _waitForExactLine(
    String expected, {
    required Duration timeout,
  }) async {
    final controller = _outputController;

    if (controller == null) {
      throw const EngineInitializationException(
        'Stockfish output stream does not exist.',
      );
    }

    try {
      await controller.stream
          .firstWhere((line) => line.trim() == expected)
          .timeout(timeout);
    } on TimeoutException {
      throw EngineInitializationException(
        'Timed out waiting for Stockfish response: $expected',
      );
    }
  }

  void _ensureReadyForCalculation() {
    _ensureNotDisposed();

    if (!_initialized) {
      throw const EngineInitializationException(
        'Stockfish Web engine has not been initialized.',
      );
    }

    if (_hasActiveCalculation) {
      throw const EngineSearchException(
        'Stockfish is already calculating.',
      );
    }
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw const EngineDisposedException();
    }
  }
}
