import '../domain/lesson_definition.dart';
import '../domain/lesson_position_definition.dart';
import 'pawn_endgame_positions.dart';

List<LessonPositionOutcome> _comparisonOutcomesFrom(
  List<LessonPositionDefinition> positions, {
  required String initialFen,
}) {
  final seen = <String>{initialFen};
  final outcomes = <LessonPositionOutcome>[];

  for (final position in positions) {
    if (!seen.add(position.fen)) {
      continue;
    }

    outcomes.add(
      LessonPositionOutcome(
        fen: position.fen,
        result: position.theoreticalResult,
        teachingPoint: position.teachingPoint,
      ),
    );
  }

  return List<LessonPositionOutcome>.unmodifiable(outcomes);
}

final LessonPositionDefinition _lesson01Learn = keySquaresLesson01Positions
    .singleWhere((position) => position.role == LessonPositionRole.learn);

final LessonDefinition keySquaresLesson01 = LessonDefinition(
  id: keySquaresLesson01Id,
  title: 'Key Squares: Fifth-Rank Pawn',
  fen: _lesson01Learn.fen,
  concept: LessonConcept.keySquares,
  objective:
      'Read the key-square zone correctly for the exact d5-pawn position and hold the theoretical draw.',
  learnText:
      'White has king d4 and pawn d5 against the black king on d7. '
      'Because the pawn is already on the fifth rank, its key-square zone contains six squares: c6, d6, e6, c7, d7, and e7. '
      'The black king already controls this zone. White to move must not confuse having an advanced pawn with having a forced win. '
      'The practical task is to play accurately and preserve the theoretical draw.',
  userSide: ChessSide.white,
  initialKeySquares: <String>{'c6', 'd6', 'e6', 'c7', 'd7', 'e7'},
  theoreticalResult: _lesson01Learn.theoreticalResult,
  comparisonOutcomes: _comparisonOutcomesFrom(
    keySquaresLesson01Positions,
    initialFen: _lesson01Learn.fen,
  ),
  difficulty: 1,
);

final LessonPositionDefinition _lesson02Learn = keySquaresLesson02Positions
    .singleWhere((position) => position.role == LessonPositionRole.learn);

final LessonDefinition keySquaresLesson02 = LessonDefinition(
  id: keySquaresLesson02Id,
  title: 'Do Not Force the Pawn',
  fen: _lesson02Learn.fen,
  concept: LessonConcept.practicalAwareness,
  objective:
      'Play the exact b6-pawn position without assuming that an advanced pawn can be forced through.',
  learnText:
      'White has king b5 and pawn b6 against the black king on b8, with White to move. '
      'This position is a drawing task. The pawn is close to promotion, but the defending king is ideally placed in front of it. '
      'Do not invent a winning plan from the pawn\'s rank alone. Play the position to its genuine chess conclusion and prove the draw.',
  userSide: ChessSide.white,
  initialKeySquares: const <String>{},
  theoreticalResult: _lesson02Learn.theoreticalResult,
  comparisonOutcomes: _comparisonOutcomesFrom(
    keySquaresLesson02Positions,
    initialFen: _lesson02Learn.fen,
  ),
  difficulty: 1,
);

final LessonPositionDefinition _lesson03Learn = keySquaresLesson03Positions
    .singleWhere((position) => position.role == LessonPositionRole.learn);

final LessonDefinition keySquaresLesson03 = LessonDefinition(
  id: keySquaresLesson03Id,
  title: 'Choose the Right Key Square',
  fen: _lesson03Learn.fen,
  concept: LessonConcept.keySquares,
  objective:
      'Learn how to choose between several key squares by aiming for the one hardest for the enemy king to defend.',
  learnText:
      'For the white pawn on b4, the key squares are a6, b6, and c6. '
      'All three are theoretically important, but they are not equally easy to reach. '
      'Because the black king starts on f8, White should head toward a6, the key square farthest from the defender. '
      'Dvoretsky uses this position to teach route selection: choose the key square the enemy king will have the greatest difficulty reaching in time.',
  userSide: ChessSide.white,
  initialKeySquares: <String>{'a6', 'b6', 'c6'},
  theoreticalResult: _lesson03Learn.theoreticalResult,
  comparisonOutcomes: _comparisonOutcomesFrom(
    keySquaresLesson03Positions,
    initialFen: _lesson03Learn.fen,
  ),
  difficulty: 1,
);

final LessonPositionDefinition _lesson04Learn = keySquaresLesson04Positions
    .singleWhere((position) => position.role == LessonPositionRole.learn);

final LessonDefinition keySquaresLesson04 = LessonDefinition(
  id: keySquaresLesson04Id,
  title: 'Recalculate the Key Squares',
  fen: _lesson04Learn.fen,
  concept: LessonConcept.keySquares,
  objective:
      'Learn to recalculate key squares when pawn moves change the structure of the endgame.',
  learnText:
      'In Diagram 1-4 White must not treat key squares as a fixed map. '
      'The initial white pawn on g2 has the key squares f4, g4, and h4. '
      'After Kf2, Black can advance the h-pawn, and White must anticipate how that changes the position. '
      'The critical idea comes after ...h3: g3 changes the white pawn structure, and the key squares for the pawn on g3 move to f5, g5, and h5, closer to the white king. '
      'Recalculate the key-square zone whenever a pawn move changes the structure.',
  userSide: ChessSide.white,
  initialKeySquares: <String>{'f4', 'g4', 'h4'},
  theoreticalResult: _lesson04Learn.theoreticalResult,
  comparisonOutcomes: _comparisonOutcomesFrom(
    keySquaresLesson04Positions,
    initialFen: _lesson04Learn.fen,
  ),
  difficulty: 1,
);

final LessonDefinition pawnTragicomedyLesson05 = LessonDefinition(
  id: pawnTragicomedyLesson05Id,
  title: 'Tragicomedy: Do Not Resign Too Soon',
  fen: '8/8/3p4/3P4/5k2/3K4/8/8 w - - 0 1',
  concept: LessonConcept.practicalAwareness,
  objective:
      'Learn to evaluate the resulting pawn ending before assuming that losing a pawn means losing the game.',
  learnText:
      'Dvoretsky places this Coull–Stanciu position immediately after the Key Squares examples as a practical warning. '
      'White resigned after seeing that the d5-pawn could not be saved. The lesson is not to stop the calculation there. '
      'Before resigning, calculate the position that remains after the pawn is lost and evaluate the kings, the remaining pawn, and the side to move. '
      'Material loss and game loss are not the same conclusion.',
  userSide: ChessSide.white,
  initialKeySquares: const <String>{},
  theoreticalResult: TheoreticalResult.draw,
  difficulty: 1,
);

final LessonDefinition pawnTragicomedyLesson06 = LessonDefinition(
  id: pawnTragicomedyLesson06Id,
  title: 'Tragicomedy: One Careless Rook Move',
  fen: '8/8/5pk1/5r2/R7/5K2/8/8 w - - 0 1',
  concept: LessonConcept.practicalAwareness,
  objective:
      'Learn to check the enemy king\'s access before making an automatic rook move in a technical ending.',
  learnText:
      'Dvoretsky ends the Tragicomedies with the Spielmann–Duras position. '
      'White played 1.Rf4?? and after ...Kg5! resigned. '
      'The warning is practical: before committing the rook, check whether the move opens a decisive route for the enemy king. '
      'Do not judge a technical position by habit; recalculate the opponent\'s most forcing reply first.',
  userSide: ChessSide.white,
  initialKeySquares: const <String>{},
  theoreticalResult: TheoreticalResult.draw,
  difficulty: 1,
);
