import '../../../core/chess/played_move.dart';
import 'pedagogical_move_assessment.dart';
import 'teaching_state.dart';

/// Curriculum-only coaching rule for the Key Squares concept.
///
/// The rule is intentionally conservative.
///
/// It positively recognizes only one verified event:
/// the white king moves onto one of the pedagogically established key squares.
///
/// It does not classify every other move as bad.
/// Absence of a verified rule means no assessment.
class KeySquaresMoveAssessmentRule {
  const KeySquaresMoveAssessmentRule();

  PedagogicalMoveAssessment? assess({
    required PlayedMove move,
    required TeachingState before,
    required TeachingState after,
  }) {
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
