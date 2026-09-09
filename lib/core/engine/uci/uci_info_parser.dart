import 'package:endgame_mastery/core/engine/engine_position_analysis.dart';

class UciAnalysisInfo {
  UciAnalysisInfo({
    required this.depth,
    required this.score,
    required List<String> principalVariation,
  }) : principalVariation = List<String>.unmodifiable(principalVariation);

  final int depth;
  final EngineScore score;
  final List<String> principalVariation;
}

/// Extracts the evaluation fields required by the coach from a UCI `info` line.
///
/// Other Stockfish telemetry is deliberately ignored here. This parser does not
/// assign chess labels such as mistake/blunder; it only preserves engine data.
class UciInfoParser {
  const UciInfoParser._();

  static UciAnalysisInfo? parse(String line) {
    final normalized = line.trim();

    if (normalized.isEmpty) {
      return null;
    }

    final tokens = normalized.split(RegExp(r'\s+'));

    if (tokens.isEmpty || tokens.first != 'info') {
      return null;
    }

    var depth = 0;
    EngineScore? score;
    var principalVariation = <String>[];

    for (var index = 1; index < tokens.length; index++) {
      final token = tokens[index];

      if (token == 'depth' && index + 1 < tokens.length) {
        depth = int.tryParse(tokens[index + 1]) ?? depth;
        index++;
        continue;
      }

      if (token == 'score' && index + 2 < tokens.length) {
        final scoreType = tokens[index + 1];
        final scoreValue = int.tryParse(tokens[index + 2]);

        if (scoreValue != null) {
          score = switch (scoreType) {
            'cp' => EngineScore.centipawns(scoreValue),
            'mate' => EngineScore.mate(scoreValue),
            _ => score,
          };
        }

        index += 2;
        continue;
      }

      if (token == 'pv') {
        principalVariation = tokens.sublist(index + 1);
        break;
      }
    }

    if (score == null) {
      return null;
    }

    return UciAnalysisInfo(
      depth: depth,
      score: score,
      principalVariation: principalVariation,
    );
  }
}
