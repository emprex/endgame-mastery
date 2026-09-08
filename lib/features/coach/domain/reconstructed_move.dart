class ReconstructedMove {
  const ReconstructedMove({
    required this.ply,
    required this.san,
    required this.fenBefore,
    required this.fenAfter,
  });

  final int ply;
  final String san;
  final String fenBefore;
  final String fenAfter;

  bool get wasWhiteMove => ply.isOdd;
  int get fullMoveNumber => (ply + 1) ~/ 2;
}
