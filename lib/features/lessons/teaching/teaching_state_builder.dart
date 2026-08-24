import '../domain/lesson_definition.dart';
import '../overlay/pedagogical_overlay_engine.dart';
import 'teaching_state.dart';

/// Builds the pedagogical state for a lesson position.
///
/// Responsibilities:
///
/// - derive side to move from the current FEN;
/// - retrieve known theoretical curriculum truth;
/// - retrieve the teaching explanation for an exact known position;
/// - generate semantic board overlays.
///
/// It does NOT:
///
/// - ask Stockfish;
/// - calculate tablebases;
/// - mutate ChessController;
/// - render UI.
class TeachingStateBuilder {
  const TeachingStateBuilder({
    this.overlayEngine = const PedagogicalOverlayEngine(),
  });

  final PedagogicalOverlayEngine overlayEngine;

  TeachingState build({required LessonDefinition lesson, required String fen}) {
    final normalizedFen = fen.trim();

    LessonDefinition.validateFen(normalizedFen);

    final theoreticalResult = lesson.theoreticalResultForFen(normalizedFen);

    return TeachingState(
      fen: normalizedFen,
      sideToMove: _sideToMoveFromFen(normalizedFen),
      theoreticalResult: theoreticalResult,
      overlay: overlayEngine.build(lesson: lesson, fen: normalizedFen),
      teachingPoint: _teachingPointForFen(lesson: lesson, fen: normalizedFen),
    );
  }

  ChessSide _sideToMoveFromFen(String fen) {
    final fields = fen.split(RegExp(r'\s+'));

    return fields[1] == 'w' ? ChessSide.white : ChessSide.black;
  }

  String? _teachingPointForFen({
    required LessonDefinition lesson,
    required String fen,
  }) {
    if (fen == lesson.fen) {
      // The main lesson explanation already lives in learnText.
      //
      // We do not duplicate it here.
      return null;
    }

    for (final outcome in lesson.comparisonOutcomes) {
      if (outcome.fen == fen) {
        return outcome.teachingPoint;
      }
    }

    return null;
  }
}
