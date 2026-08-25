import '../domain/lesson_definition.dart';
import '../domain/lesson_position_definition.dart';
import 'pawn_endgame_positions.dart';

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
  theoreticalResult: TheoreticalResult.draw,
  comparisonOutcomes: <LessonPositionOutcome>[
    LessonPositionOutcome(
      fen: '8/3k4/8/3K4/3P4/8/8/8 b - - 0 1',
      result: TheoreticalResult.win,
      teachingPoint: 'Black must retreat, allowing the white king to enter one of the key squares.',
    ),
  ],
  difficulty: 1,
);

final LessonPositionDefinition _lesson02Learn = keySquaresLesson02Positions
    .singleWhere((position) => position.role == LessonPositionRole.learn);

final LessonDefinition keySquaresLesson02 = LessonDefinition(
  id: keySquaresLesson02Id,
  title: 'The Fifth Rank',
  fen: _lesson02Learn.fen,
  concept: LessonConcept.keySquares,
  objective: 'Understand how the key-square zone expands when the pawn reaches the fifth rank.',
  learnText:
      'When a non-rook pawn reaches the fifth rank, its key-square zone expands. '
      'For the white pawn on d5, the six key squares are c6, d6, e6, c7, d7, and e7. '
      'The king should use this larger target zone to support the pawn toward promotion.',
  userSide: ChessSide.white,
  initialKeySquares: <String>{'c6', 'd6', 'e6', 'c7', 'd7', 'e7'},
  theoreticalResult: _lesson02Learn.theoreticalResult,
  comparisonOutcomes: keySquaresLesson02Positions
      .where((position) => position.role != LessonPositionRole.learn)
      .map(
        (position) => LessonPositionOutcome(
          fen: position.fen,
          result: position.theoreticalResult,
          teachingPoint: position.teachingPoint,
        ),
      ),
  difficulty: 1,
);
