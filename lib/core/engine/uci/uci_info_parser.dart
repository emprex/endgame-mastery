class UciInfo {
  const UciInfo({
    required this.depth,
    required this.scoreCp,
    required this.mateIn,
    required this.principalVariation,
  });

  final int? depth;
  final int? scoreCp;
  final int? mateIn;
  final List<String> principalVariation;
}

class UciInfoParser {
  const UciInfoParser._();

  static UciInfo? parse(String line) {
    final tokens = line.trim().split(RegExp(r'\s+'));
    if (tokens.isEmpty || tokens.first != 'info') {
      return null;
    }

    int? depth;
    int? scoreCp;
    int? mateIn;
    var principalVariation = const <String>[];

    for (var index = 1; index < tokens.length; index++) {
      final token = tokens[index];

      if (token == 'depth' && index + 1 < tokens.length) {
        depth = int.tryParse(tokens[++index]);
        continue;
      }

      if (token == 'score' && index + 2 < tokens.length) {
        final type = tokens[++index];
        final value = int.tryParse(tokens[++index]);
        if (type == 'cp') scoreCp = value;
        if (type == 'mate') mateIn = value;
        continue;
      }

      if (token == 'pv' && index + 1 < tokens.length) {
        principalVariation = List.unmodifiable(tokens.sublist(index + 1));
        break;
      }
    }

    if (depth == null &&
        scoreCp == null &&
        mateIn == null &&
        principalVariation.isEmpty) {
      return null;
    }

    return UciInfo(
      depth: depth,
      scoreCp: scoreCp,
      mateIn: mateIn,
      principalVariation: principalVariation,
    );
  }
}
