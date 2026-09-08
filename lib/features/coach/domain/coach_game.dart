class CoachGame {
  const CoachGame({
    required this.headers,
    required this.moves,
    required this.rawPgn,
  });

  final Map<String, String> headers;
  final List<String> moves;
  final String rawPgn;

  String get white => headers['White'] ?? 'White';
  String get black => headers['Black'] ?? 'Black';
  String get result => headers['Result'] ?? '*';
  String? get whiteElo => headers['WhiteElo'];
  String? get blackElo => headers['BlackElo'];
  String? get date => headers['Date'];
  String? get site => headers['Site'];
  String? get timeControl => headers['TimeControl'];

  int get plyCount => moves.length;
  int get fullMoveCount => (moves.length + 1) ~/ 2;
}
