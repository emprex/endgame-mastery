/// Side used by a chess position or lesson.
enum ChessSide { white, black }

/// High-level pedagogical concept taught by a lesson.
enum LessonConcept { keySquares }

/// The theoretical result from the learner's point of view.
///
/// This is curriculum truth, not a Stockfish evaluation.
enum TheoreticalResult { win, draw, loss }

/// Theoretical truth attached to one exact chess position.
///
/// The complete FEN is preserved because side to move is part of the
/// theoretical position and can completely change the result.
class LessonPositionOutcome {
  factory LessonPositionOutcome({
    required String fen,
    required TheoreticalResult result,
    String? teachingPoint,
  }) {
    final normalizedFen = fen.trim();
    final normalizedTeachingPoint = teachingPoint?.trim();

    LessonDefinition.validateFen(normalizedFen);

    return LessonPositionOutcome._(
      fen: normalizedFen,
      result: result,
      teachingPoint:
          normalizedTeachingPoint == null || normalizedTeachingPoint.isEmpty
          ? null
          : normalizedTeachingPoint,
    );
  }

  const LessonPositionOutcome._({
    required this.fen,
    required this.result,
    required this.teachingPoint,
  });

  final String fen;

  /// Result from the learner's point of view.
  final TheoreticalResult result;

  final String? teachingPoint;

  ChessSide get sideToMove {
    final fields = fen.split(RegExp(r'\s+'));

    return fields[1] == 'w' ? ChessSide.white : ChessSide.black;
  }
}

/// Immutable curriculum definition.
///
/// This object contains pedagogical truth and lesson metadata only.
///
/// It does NOT control:
/// - ChessController
/// - Stockfish
/// - gameplay state
/// - board rendering
/// - pedagogical overlay rendering
class LessonDefinition {
  factory LessonDefinition({
    required String id,
    required String title,
    required String fen,
    required LessonConcept concept,
    required String objective,
    required String learnText,
    required ChessSide userSide,
    required Iterable<String> initialKeySquares,
    required TheoreticalResult theoreticalResult,
    required int difficulty,
    Iterable<LessonPositionOutcome> comparisonOutcomes =
        const <LessonPositionOutcome>[],
  }) {
    final normalizedId = id.trim();
    final normalizedTitle = title.trim();
    final normalizedFen = fen.trim();
    final normalizedObjective = objective.trim();
    final normalizedLearnText = learnText.trim();

    _validateRequiredText(fieldName: 'id', value: normalizedId);

    _validateRequiredText(fieldName: 'title', value: normalizedTitle);

    _validateRequiredText(fieldName: 'objective', value: normalizedObjective);

    _validateRequiredText(fieldName: 'learnText', value: normalizedLearnText);

    validateFen(normalizedFen);

    if (difficulty < 1 || difficulty > 5) {
      throw ArgumentError.value(
        difficulty,
        'difficulty',
        'Lesson difficulty must be between 1 and 5.',
      );
    }

    final normalizedSquares = <String>{};

    for (final square in initialKeySquares) {
      final normalizedSquare = square.trim().toLowerCase();

      if (!_isValidSquare(normalizedSquare)) {
        throw ArgumentError.value(
          square,
          'initialKeySquares',
          'Invalid chess square.',
        );
      }

      if (!normalizedSquares.add(normalizedSquare)) {
        throw ArgumentError.value(
          square,
          'initialKeySquares',
          'Key squares must be unique.',
        );
      }
    }

    final normalizedOutcomes = List<LessonPositionOutcome>.unmodifiable(
      comparisonOutcomes,
    );

    // The same exact FEN must never carry two contradictory
    // theoretical results inside one lesson.
    final knownFens = <String>{normalizedFen};

    for (final outcome in normalizedOutcomes) {
      if (!knownFens.add(outcome.fen)) {
        throw ArgumentError(
          'Every theoretical position in a lesson must use a unique FEN.',
        );
      }
    }

    return LessonDefinition._(
      id: normalizedId,
      title: normalizedTitle,
      fen: normalizedFen,
      concept: concept,
      objective: normalizedObjective,
      learnText: normalizedLearnText,
      userSide: userSide,
      initialKeySquares: Set<String>.unmodifiable(normalizedSquares),
      theoreticalResult: theoreticalResult,
      difficulty: difficulty,
      comparisonOutcomes: normalizedOutcomes,
    );
  }

  const LessonDefinition._({
    required this.id,
    required this.title,
    required this.fen,
    required this.concept,
    required this.objective,
    required this.learnText,
    required this.userSide,
    required this.initialKeySquares,
    required this.theoreticalResult,
    required this.difficulty,
    required this.comparisonOutcomes,
  });

  final String id;
  final String title;

  /// Initial teaching position.
  final String fen;

  final LessonConcept concept;
  final String objective;
  final String learnText;
  final ChessSide userSide;

  /// Key squares known to apply to the initial teaching position.
  ///
  /// Dynamic key-square calculation belongs to the future concept rule layer.
  final Set<String> initialKeySquares;

  /// Theoretical result of [fen], from the learner's point of view.
  final TheoreticalResult theoreticalResult;

  final int difficulty;

  /// Closely related theoretical positions used to teach contrasts.
  ///
  /// Example:
  ///
  /// same pieces + White to move -> draw
  /// same pieces + Black to move -> White wins
  final List<LessonPositionOutcome> comparisonOutcomes;

  ChessSide get sideToMove {
    final fields = fen.split(RegExp(r'\s+'));

    return fields[1] == 'w' ? ChessSide.white : ChessSide.black;
  }

  /// Returns curriculum truth for an exact FEN.
  ///
  /// Complete-FEN comparison is deliberate:
  /// side to move is part of the chess position.
  ///
  /// Unknown positions return null rather than inventing a result.
  TheoreticalResult? theoreticalResultForFen(String positionFen) {
    final normalizedFen = positionFen.trim();

    if (normalizedFen == fen) {
      return theoreticalResult;
    }

    for (final outcome in comparisonOutcomes) {
      if (outcome.fen == normalizedFen) {
        return outcome.result;
      }
    }

    return null;
  }

  static void _validateRequiredText({
    required String fieldName,
    required String value,
  }) {
    if (value.isEmpty) {
      throw ArgumentError.value(
        value,
        fieldName,
        '$fieldName must not be empty.',
      );
    }
  }

  /// Lightweight structural FEN validation for curriculum data.
  ///
  /// Full chess legality remains ChessController/package:chess territory.
  static void validateFen(String fen) {
    final fields = fen.split(RegExp(r'\s+'));

    if (fields.length != 6) {
      throw ArgumentError.value(
        fen,
        'fen',
        'FEN must contain exactly six fields.',
      );
    }

    final ranks = fields[0].split('/');

    if (ranks.length != 8) {
      throw ArgumentError.value(
        fen,
        'fen',
        'FEN board must contain eight ranks.',
      );
    }

    const pieceSymbols = 'prnbqkPRNBQK';

    for (final rank in ranks) {
      var squares = 0;

      for (final rune in rank.runes) {
        final character = String.fromCharCode(rune);

        final digit = int.tryParse(character);

        if (digit != null) {
          if (digit < 1 || digit > 8) {
            throw ArgumentError.value(
              fen,
              'fen',
              'Invalid empty-square count in FEN.',
            );
          }

          squares += digit;
          continue;
        }

        if (!pieceSymbols.contains(character)) {
          throw ArgumentError.value(fen, 'fen', 'Invalid piece symbol in FEN.');
        }

        squares++;
      }

      if (squares != 8) {
        throw ArgumentError.value(
          fen,
          'fen',
          'Every FEN rank must describe exactly eight squares.',
        );
      }
    }

    if (fields[1] != 'w' && fields[1] != 'b') {
      throw ArgumentError.value(fen, 'fen', 'FEN active color must be w or b.');
    }
  }

  static bool _isValidSquare(String square) {
    if (square.length != 2) {
      return false;
    }

    final file = square.codeUnitAt(0);
    final rank = square.codeUnitAt(1);

    return file >= 'a'.codeUnitAt(0) &&
        file <= 'h'.codeUnitAt(0) &&
        rank >= '1'.codeUnitAt(0) &&
        rank <= '8'.codeUnitAt(0);
  }
}
