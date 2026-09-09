import 'package:endgame_mastery/features/coach/domain/game_position.dart';

class ImportedGame {
  ImportedGame({
    required this.rawPgn,
    required Map<String, String> headers,
    required List<String> moves,
    required List<GamePosition> positions,
    required this.initialFen,
    required this.finalFen,
  }) : assert(moves.length == positions.length),
       headers = Map<String, String>.unmodifiable(headers),
       moves = List<String>.unmodifiable(moves),
       positions = List<GamePosition>.unmodifiable(positions);

  final String rawPgn;
  final Map<String, String> headers;
  final List<String> moves;
  final List<GamePosition> positions;
  final String initialFen;
  final String finalFen;

  String get white => headers['White'] ?? 'White';

  String get black => headers['Black'] ?? 'Black';

  String get result => headers['Result'] ?? '*';

  String? get event => _optionalHeader('Event');

  String? get date => _optionalHeader('Date');

  int get plyCount => moves.length;

  int get fullMoveCount => (moves.length + 1) ~/ 2;

  int get analysisPositionCount => positions.length;

  String? _optionalHeader(String key) {
    final value = headers[key]?.trim();

    if (value == null || value.isEmpty || value == '?') {
      return null;
    }

    return value;
  }
}
