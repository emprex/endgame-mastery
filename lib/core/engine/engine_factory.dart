import 'package:endgame_mastery/core/engine/chess_engine.dart';
import 'package:endgame_mastery/core/engine/engine_factory_stub.dart'
    if (dart.library.js_interop)
        'package:endgame_mastery/core/engine/engine_factory_web.dart';

/// Creates the correct chess engine for the current platform.
///
/// BoardScreen and the future lesson controllers must never need
/// to know whether Stockfish is running through:
///
/// - a WebWorker + WASM,
/// - a native isolate,
/// - FFI,
/// - or another platform adapter.
///
/// That decision belongs here.
ChessEngine createChessEngine() {
  return createPlatformChessEngine();
}
