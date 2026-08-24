import 'package:endgame_mastery/core/engine/chess_engine.dart';
import 'package:endgame_mastery/core/engine/web/stockfish_web_engine.dart';

/// Web engine factory.
///
/// Stockfish runs in its own WebWorker and therefore does not block
/// Flutter's rendering/UI thread.
ChessEngine createPlatformChessEngine() {
  return StockfishWebEngine();
}
