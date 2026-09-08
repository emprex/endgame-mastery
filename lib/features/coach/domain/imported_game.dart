class ImportedGame {
  ImportedGame({
    required this.rawPgn,
    required Map<String, String> headers,
    required List<String> moves,
  }) : headers = Map<String, String>.unmodifiable(headers),
       moves = List<String>.unmodifiable(moves);

  final String rawPgn;
  final Map<String, String> headers;
  final List<String> moves;

  String get white => headers['White'] ?? 'White';

  String get black => headers['Black'] ?? 'Black';

  String get result => headers['Result'] ?? '*';

  String? get event => _optionalHeader('Event');

  String? get date => _optionalHeader('Date');

  int get plyCount => moves.length;

  int get fullMoveCount => (moves.length + 1) ~/ 2;

  String? _optionalHeader(String key) {
    final value = headers[key]?.trim();

    if (value == null || value.isEmpty || value == '?') {
      return null;
    }

    return value;
  }
}
