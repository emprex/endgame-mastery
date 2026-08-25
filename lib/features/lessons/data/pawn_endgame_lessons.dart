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
  title: 'Key Squares',
  fen: _lesson01Learn.fen,
  concept: LessonConcept.keySquares,
  objective:
      'Recognize the three key squares for a fourth-rank pawn and understand why the side to move changes the result.',
  learnText:
      'White has king d5 and pawn d4 against the black king on d7. '
      'The king on d5 is not yet on a key square. The key squares are c6, d6, and e6. '
      'With White to move, White cannot enter one of them and the position is drawn. '
      'With Black to move, Black must retreat and White can step onto a key square, which wins.',
  userSide: ChessSide.white,
  initialKeySquares: <String>{'c6', 'd6', 'e6'},
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
  title: 'The Fifth Rank',
  fen: _lesson02Learn.fen,
  concept: LessonConcept.keySquares,
  objective:
      'Convert the exact fifth-rank pawn position by using the king correctly and avoiding stalemate.',
  learnText:
      'White has king b6 and pawn b5 against the black king on b8, with White to move. '
      'For a white pawn on the fifth rank, the key-square zone contains six squares: a6, b6, c6, a7, b7, and c7. '
      'The white king already stands on b6, one of those key squares, so the position is winning. '
      'The important practical lesson is conversion: use the king to make progress and do not rush the pawn into a stalemate resource.',
  userSide: ChessSide.white,
  initialKeySquares: <String>{'a6', 'b6', 'c6', 'a7', 'b7', 'c7'},
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
      'Anticipate pawn advances and recalculate the key squares when the pawn structure changes.',
  learnText:
      'Dvoretsky Diagram 1-4 starts with White king f1 and pawn g2 against Black king c8 and pawn h5. '
      'The accurate move is 1.Kf2!. The natural 1.Kg1? lets the black king arrive in time to defend the pawn. '
      'After 1.Kf2 h4, White must play 2.Kg1!!; 2.Kf3? fails to 2...h3!. '
      'After 2...h3, 3.g3! changes the pawn structure. The key squares for the pawn on g3 are f5, g5, and h5, which are closer to White\'s king. '
      'The rule is practical: when a pawn move changes the structure, recalculate the key squares instead of using the old map.',
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
  title: 'Tragicomedy: Calculate Before Resigning',
  fen: '8/8/3p4/3P4/5k2/3K4/8/8 w - - 0 1',
  concept: LessonConcept.practicalAwareness,
  objective:
      'Keep calculating after a pawn is lost and evaluate the resulting king-and-pawn ending before resigning.',
  learnText:
      'In the Coull-Stanciu position from Diagram 1-5, White saw that the d5-pawn could not be saved and resigned. '
      'Dvoretsky presents the example as a warning against ending the calculation too early. '
      'The important question is not whether the pawn falls, but what the remaining pawn ending actually is. '
      'Before resigning, continue the calculation through the material change and judge the resulting kings, pawn and side to move.',
  userSide: ChessSide.white,
  initialKeySquares: const <String>{},
  theoreticalResult: TheoreticalResult.draw,
  difficulty: 1,
);

final LessonDefinition pawnTragicomedyLesson06 = LessonDefinition(
  id: pawnTragicomedyLesson06Id,
  title: 'Tragicomedy: Check the King Route',
  fen: '8/8/5pk1/5r2/R7/5K2/8/8 w - - 0 1',
  concept: LessonConcept.practicalAwareness,
  objective:
      'Before making an automatic rook move, check whether it gives the enemy king a decisive route.',
  learnText:
      'In the Spielmann-Duras position from Diagram 1-6, White played 1.Rf4??. Black answered 1...Kg5!, and White resigned. '
      'Dvoretsky uses the example as a final practical warning before Corresponding Squares. '
      'The lesson is not to move the rook by habit: first ask which king square the move releases. '
      'Here the critical route is ...Kg5, so the user must check Black\'s king penetration before committing the rook.',
  userSide: ChessSide.white,
  initialKeySquares: const <String>{},
  theoreticalResult: TheoreticalResult.draw,
  difficulty: 1,
);
