import '../domain/lesson_definition.dart';
import '../domain/lesson_position_definition.dart';

const String keySquaresLesson01Id = 'pawn-key-squares-01';
const String keySquaresLesson02Id = 'pawn-key-squares-02';
const String keySquaresLesson03Id = 'pawn-key-squares-03';

final List<LessonPositionDefinition> keySquaresLesson01Positions =
    List<LessonPositionDefinition>.unmodifiable(<LessonPositionDefinition>[
      LessonPositionDefinition(
        id: 'pawn-key-squares-01a',
        lessonId: keySquaresLesson01Id,
        role: LessonPositionRole.learn,
        fen: '8/3k4/8/3K4/3P4/8/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.draw,
        teachingPoint:
            'The white king on d5 has not reached c6, d6, or e6. With White to move, the position is drawn.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-01b',
        lessonId: keySquaresLesson01Id,
        role: LessonPositionRole.practice,
        fen: '8/3k4/8/3K4/3P4/8/8/8 b - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'With Black to move, the defending king must retreat and White can enter a key square.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-01c',
        lessonId: keySquaresLesson01Id,
        role: LessonPositionRole.prove,
        fen: '8/3k4/8/3K4/3P4/8/8/8 b - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'Prove the side-to-move rule by converting after Black is forced away from the key-square zone.',
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
            'In Dvoretsky Diagram 1-2, the pawn on b5 has six key squares and the white king already occupies b6.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-02b',
        lessonId: keySquaresLesson02Id,
        role: LessonPositionRole.practice,
        fen: '8/k7/2K5/1P6/8/8/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'After the inaccurate route Kc6 and Black\'s reply Ka7, White must return toward the original winning setup instead of forcing the pawn.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-02c',
        lessonId: keySquaresLesson02Id,
        role: LessonPositionRole.practice,
        fen: 'k7/2K5/8/1P6/8/8/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'This exact Diagram 1-2 variation tests the natural error of pushing the pawn too soon: White must preserve the winning king route and avoid stalemate.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-02d',
        lessonId: keySquaresLesson02Id,
        role: LessonPositionRole.prove,
        fen: '1k6/8/1K6/1P6/8/8/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'Play out the exact Diagram 1-2 position and convert the theoretical win while respecting the king route and stalemate resources shown by Dvoretsky.',
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
        fen: '8/8/3k4/8/1P6/1K6/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'After Kc2, Ke7, Kb3 and Kd6, White should continue toward a6. The natural Kc4 route lets Black defend with Kc6.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-03c',
        lessonId: keySquaresLesson03Id,
        role: LessonPositionRole.prove,
        fen: '5k2/8/8/8/1P6/8/8/3K4 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'Play out the exact Diagram 1-3 position and prove that choosing the hardest key square for the enemy king to defend is the winning method.',
      ),
    ]);
