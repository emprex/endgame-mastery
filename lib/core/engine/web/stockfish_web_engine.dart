import 'dart:async';
import 'dart:js_interop';

import 'package:endgame_mastery/core/engine/chess_engine.dart';
import 'package:endgame_mastery/core/engine/engine_config.dart';
import 'package:endgame_mastery/core/engine/engine_exception.dart';
import 'package:endgame_mastery/core/engine/engine_move.dart';
import 'package:endgame_mastery/core/engine/uci/uci_best_move_parser.dart';
import 'package:endgame_mastery/core/engine/uci/uci_command_builder.dart';
import 'package:web/web.dart' as web;

/// Web implementation of [ChessEngine] backed by
/// Stockfish 18 Lite WASM.
///
/// Stockfish runs inside a browser WebWorker.
///
/// This is important because engine calculation must never
/// block Flutter's UI thread.
///
/// The worker is loaded directly from:
///
/// stockfish/stockfish-18-lite-single.js
///
/// and its companion WebAssembly binary is:
///
/// stockfish/stockfish-18-lite-single.wasm
class StockfishWebEngine implements ChessEngine {
  web.Worker? _worker;

  StreamController<String>? _outputController;

  StreamSubscription<String>? _outputSubscription;

  bool _initialized = false;

  bool _disposed = false;

  Completer<EngineMove>? _activeSearch;

  // ---------------------------------------------------------------------------
  // INITIALIZATION
  // ---------------------------------------------------------------------------

  @override
  Future<void> initialize() async {
    _ensureNotDisposed();

    if (_initialized) {
      return;
    }

    /*
     * Stockfish.js itself is the WebWorker.
     *
     * The URL fragment explicitly tells Stockfish.js which
     * WebAssembly file belongs to this JavaScript worker.
     *
     * package:web expects a JavaScript value here, so the Dart
     * String is converted with `.toJS`.
     */
    final worker = web.Worker(
      (
        'stockfish/stockfish-18-lite-single.js'
        '#stockfish-18-lite-single.wasm'
      ).toJS,
    );

    final controller =
        StreamController<String>.broadcast();

    _worker = worker;

    _outputController = controller;

    // -------------------------------------------------------------------------
    // STOCKFISH OUTPUT
    // -------------------------------------------------------------------------

    worker.onmessage = (
      web.MessageEvent event,
    ) {
      final data = event.data;

      if (data == null) {
        return;
      }

      /*
       * Stockfish sends UCI output as JavaScript strings.
       *
       * Convert the JS value back to a Dart String before
       * forwarding it to the rest of the application.
       */
      controller.add(
        data.toString(),
      );
    }.toJS;

    // -------------------------------------------------------------------------
    // WORKER ERROR
    // -------------------------------------------------------------------------

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

    // -------------------------------------------------------------------------
    // UCI HANDSHAKE
    // -------------------------------------------------------------------------

    /*
     * Step 1:
     *
     * Ask Stockfish to enter UCI mode.
     */
    _send(
      UciCommandBuilder.initialize,
    );

    /*
     * Step 2:
     *
     * Stockfish must answer:
     *
     * uciok
     */
    await _waitForExactLine(
      'uciok',
      timeout: const Duration(
        seconds: 5,
      ),
    );

    /*
     * Step 3:
     *
     * Ask whether Stockfish is ready.
     */
    _send(
      UciCommandBuilder.isReady,
    );

    /*
     * Step 4:
     *
     * Stockfish must answer:
     *
     * readyok
     */
    await _waitForExactLine(
      'readyok',
      timeout: const Duration(
        seconds: 5,
      ),
    );

    _initialized = true;
  }

  // ---------------------------------------------------------------------------
  // BEST MOVE SEARCH
  // ---------------------------------------------------------------------------

  @override
  Future<EngineMove> bestMove({
    required String fen,
    required EngineConfig config,
  }) async {
    _ensureNotDisposed();

    if (!_initialized) {
      throw const EngineInitializationException(
        'Stockfish Web engine has not been initialized.',
      );
    }

    /*
     * For Phase 2 we allow only one active Stockfish search.
     *
     * GameEngineController is responsible for sequencing
     * requests and rejecting stale responses.
     */
    if (_activeSearch != null) {
      throw const EngineSearchException(
        'Stockfish is already calculating.',
      );
    }

    final completer =
        Completer<EngineMove>();

    _activeSearch = completer;

    // -------------------------------------------------------------------------
    // WAIT FOR BESTMOVE
    // -------------------------------------------------------------------------

    _outputSubscription =
        _outputController!.stream.listen(
      (line) {
        /*
         * Most Stockfish output consists of lines such as:
         *
         * info depth 12 ...
         *
         * The parser ignores them and only returns a value
         * when it encounters:
         *
         * bestmove d7c7
         */
        final move =
            UciBestMoveParser.parse(
          line,
        );

        if (move == null) {
          return;
        }

        if (!completer.isCompleted) {
          completer.complete(
            move,
          );
        }
      },
      onError: (
        Object error,
        StackTrace stackTrace,
      ) {
        if (!completer.isCompleted) {
          completer.completeError(
            error,
            stackTrace,
          );
        }
      },
    );

    try {
      // -----------------------------------------------------------------------
      // SEND EXACT POSITION
      // -----------------------------------------------------------------------

      _send(
        UciCommandBuilder
            .positionFromFen(
          fen,
        ),
      );

      // -----------------------------------------------------------------------
      // START RESPONSIVE SEARCH
      // -----------------------------------------------------------------------

      /*
       * Current gameplay target:
       *
       * approximately 150–400 ms.
       *
       * EngineConfig currently defaults to 250 ms.
       */
      _send(
        UciCommandBuilder.go(
          config,
        ),
      );

      return await completer.future;
    } finally {
      /*
       * Always remove the temporary bestmove listener.
       *
       * This prevents old listeners from accumulating
       * between engine searches.
       */
      await _outputSubscription
          ?.cancel();

      _outputSubscription = null;

      _activeSearch = null;
    }
  }

  // ---------------------------------------------------------------------------
  // STOP
  // ---------------------------------------------------------------------------

  @override
  Future<void> stop() async {
    if (_disposed ||
        _worker == null) {
      return;
    }

    /*
     * UCI stop does not kill Stockfish.
     *
     * It asks the current search to stop and Stockfish normally
     * responds with its current bestmove.
     *
     * GameEngineController request IDs ensure that a stale
     * bestmove cannot be applied after reset/stop.
     */
    _send(
      UciCommandBuilder.stop,
    );
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }

    _disposed = true;

    await _outputSubscription
        ?.cancel();

    _outputSubscription = null;

    final controller =
        _outputController;

    if (controller != null &&
        !controller.isClosed) {
      await controller.close();
    }

    _outputController = null;

    /*
     * terminate() immediately releases the browser worker.
     */
    _worker?.terminate();

    _worker = null;

    _activeSearch = null;

    _initialized = false;
  }

  // ---------------------------------------------------------------------------
  // UCI COMMAND OUTPUT
  // ---------------------------------------------------------------------------

  void _send(
    String command,
  ) {
    final worker = _worker;

    if (worker == null) {
      throw const EngineInitializationException(
        'Stockfish WebWorker does not exist.',
      );
    }

    /*
     * package:web expects JavaScript values.
     *
     * Convert the Dart String into JSString.
     */
    worker.postMessage(
      command.toJS,
    );
  }

  // ---------------------------------------------------------------------------
  // UCI HANDSHAKE HELPER
  // ---------------------------------------------------------------------------

  Future<void> _waitForExactLine(
    String expected, {
    required Duration timeout,
  }) async {
    final controller =
        _outputController;

    if (controller == null) {
      throw const EngineInitializationException(
        'Stockfish output stream does not exist.',
      );
    }

    try {
      await controller.stream
          .firstWhere(
            (line) =>
                line.trim() ==
                expected,
          )
          .timeout(
            timeout,
          );
    } on TimeoutException {
      throw EngineInitializationException(
        'Timed out waiting for Stockfish response: $expected',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // SAFETY
  // ---------------------------------------------------------------------------

  void _ensureNotDisposed() {
    if (_disposed) {
      throw const EngineDisposedException();
    }
  }
}
