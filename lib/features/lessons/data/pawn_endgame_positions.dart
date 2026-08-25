import '../domain/lesson_definition.dart';
import '../domain/lesson_position_definition.dart';

const String keySquaresLesson01Id = 'pawn-key-squares-01';
const String keySquaresLesson02Id = 'pawn-key-squares-02';

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
        fen: '1k6/8/1K6/1P6/8/8/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'Recognize that reaching a key square establishes the theoretical win, but accurate conversion is still required.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-02c',
        lessonId: keySquaresLesson02Id,
        role: LessonPositionRole.prove,
        fen: '1k6/8/1K6/1P6/8/8/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'Convert the exact Diagram 1-2 position without relying on an invented equivalent position.',
      ),
    ]);
