import '../domain/lesson_definition.dart';
import '../domain/lesson_position_definition.dart';
import 'pawn_endgame_lessons.dart';

final List<LessonPositionDefinition> keySquaresLesson02Positions =
    List<LessonPositionDefinition>.unmodifiable(<LessonPositionDefinition>[
      LessonPositionDefinition(
        id: 'pawn-key-squares-02a',
        lessonId: keySquaresLesson02.id,
        role: LessonPositionRole.learn,
        fen: '7k/8/8/3P4/3K4/8/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint: 'A non-rook pawn on the fifth rank has six key squares.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-02b',
        lessonId: keySquaresLesson02.id,
        role: LessonPositionRole.practice,
        fen: 'k7/8/8/5P2/5K2/8/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'Transfer the fifth-rank key-square pattern to another file.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-02c',
        lessonId: keySquaresLesson02.id,
        role: LessonPositionRole.practice,
        fen: '5k2/8/8/2P5/2K5/8/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint:
            'Recognize the six-square zone with the defending king closer.',
      ),
      LessonPositionDefinition(
        id: 'pawn-key-squares-02d',
        lessonId: keySquaresLesson02.id,
        role: LessonPositionRole.prove,
        fen: '8/4k3/8/2P5/2K5/8/8/8 w - - 0 1',
        theoreticalResult: TheoreticalResult.win,
        teachingPoint: 'Use the fifth-rank key-square concept to convert against active defence.',
      ),
    ]);
