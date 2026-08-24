import 'package:endgame_mastery/core/engine/engine_config.dart';

/// Builds the minimal UCI commands required by Endgame Mastery.
///
/// We intentionally keep this small for Phase 2:
///
/// - initialize Stockfish with `uci`
/// - verify readiness with `isready`
/// - send an exact FEN position
/// - start a short search using movetime
/// - stop an active search
///
/// Deeper analysis options can be added later without changing
/// the higher-level ChessEngine abstraction.
class UciCommandBuilder {
  const UciCommandBuilder._();

  static const String initialize = 'uci';

  static const String isReady = 'isready';

  static const String stop = 'stop';

  static const String quit = 'quit';

  /// Builds:
  ///
  /// `position fen FEN_STRING`
  static String positionFromFen(
    String fen,
  ) {
    final normalizedFen = fen.trim();

    if (normalizedFen.isEmpty) {
      throw ArgumentError.value(
        fen,
        'fen',
        'FEN must not be empty.',
      );
    }

    return 'position fen $normalizedFen';
  }

  /// Builds the search command used for interactive gameplay.
  ///
  /// Endgame Mastery currently prioritizes responsiveness, so
  /// movetime is the primary search limit.
  ///
  /// Example:
  ///
  /// `go movetime 250`
  ///
  /// If an explicit depth is also supplied, it is included as
  /// an additional ceiling.
  static String go(
    EngineConfig config,
  ) {
    final milliseconds =
        config.moveTime.inMilliseconds;

    if (milliseconds <= 0) {
      throw ArgumentError.value(
        config.moveTime,
        'moveTime',
        'Engine move time must be greater than zero.',
      );
    }

    final parts = <String>[
      'go',
      'movetime',
      milliseconds.toString(),
    ];

    final depth = config.depth;

    if (depth != null) {
      parts.addAll([
        'depth',
        depth.toString(),
      ]);
    }

    return parts.join(' ');
  }
}
