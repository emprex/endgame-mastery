import '../domain/lesson_definition.dart';
import '../domain/lesson_position_definition.dart';

const String keySquaresLesson01Id = 'pawn-key-squares-01';
const String keySquaresLesson02Id = 'pawn-key-squares-02';
const String keySquaresLesson03Id = 'pawn-key-squares-03';
const String keySquaresLesson04Id = 'pawn-key-squares-04';
const String pawnTragicomedyLesson05Id = 'pawn-tragicomedy-05';
const String pawnTragicomedyLesson06Id = 'pawn-tragicomedy-06';

final List<LessonPositionDefinition> keySquaresLesson01Positions =
    List<LessonPositionDefinition>.unmodifiable(<LessonPositionDefinition>[
      LessonPositionDefinition(
        id: 'pawn-key-squares-01a',
        lessonId: keySquaresLesson01Id,
        role: LessonPositionRole.learn,
        fen: '8/3k4/8/3K4/3P4/8/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.draw,
        teachingPoint:
            'Dvoretsky Diagram 1-1: White king d5, white pawn d4, Black king d7, White to move. The key squares are c6, d6, and e6.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-01b',
        lessonId: keySquaresLesson01Id,
        role: LessonPositionRole.practice,
        fen: '8/3k4/8/3K4/3P4/8/8/8 b - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'Same exact Diagram 1-1 geometry with Black to move: Black must retreat and White can enter a key square.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-01c',
        lessonId: keySquaresLesson01Id,
        role: LessonPositionRole.prove,
        fen: '8/3k4/8/3K4/3P4/8/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.draw,
        teachingPoint:
            'Play the exact Diagram 1-1 position to a genuine chess conclusion and prove the theoretical draw with White to move.',
      ),
    ]);

final List<LessonPositionDefinition> keySquaresLesson02Positions =
    List<LessonPositionDefinition>.unmodifiable(<LessonPositionDefinition>[
      LessonPositionDefinition(
        id: 'pawn-key-squares-02a',
        lessonId: keySquaresLesson02Id,
        role: LessonPositionRole.learn,
        fen: '1k6/8/1K6/1P6/8/8/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'Dvoretsky Diagram 1-2: White king b6, white pawn b5, Black king b8, White to move. The white king already occupies a key square.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-02b',
        lessonId: keySquaresLesson02Id,
        role: LessonPositionRole.practice,
        fen: '1k6/8/1K6/1P6/8/8/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'Begin practice from the exact Diagram 1-2 position before moving to the published conversion checkpoints.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-02c',
        lessonId: keySquaresLesson02Id,
        role: LessonPositionRole.practice,
        fen: '8/k7/2K5/1P6/8/8/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'This published continuation tests the less direct Kc6 route after Black reaches a7.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-02d',
        lessonId: keySquaresLesson02Id,
        role: LessonPositionRole.practice,
        fen: 'k7/2K5/8/1P6/8/8/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'This published continuation tests the stalemate resource: advancing b6 immediately would stalemate Black.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-02e',
        lessonId: keySquaresLesson02Id,
        role: LessonPositionRole.prove,
        fen: '1k6/8/1K6/1P6/8/8/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'Play out the exact Diagram 1-2 position and prove the win without allowing the stalemate resource.',
      ),
    ]);

final List<LessonPositionDefinition> keySquaresLesson03Positions =
    List<LessonPositionDefinition>.unmodifiable(<LessonPositionDefinition>[
      LessonPositionDefinition(
        id: 'pawn-key-squares-03a',
        lessonId: keySquaresLesson03Id,
        role: LessonPositionRole.learn,
        fen: '5k2/8/8/8/1P6/8/8/3K4 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'In Dvoretsky Diagram 1-3, White should head for the key square farthest from the enemy king.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-03b',
        lessonId: keySquaresLesson03Id,
        role: LessonPositionRole.practice,
        fen: '5k2/8/8/8/1P6/8/8/3K4 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'Begin practice from the exact Diagram 1-3 position and choose a king route toward the key square farthest from Black.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-03c',
        lessonId: keySquaresLesson03Id,
        role: LessonPositionRole.practice,
        fen: '8/8/3k4/8/1P6/1K6/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'After Kc2, Ke7, Kb3 and Kd6, White should continue toward a6. The natural Kc4 route lets Black defend with Kc6.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-03d',
        lessonId: keySquaresLesson03Id,
        role: LessonPositionRole.prove,
        fen: '5k2/8/8/8/1P6/8/8/3K4 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'Play out the exact Diagram 1-3 position and prove that choosing the hardest key square for the enemy king to defend is the winning method.',
      ),
    ]);

final List<LessonPositionDefinition> keySquaresLesson04Positions =
    List<LessonPositionDefinition>.unmodifiable(<LessonPositionDefinition>[
      LessonPositionDefinition(
        id: 'pawn-key-squares-04a',
        lessonId: keySquaresLesson04Id,
        role: LessonPositionRole.learn,
        fen: '2k5/8/8/7p/8/8/6P1/5K2 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'Dvoretsky Diagram 1-4: 1.Kf2! is the accurate start. White must anticipate how the h-pawn changes the key-square geometry.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-04b',
        lessonId: keySquaresLesson04Id,
        role: LessonPositionRole.practice,
        fen: '2k5/8/8/7p/8/8/6P1/5K2 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'Begin practice from the exact Diagram 1-4 position. Find the king move that keeps White in time against the h-pawn.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-04c',
        lessonId: keySquaresLesson04Id,
        role: LessonPositionRole.practice,
        fen: '2k5/8/8/8/7p/8/5KP1/8 w - - 0 2',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'After 1.Kf2 h4, Dvoretsky gives 2.Kg1!!. The natural 2.Kf3? is refuted by 2...h3!.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-04d',
        lessonId: keySquaresLesson04Id,
        role: LessonPositionRole.practice,
        fen: '2k5/8/8/8/8/7p/6P1/6K1 w - - 0 3',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'After 1.Kf2 h4 2.Kg1 h3, White changes the pawn structure with 3.g3!, moving the key squares closer to the king.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-04e',
        lessonId: keySquaresLesson04Id,
        role: LessonPositionRole.prove,
        fen: '2k5/8/8/7p/8/8/6P1/5K2 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'Play the exact Diagram 1-4 position to a genuine conclusion and prove the win by recalculating key squares as the pawn structure changes.',
      ),
    ]);

final List<LessonPositionDefinition> pawnTragicomedyLesson05Positions =
    List<LessonPositionDefinition>.unmodifiable(<LessonPositionDefinition>[
      LessonPositionDefinition(
        id: 'pawn-tragicomedy-05-learn',
        lessonId: pawnTragicomedyLesson05Id,
        role: LessonPositionRole.learn,
        fen: '8/8/3p4/3P4/5k2/3K4/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.draw,
        teachingPoint:
            'Dvoretsky Diagram 1-5, Coull-Stanciu: White resigned because the d5-pawn must fall. The lesson is to evaluate the resulting pawn ending before resigning.',
      ),
      LessonPositionDefinition(
        id: 'pawn-tragicomedy-05-practice',
        lessonId: pawnTragicomedyLesson05Id,
        role: LessonPositionRole.practice,
        fen: '8/8/3p4/3P4/5k2/3K4/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.draw,
        teachingPoint:
            'Start from the exact Coull-Stanciu position and keep playing instead of treating the loss of d5 as the end of the game.',
      ),
      LessonPositionDefinition(
        id: 'pawn-tragicomedy-05-prove',
        lessonId: pawnTragicomedyLesson05Id,
        role: LessonPositionRole.prove,
        fen: '8/8/3p4/3P4/5k2/3K4/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.draw,
        teachingPoint:
            'Play the exact Diagram 1-5 position to a genuine conclusion and demonstrate why resigning immediately is unjustified.',
      ),
    ]);

final List<LessonPositionDefinition> pawnTragicomedyLesson06Positions =
    List<LessonPositionDefinition>.unmodifiable(<LessonPositionDefinition>[
      LessonPositionDefinition(
        id: 'pawn-tragicomedy-06-learn',
        lessonId: pawnTragicomedyLesson06Id,
        role: LessonPositionRole.learn,
        fen: '8/8/5pk1/5r2/R7/5K2/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.draw,
        teachingPoint:
            'Dvoretsky Diagram 1-6, Spielmann-Duras: 1.Rf4?? allows 1...Kg5!, after which White resigned.',
      ),
      LessonPositionDefinition(
        id: 'pawn-tragicomedy-06-practice',
        lessonId: pawnTragicomedyLesson06Id,
        role: LessonPositionRole.practice,
        fen: '8/8/5pk1/5r2/R7/5K2/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.draw,
        teachingPoint:
            'Start from the exact Spielmann-Duras position. Before moving the rook, check whether the move grants Black immediate king penetration with ...Kg5.',
      ),
      LessonPositionDefinition(
        id: 'pawn-tragicomedy-06-prove',
        lessonId: pawnTragicomedyLesson06Id,
        role: LessonPositionRole.prove,
        fen: '8/8/5pk1/5r2/R7/5K2/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.draw,
        teachingPoint:
            'Play the exact Diagram 1-6 position to a genuine conclusion while avoiding the careless 1.Rf4?? king-penetration error.',
      ),
    ]);
