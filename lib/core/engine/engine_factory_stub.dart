import 'package:endgame_mastery/core/engine/chess_engine.dart';
import 'package:endgame_mastery/core/engine/legal_move_test_engine.dart';

/// Temporary non-Web engine factory.
///
/// Phase 2 currently integrates real Stockfish on Web first.
///
/// Android and iOS will later receive their own native Stockfish
/// implementation without requiring any BoardScreen changes.
ChessEngine createPlatformChessEngine() {
  return LegalMoveTestEngine();
}
