class EngineMove {
  const EngineMove({
    required this.from,
    required this.to,
    this.promotion,
  });

  final String from;
  final String to;

  /// UCI promotion piece:
  /// q, r, b or n.
  final String? promotion;

  String get uci => '$from$to${promotion ?? ''}';

  @override
  bool operator ==(Object other) {
    return other is EngineMove &&
        other.from == from &&
        other.to == to &&
        other.promotion == promotion;
  }

  @override
  int get hashCode {
    return Object.hash(
      from,
      to,
      promotion,
    );
  }

  @override
  String toString() {
    return 'EngineMove($uci)';
  }
}
