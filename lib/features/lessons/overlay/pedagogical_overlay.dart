/// Semantic meaning of a highlighted board square.
///
/// The UI will eventually decide how each role should look.
/// Curriculum/domain code should never contain Flutter colors.
enum SquareOverlayRole { highlight, keySquare, targetSquare, criticalSquare }

/// A single pedagogically meaningful board square.
class SquareOverlay {
  factory SquareOverlay({
    required String square,
    required SquareOverlayRole role,
  }) {
    final normalizedSquare = square.trim().toLowerCase();

    if (!_isValidSquare(normalizedSquare)) {
      throw ArgumentError.value(square, 'square', 'Invalid chess square.');
    }

    return SquareOverlay._(square: normalizedSquare, role: role);
  }

  const SquareOverlay._({required this.square, required this.role});

  final String square;
  final SquareOverlayRole role;

  @override
  bool operator ==(Object other) {
    return other is SquareOverlay &&
        other.square == square &&
        other.role == role;
  }

  @override
  int get hashCode => Object.hash(square, role);

  static bool _isValidSquare(String square) {
    if (square.length != 2) {
      return false;
    }

    final file = square.codeUnitAt(0);
    final rank = square.codeUnitAt(1);

    return file >= 'a'.codeUnitAt(0) &&
        file <= 'h'.codeUnitAt(0) &&
        rank >= '1'.codeUnitAt(0) &&
        rank <= '8'.codeUnitAt(0);
  }
}

/// Directional pedagogical arrow.
///
/// Examples later:
///
/// king route
/// pawn advance
/// opposition direction
class ArrowOverlay {
  factory ArrowOverlay({required String from, required String to}) {
    final normalizedFrom = from.trim().toLowerCase();
    final normalizedTo = to.trim().toLowerCase();

    if (!_isValidSquare(normalizedFrom)) {
      throw ArgumentError.value(from, 'from', 'Invalid arrow origin.');
    }

    if (!_isValidSquare(normalizedTo)) {
      throw ArgumentError.value(to, 'to', 'Invalid arrow destination.');
    }

    if (normalizedFrom == normalizedTo) {
      throw ArgumentError('An arrow must connect two different squares.');
    }

    return ArrowOverlay._(from: normalizedFrom, to: normalizedTo);
  }

  const ArrowOverlay._({required this.from, required this.to});

  final String from;
  final String to;

  static bool _isValidSquare(String square) {
    if (square.length != 2) {
      return false;
    }

    final file = square.codeUnitAt(0);
    final rank = square.codeUnitAt(1);

    return file >= 'a'.codeUnitAt(0) &&
        file <= 'h'.codeUnitAt(0) &&
        rank >= '1'.codeUnitAt(0) &&
        rank <= '8'.codeUnitAt(0);
  }
}

/// A pedagogical area made from one or more board squares.
///
/// Using explicit squares rather than screen coordinates keeps this
/// independent from board orientation, board size and Flutter rendering.
class ZoneOverlay {
  factory ZoneOverlay({required Iterable<String> squares}) {
    final normalizedSquares = <String>{};

    for (final square in squares) {
      final normalizedSquare = square.trim().toLowerCase();

      if (!_isValidSquare(normalizedSquare)) {
        throw ArgumentError.value(square, 'squares', 'Invalid zone square.');
      }

      normalizedSquares.add(normalizedSquare);
    }

    if (normalizedSquares.isEmpty) {
      throw ArgumentError('A zone must contain at least one square.');
    }

    return ZoneOverlay._(squares: Set<String>.unmodifiable(normalizedSquares));
  }

  const ZoneOverlay._({required this.squares});

  final Set<String> squares;

  static bool _isValidSquare(String square) {
    if (square.length != 2) {
      return false;
    }

    final file = square.codeUnitAt(0);
    final rank = square.codeUnitAt(1);

    return file >= 'a'.codeUnitAt(0) &&
        file <= 'h'.codeUnitAt(0) &&
        rank >= '1'.codeUnitAt(0) &&
        rank <= '8'.codeUnitAt(0);
  }
}

/// Complete pedagogical annotation for a board position.
///
/// This is pure domain data:
///
/// - no Flutter widgets;
/// - no colors;
/// - no board orientation;
/// - no Stockfish information.
class PedagogicalOverlay {
  PedagogicalOverlay({
    Iterable<SquareOverlay> squares = const <SquareOverlay>[],
    Iterable<ArrowOverlay> arrows = const <ArrowOverlay>[],
    Iterable<ZoneOverlay> zones = const <ZoneOverlay>[],
  }) : squares = List<SquareOverlay>.unmodifiable(squares),
       arrows = List<ArrowOverlay>.unmodifiable(arrows),
       zones = List<ZoneOverlay>.unmodifiable(zones);

  final List<SquareOverlay> squares;
  final List<ArrowOverlay> arrows;
  final List<ZoneOverlay> zones;

  bool get isEmpty => squares.isEmpty && arrows.isEmpty && zones.isEmpty;
}
