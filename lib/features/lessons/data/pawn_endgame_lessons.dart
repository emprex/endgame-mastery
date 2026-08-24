import '../domain/lesson_definition.dart';

/// Pawn Endgames — Key Squares.
///
/// Dvoretsky's teaching point here depends critically on the side to move.
///
/// Same piece placement:
///
/// White to move -> draw.
/// Black to move -> White wins.
///
/// The key squares are c6, d6 and e6.
/// The white king on d5 is not yet on a key square.
final LessonDefinition keySquaresLesson01 = LessonDefinition(
  id: 'pawn-key-squares-01',
  title: 'Key Squares',
  fen: '8/3k4/8/3K4/3P4/8/8/8 w - - 0 1',
  concept: LessonConcept.keySquares,
  objective: 'Understand what key squares are and why the side to move can completely change the theoretical result.',
  learnText:
      'The white king on d5 has not yet reached a key square. '
      'The relevant key squares are c6, d6, and e6. '
      'With White to move, White cannot force entry onto one of these key squares, so the position is drawn. '
      'With Black to move, Black must retreat and White can enter a key square, so White wins.',
  userSide: ChessSide.white,
  initialKeySquares: <String>{'c6', 'd6', 'e6'},

  // Initial position: White to move -> draw.
  theoreticalResult: TheoreticalResult.draw,

  // Same pieces, Black to move -> White wins.
  comparisonOutcomes: <LessonPositionOutcome>[
    LessonPositionOutcome(
      fen: '8/3k4/8/3K4/3P4/8/8/8 b - - 0 1',
      result: TheoreticalResult.win,
      teachingPoint: 'Black must retreat, allowing the white king to enter one of the key squares.',
    ),
  ],

  difficulty: 1,
);
