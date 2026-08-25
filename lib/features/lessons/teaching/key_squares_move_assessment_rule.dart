import '../../../core/chess/played_move.dart';
import 'pedagogical_move_assessment.dart';
import 'teaching_state.dart';

/// Curriculum-only coaching rule for the Key Squares concept.
///
/// The rule is intentionally conservative. It recognizes only events that are
/// explicitly supported by the verified curriculum positions and variations.
/// Absence of a verified rule means no assessment.
class KeySquaresMoveAssessmentRule {
  const KeySquaresMoveAssessmentRule();

  static const String _diagram12Start =
      '1k6/8/1K6/1P6/8/8/8/8 w';
  static const String _diagram12StalemateTrap =
      'k7/2K5/8/1P6/8/8/8/8 w';

  PedagogicalMoveAssessment? assess({
    required PlayedMove move,
    required TeachingState before,
    required TeachingState after,
  }) {
    final diagram12Assessment = _assessDiagram12(move: move, before: before);

    if (diagram12Assessment != null) {
      return diagram12Assessment;
    }

    if (!_whiteKingWasOn(fen: before.fen, square: move.from)) {
      return null;
    }

    if (!after.keySquares.contains(move.to)) {
      return null;
    }

    return PedagogicalMoveAssessment(
      move: move,
      quality: PedagogicalMoveQuality.reinforcesConcept,
      title: 'You reached a key square',
      message:
          '${move.to} is a verified key square in this position. '
          'Reaching a key square is the central objective of this concept.',
      source: PedagogicalAssessmentSource.curriculum,
    );
  }

  PedagogicalMoveAssessment? _assessDiagram12({
    required PlayedMove move,
    required TeachingState before,
  }) {
    final signature = _positionSignature(before.fen);

    if (signature == _diagram12Start && move.uci == 'b6a6') {
      return PedagogicalMoveAssessment(
        move: move,
        quality: PedagogicalMoveQuality.reinforcesConcept,
        title: 'Use the king to convert',
        message:
            'White already starts on a key square. Ka6 follows the verified '
            'conversion route: improve the king before advancing the pawn.',
        source: PedagogicalAssessmentSource.curriculum,
      );
    }

    if (signature == _diagram12Start && move.uci == 'b6c6') {
      return PedagogicalMoveAssessment(
        move: move,
        quality: PedagogicalMoveQuality.needsAttention,
        title: 'A less direct king route',
        message:
            'Kc6 is the inaccurate route highlighted in the book. After the '
            'defensive resource ...Ka7, White must return toward the original '
            'winning setup. The position is still winning, but the conversion '
            'has become less direct.',
        source: PedagogicalAssessmentSource.curriculum,
      );
    }

    if (signature == _diagram12StalemateTrap && move.uci == 'b5b6') {
      return PedagogicalMoveAssessment(
        move: move,
        quality: PedagogicalMoveQuality.needsAttention,
        title: 'Stalemate resource',
        message:
            'Pushing b6 here leaves the black king with no legal move while '
            'it is not in check: stalemate. Preserve the winning king route '
            'before advancing the pawn.',
        source: PedagogicalAssessmentSource.curriculum,
      );
    }

    return null;
  }

  String _positionSignature(String fen) {
    final fields = fen.trim().split(RegExp(r'\s+'));

    if (fields.length < 2) {
      return fen.trim();
    }

    return '${fields[0]} ${fields[1]}';
  }

  bool _whiteKingWasOn({required String fen, required String square}) {
    final piecePlacement = fen.trim().split(RegExp(r'\s+')).first;

    final ranks = piecePlacement.split('/');

    if (ranks.length != 8) {
      return false;
    }

    final targetFile = square.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final targetRank = int.tryParse(square.substring(1));

    if (targetFile < 0 ||
        targetFile > 7 ||
        targetRank == null ||
        targetRank < 1 ||
        targetRank > 8) {
      return false;
    }

    final fenRankIndex = 8 - targetRank;
    final rankData = ranks[fenRankIndex];

    var fileIndex = 0;

    for (final codeUnit in rankData.codeUnits) {
      final char = String.fromCharCode(codeUnit);
      final emptyCount = int.tryParse(char);

      if (emptyCount != null) {
        fileIndex += emptyCount;
        continue;
      }

      if (fileIndex == targetFile) {
        return char == 'K';
      }

      fileIndex++;
    }

    return false;
  }
}
