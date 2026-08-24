/// Immutable description of one completed chess move.
///
/// This is transport data only.
/// It contains no engine evaluation and no pedagogical judgement.
class PlayedMove {
  factory PlayedMove({
    required String from,
    required String to,
    String? promotion,
  }) {
    final normalizedFrom = from.trim().toLowerCase();
    final normalizedTo = to.trim().toLowerCase();
    final normalizedPromotion = promotion?.trim().toLowerCase();

    if (!_isSquare(normalizedFrom)) {
      throw ArgumentError.value(from, 'from', 'Invalid origin square.');
    }

    if (!_isSquare(normalizedTo)) {
      throw ArgumentError.value(to, 'to', 'Invalid destination square.');
    }

    if (normalizedFrom == normalizedTo) {
      throw ArgumentError('Origin and destination must be different.');
    }

    if (normalizedPromotion != null &&
        !const <String>{'q', 'r', 'b', 'n'}.contains(normalizedPromotion)) {
      throw ArgumentError.value(
        promotion,
        'promotion',
        'Promotion must be q, r, b or n.',
      );
    }

    return PlayedMove._(
      from: normalizedFrom,
      to: normalizedTo,
      promotion: normalizedPromotion,
    );
  }

  const PlayedMove._({
    required this.from,
    required this.to,
    required this.promotion,
  });

  final String from;
  final String to;
  final String? promotion;

  String get uci {
    return '$from$to${promotion ?? ''}';
  }

  static bool _isSquare(String square) {
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
